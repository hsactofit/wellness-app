/// OAuth client IDs already present in `android/app/google-services.json`
/// (type 3 / web). Firebase Auth needs this as `serverClientId` so the
/// Google sign-in plugin returns an ID token Firebase will accept.
class GoogleAuthConfig {
  static const String webClientId =
      '133235672969-tam6tkijvkiv0jt9i379rvm9mgfsn531.apps.googleusercontent.com';
}
