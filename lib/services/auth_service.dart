import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'health_service.dart';
import '../models/gender.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the currently authenticated user, if any.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google Sign-In & Firebase Auth (google_sign_in 7.0.0+ compatible)
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-in flow (v7.0.0+ uses authenticate())
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // Obtain auth details (tokens)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a credential for Firebase (v7.0.0+ only requires idToken)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Authenticate with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Google Authentication error: $e");
      rethrow;
    }
  }

  /// Apple Sign-In & Firebase Auth
  Future<User?> signInWithApple() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Firebase drives the native iOS sheet and nonce. This is the
        // supported iOS path; the plugin call below is for Android.
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        final userCredential = await _auth.signInWithProvider(appleProvider);
        return userCredential.user;
      }

      final rawNonce = _generateNonce();
      final sha256Nonce = _sha256ofString(rawNonce);

      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256Nonce,
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      // Apple only returns name metadata on the first signup.
      if (user != null) {
        String? displayName;
        if (appleIdCredential.givenName != null) {
          displayName = appleIdCredential.givenName;
          if (appleIdCredential.familyName != null) {
            displayName = "$displayName ${appleIdCredential.familyName}";
          }
        }
        if (displayName != null &&
            (user.displayName == null || user.displayName!.isEmpty)) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }
      }

      return _auth.currentUser;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      if (e.code == AuthorizationErrorCode.unknown) {
        throw AuthException(
          'Apple Sign In is not available here. On the simulator, open Settings and sign in with an Apple ID, enable Sign in with Apple for this App ID in Apple Developer, then do a full rebuild.',
        );
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      final raw = '${e.code} ${e.message ?? ''}';
      if (raw.contains('1000') ||
          raw.contains('unknown') ||
          e.code == 'unknown') {
        throw AuthException(
          'Apple Sign In is not available here. On the simulator, open Settings and sign in with an Apple ID, enable Sign in with Apple for this App ID in Apple Developer, then do a full rebuild.',
        );
      }
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint("Apple Authentication error: $e");
      rethrow;
    }
  }

  // JWT tokens cache keys
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';

  // Getters for tokens
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Base API URL — wellness-server (see medifit-kb/MEDIFIT_KB.md).
  // Debug iOS/Android builds use this Mac's LAN address because a physical
  // phone's localhost is the phone, not the API. Override with
  // --dart-define=API_BASE_URL=https://...
  static String get apiBaseUrl => ApiConfig.baseUrl;

  /// API route namespace. The development server uses `/api`; the deployed
  /// Wellness360 API is versioned under `/api/v1`.
  static const String apiPathPrefix = String.fromEnvironment(
    'API_PATH_PREFIX',
    defaultValue: '/api',
  );

  /// Builds an API URL while allowing the server route namespace to vary by
  /// build. Existing callers may continue to pass their legacy `/api/...`
  /// paths, so the default Medifit behavior stays unchanged.
  static Uri apiUrl(String path) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final prefixedPath = apiPathPrefix.startsWith('/')
        ? apiPathPrefix
        : '/$apiPathPrefix';
    final prefix = prefixedPath.endsWith('/') && prefixedPath.length > 1
        ? prefixedPath.substring(0, prefixedPath.length - 1)
        : prefixedPath;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    const legacyPrefix = '/api';

    if (normalizedPath == legacyPrefix ||
        normalizedPath.startsWith('$legacyPrefix/')) {
      return Uri.parse(
        '$base$prefix${normalizedPath.substring(legacyPrefix.length)}',
      );
    }
    return Uri.parse('$base$normalizedPath');
  }

  // Signup API
  Future<Map<String, dynamic>> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'provider': 'email',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          await _saveTokens(accessToken, refreshToken);
        }
        return data;
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw AuthException(errorMsg);
      }
    } catch (e) {
      debugPrint("SignUp API error: $e");
      rethrow;
    }
  }

  // Login API
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          await _saveTokens(accessToken, refreshToken);
        }
        return data;
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw AuthException(errorMsg);
      }
    } catch (e) {
      debugPrint("Login API error: $e");
      rethrow;
    }
  }

  // Passwordless login, step 1: emails a one-time code.
  Future<String> requestLoginCode(String email) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/login-code/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['message'] ?? 'Sign-in code sent to email';
      } else {
        throw Exception(_extractErrorMessage(data));
      }
    } catch (e) {
      debugPrint("Request Login Code API error: $e");
      rethrow;
    }
  }

  // Passwordless login, step 2: exchanges the code for real tokens, same
  // response shape as loginWithEmail.
  Future<Map<String, dynamic>> loginWithCode(String email, String otp) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/login-code/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          await _saveTokens(accessToken, refreshToken);
        }
        return data;
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw AuthException(errorMsg);
      }
    } catch (e) {
      debugPrint("Login With Code API error: $e");
      rethrow;
    }
  }

  // Refresh Tokens / Validate Session API
  Future<Map<String, dynamic>> refreshSessionToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw AuthException("No refresh token found");
      }

      final response = await http.post(
        apiUrl('/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final accessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        if (accessToken != null && newRefreshToken != null) {
          await _saveTokens(accessToken, newRefreshToken);
        }
        return data;
      } else {
        await _clearTokens();
        final errorMsg = _extractErrorMessage(data);
        throw AuthException(errorMsg);
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint("Token Refresh API connection error: $e");
      // Do NOT clear tokens on network/connection errors to preserve persistence
      rethrow;
    }
  }

  // Request OTP for password recovery
  Future<String> forgotPassword(String email) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['message'] ?? 'OTP sent to email';
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint("Forgot Password API error: $e");
      rethrow;
    }
  }

  // Verify OTP code to obtain Reset Token
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final resetToken = data['reset_token'];
        if (resetToken == null) {
          throw Exception("Reset token not found in response");
        }
        return resetToken;
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint("Verify OTP API error: $e");
      rethrow;
    }
  }

  // Reset Password using reset token
  Future<String> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reset_token': resetToken,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['message'] ?? 'Password reset successful';
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint("Reset Password API error: $e");
      rethrow;
    }
  }

  // Social Auth API backend linking
  Future<Map<String, dynamic>> socialLoginBackend(
    String provider,
    String token, {
    String? name,
    bool isLogin = false,
  }) async {
    try {
      final response = await http.post(
        apiUrl('/api/auth/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider.toLowerCase(),
          // wellness-server's field is `id_token` (see app/schemas/auth.py
          // SocialLoginIn) — the old prototype backend called it `token`.
          'id_token': token,
          'name': name,
          'mode': isLogin ? 'login' : 'signup',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        if (accessToken != null && refreshToken != null) {
          await _saveTokens(accessToken, refreshToken);
        }
        return data;
      } else {
        final errorMsg = _extractErrorMessage(data);
        throw AuthException(errorMsg);
      }
    } catch (e) {
      debugPrint("Social Login API error: $e");
      final message = e.toString();
      if (message.contains('Connection refused') ||
          message.contains('SocketException') ||
          message.contains('Failed host lookup')) {
        throw AuthException(
          'Cannot reach the API at $apiBaseUrl. On a physical phone this must be your Mac Wi-Fi IP, and wellness-server must be running.',
        );
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listSsoOrganizations() async {
    final response = await http.get(apiUrl('/api/auth/sso/organizations'));
    final data = _decodeResponseBody(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_extractErrorMessage(data));
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw AuthException('Could not load organizations');
  }

  Future<Map<String, dynamic>> startSso({
    required String email,
    required String password,
    required String corporateId,
    required bool isLogin,
  }) async {
    final response = await http.post(
      apiUrl('/api/auth/sso/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'corporate_id': corporateId,
        'mode': isLogin ? 'login' : 'signup',
      }),
    );
    final data = _decodeResponseBody(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_extractErrorMessage(data));
    }
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> verifySso({
    required String email,
    required String otp,
    required String corporateId,
  }) async {
    final response = await http.post(
      apiUrl('/api/auth/sso/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'corporate_id': corporateId,
      }),
    );
    final data = _decodeResponseBody(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_extractErrorMessage(data));
    }
    final map = Map<String, dynamic>.from(data as Map);
    final accessToken = map['access_token'];
    final refreshToken = map['refresh_token'];
    if (accessToken != null && refreshToken != null) {
      await _saveTokens(accessToken as String, refreshToken as String);
    }
    return map;
  }

  // ---- Enrolment API (wellness-server /enrolments/*) ----
  // Replaces the old prototype's single POST /api/onboarding call, which
  // has no equivalent on wellness-server. The real pipeline is a sequence:
  // list corporates/facilities -> start -> health-assessment -> consent.
  // See app/api/v1/enrolment.py and medifit-kb/MEDIFIT_KB.md §5.

  Future<Map<String, dynamic>> _authedGet(String path) async {
    final token = await getAccessToken();
    final response = await http.get(
      apiUrl(path),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(_decodeResponseBody(response.body)));
    }
    return {'body': _decodeResponseBody(response.body)};
  }

  Future<Map<String, dynamic>> _authedPost(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = await getAccessToken();
    final response = await http.post(
      apiUrl(path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    final data = _decodeResponseBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractErrorMessage(data));
    }
    return data as Map<String, dynamic>;
  }

  Future<List<dynamic>> listEnrolmentCorporates() async {
    final result = await _authedGet('/api/enrolments/corporates');
    return result['body'] as List<dynamic>;
  }

  Future<List<dynamic>> listEnrolmentFacilities() async {
    final result = await _authedGet('/api/enrolments/facilities');
    return result['body'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> startEnrolment({
    required String corporateId,
    required String facilityId,
    String? goal,
    List<String> goals = const [],
    String? activityLevel,
    String? dob,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) {
    return _authedPost('/api/enrolments/me/start', {
      'corporate_id': corporateId,
      'facility_id': facilityId,
      'goal': goal,
      'goals': goals,
      'activity_level': activityLevel,
      'dob': dob,
      'gender': genderApiValue(gender),
      'height_cm': heightCm,
      'weight_kg': weightKg,
    });
  }

  Future<Map<String, dynamic>> submitHealthAssessment({
    required Map<String, String> answers,
    String? declaredCondition,
  }) {
    return _authedPost('/api/enrolments/me/health-assessment', {
      'answers': answers,
      'declared_condition': declaredCondition,
    });
  }

  Future<Map<String, dynamic>> submitEnrolmentConsent({
    required Map<String, bool> grants,
    required String signatureName,
  }) {
    return _authedPost('/api/enrolments/me/consent', {
      'grants': grants.entries
          .map((e) => {'key': e.key, 'granted': e.value})
          .toList(),
      'signature_name': signatureName,
    });
  }

  // Helper to extract error message from API response (specifically FastAPI ValidationError)
  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      if (data['detail'] != null) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final firstErr = detail[0];
          if (firstErr is Map && firstErr['msg'] != null) {
            return firstErr['msg'].toString();
          }
        }
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'An unknown server error occurred.';
  }

  dynamic _decodeResponseBody(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return {'detail': body.trim().isEmpty ? 'Empty server response' : body};
    }
  }

  /// Sign out from Firebase, Google Sign-In, and clear backend tokens
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (e) {
      debugPrint("Error disconnecting Google Sign-In: $e");
    }
    await _clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    await prefs.remove('onboarding_data');
    await prefs.remove('healthSetupCompleted');
    await prefs.remove('healthConnectRequested');
    await prefs.remove('health_sync_enabled');
    await prefs.remove('sso_corporate_id');
    await prefs.remove('sso_corporate_name');
    await prefs.remove('sso_corporate_logo_url');
    await prefs.remove('sso_health_provider_linked');
    await prefs.remove('user_provider');
    await HealthService.instance.resetLocalState();
  }

  /// Helper to generate a random cryptographically secure string (nonce)
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Helper to hash a string using SHA-256
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
