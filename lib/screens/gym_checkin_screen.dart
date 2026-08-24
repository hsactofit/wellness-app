import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../app_brand.dart';
import '../services/workout_session_service.dart';
import '../widgets/glass_card.dart';

class GymCheckinScreen extends StatefulWidget {
  final VoidCallback? onStatusChanged;
  const GymCheckinScreen({super.key, this.onStatusChanged});

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

class _GymCheckinScreenState extends State<GymCheckinScreen>
    with TickerProviderStateMixin {
  bool _isCheckedIn = false;
  String? _gymName;
  String? _gymPlace;
  DateTime? _checkInTime;

  bool _isLoading = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Camera permission tracking
  bool _cameraPermissionGranted = false;

  // Manual facility-code entry — fallback when the camera/QR isn't usable
  // (no camera, damaged/missing QR sticker, or the QR still encodes the old
  // freeform {name, place} payload instead of a real Facility.code).
  bool _showManualEntry = false;
  final TextEditingController _manualCodeController = TextEditingController();

  // Real Camera barcode/QR scanner controller
  MobileScannerController? _scannerController;

  // Camera mock scanner states
  late AnimationController _scannerAnimController;
  late Animation<double> _scannerLinePosition;

  // Checkout exercise logging
  final List<Map<String, dynamic>> _loggedExercises = [];

  final List<String> _popularExercises = [
    "Bench Press",
    "Squats",
    "Treadmill Running",
    "Deadlift",
    "Bicep Curl",
    "Leg Press",
    "Shoulder Press",
    "Pull-ups",
    "Push-ups",
    "Plank",
  ];

  @override
  void initState() {
    super.initState();
    WorkoutSessionService.instance.sessionRefreshSignal.addListener(
      _handleExternalSessionChange,
    );
    _loadCheckinState();
    _checkCameraPermission();

    // Setup pulse scan line animation
    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerLinePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerAnimController, curve: Curves.easeInOut),
    );
  }

  void _initScanner() {
    if (_scannerController == null &&
        _cameraPermissionGranted &&
        !_isCheckedIn) {
      setState(() {
        _scannerController = MobileScannerController();
      });
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() {
        _cameraPermissionGranted = status.isGranted;
      });
      if (status.isGranted) {
        _initScanner();
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _cameraPermissionGranted = status.isGranted;
      });
      if (status.isGranted) {
        _initScanner();
      }
    }
  }

  @override
  void dispose() {
    WorkoutSessionService.instance.sessionRefreshSignal.removeListener(
      _handleExternalSessionChange,
    );
    _timer?.cancel();
    _scannerAnimController.dispose();
    _scannerController?.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _handleExternalSessionChange() {
    _loadCheckinState();
  }

  Future<void> _loadCheckinState() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool('gym_checked_in') ?? false;
    if (!mounted) return;
    if (isCheckedIn) {
      final name = prefs.getString('gym_name');
      final place = prefs.getString('gym_place');
      final timeStr = prefs.getString('gym_check_in_time');
      final checkInTime = timeStr != null ? DateTime.tryParse(timeStr) : null;

      setState(() {
        _isCheckedIn = true;
        _gymName = name;
        _gymPlace = place;
        _checkInTime = checkInTime;
      });
      _startTimer();
      await _loadLoggedExercises();
    } else {
      _timer?.cancel();
      setState(() {
        _isCheckedIn = false;
        _gymName = null;
        _gymPlace = null;
        _checkInTime = null;
        _elapsed = Duration.zero;
        _loggedExercises.clear();
      });
    }
  }

  Future<void> _saveLoggedExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'gym_logged_exercises',
        jsonEncode(_loggedExercises),
      );
    } catch (e) {
      debugPrint("Error saving logged exercises: $e");
    }
  }

  Future<void> _loadLoggedExercises() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('gym_logged_exercises');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        setState(() {
          _loggedExercises.clear();
          _loggedExercises.addAll(
            decoded.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading logged exercises: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_checkInTime == null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsed = DateTime.now().difference(_checkInTime!);
      });
    });
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a facility code first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // A manually-typed code is never JSON, so _handleCheckin's fallback
    // path treats it as the raw facility code directly (uppercased) — no
    // separate code path needed.
    _handleCheckin(code);
  }

  Future<void> _handleCheckin(String qrString) async {
    // Stop the scanner from delivering duplicate frames while the member is
    // completing the required second factor for this facility session.
    setState(() => _isLoading = true);

    try {
      // wellness-server identifies the facility by its short code (e.g.
      // "BLR1", see Facility.code in wellness-server), not a freeform
      // name/place pair. Until the physical/demo QR codes are regenerated
      // to encode that code directly (tracked in medifit-kb/MEDIFIT_KB.md
      // §7), this treats the QR's "name" field (or the raw scanned string)
      // as a best-effort facility code candidate — the backend replies 404
      // "Unknown facility code" if it doesn't match a real one.
      String gymName = 'Gym';
      String gymPlace = 'Gym Place';
      String facilityCode = qrString.trim();
      try {
        final Map<String, dynamic> qrData = jsonDecode(qrString);
        gymName = qrData['name'] as String? ?? 'Gym';
        gymPlace = qrData['place'] as String? ?? 'Gym Place';
        facilityCode = gymName;
      } catch (_) {
        // Fallback: If not JSON, use the raw QR string itself as gym name
        gymName = qrString;
        if (gymName.startsWith('http://') || gymName.startsWith('https://')) {
          try {
            final uri = Uri.parse(gymName);
            gymName = uri.host;
          } catch (_) {}
        }
      }
      facilityCode = facilityCode.trim().toUpperCase();

      final memberPin = await _promptForMemberPin(gymName);
      if (memberPin == null) return;

      final data = await WorkoutSessionService.instance.checkIn(
        facilityCode: facilityCode,
        memberPin: memberPin,
      );

      await WorkoutSessionService.instance.saveCheckIn(
        session: data,
        fallbackFacilityName: gymName,
        fallbackFacilityPlace: gymPlace,
      );
      // This asks for location only after an actual workout starts. A denied
      // request is optional and simply leaves the hourly confirmation active.
      await WorkoutSessionService.instance.startMonitoring(
        requestLocationPermission: true,
      );

      _scannerController?.dispose();
      _scannerController = null;
      final checkinTimeStr =
          data['check_in_at'] as String? ?? DateTime.now().toIso8601String();
      final checkInTime = DateTime.tryParse(checkinTimeStr) ?? DateTime.now();
      final confirmedGymName = data['facility_name'] as String? ?? gymName;

      setState(() {
        _isCheckedIn = true;
        _gymName = confirmedGymName;
        _gymPlace = gymPlace;
        _checkInTime = checkInTime;
      });

      _startTimer();
      widget.onStatusChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 Workout session started at $confirmedGymName!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on WorkoutSessionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      debugPrint("Error in gym check-in: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to start workout session: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _promptForMemberPin(String facilityName) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MemberPinDialog(facilityName: facilityName),
    );
  }

  /// Returns `true` when checkout succeeded.
  ///
  /// [useGlobalLoading] — full-screen overlay on the gym page.
  /// [popScreenOnSuccess] — pop the gym screen after a successful checkout.
  Future<bool> _handleCheckout({
    bool useGlobalLoading = true,
    bool popScreenOnSuccess = true,
  }) async {
    if (useGlobalLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await WorkoutSessionService.instance.checkout();

      _timer?.cancel();
      setState(() {
        _isCheckedIn = false;
        _gymName = null;
        _gymPlace = null;
        _checkInTime = null;
        _elapsed = Duration.zero;
        _loggedExercises.clear();
      });

      widget.onStatusChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("💪 Workout session completed!"),
            backgroundColor: Colors.green,
          ),
        );
        if (popScreenOnSuccess) Navigator.pop(context);
      }
      return true;
    } on WorkoutSessionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
      return false;
    } catch (e) {
      debugPrint("Error in gym checkout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Checkout error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    } finally {
      if (useGlobalLoading && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// [onChanged] is invoked after an exercise is added so a parent sheet
  /// (e.g. checkout confirmation) can rebuild without being closed.
  void _showAddExerciseSheet({VoidCallback? onChanged}) {
    String? selectedName;
    int sets = 3;
    final customNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Add Exercise Done 🏋️‍♂️",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Choose from popular exercises:",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularExercises.length,
                      itemBuilder: (context, index) {
                        final name = _popularExercises[index];
                        final isSelected = selectedName == name;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedName = name;
                              customNameController.text = "";
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blueAccent.withValues(alpha: 0.15)
                                  : (isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.05)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Or type custom exercise name:",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customNameController,
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        setSheetState(() {
                          selectedName = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "E.g., Pull-ups, Calf Raises",
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.04),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Number of Sets:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: sets > 1
                                ? () => setSheetState(() => sets--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.blueAccent,
                          ),
                          Text(
                            "$sets",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setSheetState(() => sets++),
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final name = customNameController.text.trim().isNotEmpty
                          ? customNameController.text.trim()
                          : selectedName;
                      if (name != null && name.isNotEmpty) {
                        setState(() {
                          _loggedExercises.add({"name": name, "sets": sets});
                        });
                        _saveLoggedExercises();
                        // Notify parent sheet (checkout) so its list refreshes.
                        onChanged?.call();
                        // Only close this add-exercise sheet — leave checkout sheet open.
                        Navigator.pop(sheetContext);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please specify or choose an exercise name!",
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Add to Workout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCheckoutConfirmationSheet() {
    bool isCheckingOut = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Keep sheet under user control; PopScope blocks dismiss while API runs.
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setCheckoutState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return PopScope(
              canPop: !isCheckingOut,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Log Gym Workout & Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          // Keep checkout sheet open; stack add sheet on top.
                          onPressed: isCheckingOut
                              ? null
                              : () {
                                  _showAddExerciseSheet(
                                    onChanged: () {
                                      setCheckoutState(() {});
                                    },
                                  );
                                },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            "Add",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loggedExercises.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "No exercises added. Tap 'Add' to log a workout!",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _loggedExercises.length,
                          itemBuilder: (context, index) {
                            final item = _loggedExercises[index];
                            return Card(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.02),
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${item['sets']} sets",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    onPressed: isCheckingOut
                                        ? null
                                        : () {
                                            setCheckoutState(() {
                                              _loggedExercises.removeAt(index);
                                            });
                                            setState(() {});
                                            _saveLoggedExercises();
                                          },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (isCheckingOut) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Checking out… please wait",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isCheckingOut
                                ? null
                                : () => Navigator.pop(sheetContext),
                            child: const Text("Go Back"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Keep sheet open until checkout API finishes.
                            onPressed: isCheckingOut
                                ? null
                                : () async {
                                    setCheckoutState(() {
                                      isCheckingOut = true;
                                    });

                                    final sheetNav = Navigator.of(sheetContext);
                                    final pageNav = Navigator.of(this.context);

                                    final success = await _handleCheckout(
                                      useGlobalLoading: false,
                                      popScreenOnSuccess: false,
                                    );

                                    if (!mounted) return;

                                    if (success) {
                                      // Close checkout sheet, then leave gym screen.
                                      if (sheetNav.canPop()) {
                                        sheetNav.pop();
                                      }
                                      if (pageNav.canPop()) {
                                        pageNav.pop();
                                      }
                                    } else {
                                      // Stay on sheet so user can retry.
                                      setCheckoutState(() {
                                        isCheckingOut = false;
                                      });
                                    }
                                  },
                            child: Text(
                              isCheckingOut
                                  ? "Checking out…"
                                  : "Checkout & Log",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F0F12)
        : const Color(0xFFF6F8FC);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Gym Check-In 🏋️‍♂️",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -80,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withValues(alpha: isDark ? 0.15 : 0.1),
                    Colors.blue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isCheckedIn) ...[
                      // Header Instruction
                      Text(
                        "Find QR code in your partner gym to check in & start tracking workout duration.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_cameraPermissionGranted) ...[
                        // Camera permission request state
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                size: 60,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  "Camera Access Required",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  "Arcare needs camera permission to scan QR code at the gym.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _requestCameraPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Grant Permission",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // Real Camera Barcode/QR Scanner Feed
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 280,
                            color: Colors.black,
                            child: Stack(
                              children: [
                                if (_cameraPermissionGranted &&
                                    _scannerController != null)
                                  MobileScanner(
                                    controller: _scannerController!,
                                    onDetect: (barcodeCapture) {
                                      if (_isLoading) {
                                        return; // Prevent double scanning while loading
                                      }
                                      final List<Barcode> barcodes =
                                          barcodeCapture.barcodes;
                                      debugPrint(
                                        "Scanned QR Code barcodes found: ${barcodes.length}",
                                      );
                                      for (final barcode in barcodes) {
                                        final rawValue = barcode.rawValue;
                                        debugPrint(
                                          "Scanned QR Code raw value: $rawValue",
                                        );
                                        if (rawValue != null) {
                                          _handleCheckin(rawValue);
                                          break;
                                        }
                                      }
                                    },
                                  ),
                                // Real QR focus overlay visual
                                Center(
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Pulsing scan animation line overlay
                                AnimatedBuilder(
                                  animation: _scannerLinePosition,
                                  builder: (context, child) {
                                    final topPos =
                                        50.0 +
                                        _scannerLinePosition.value * 180.0;
                                    return Positioned(
                                      top: topPos,
                                      left:
                                          (MediaQuery.of(context).size.width -
                                              240) /
                                          2,
                                      width: 180,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.redAccent
                                                  .withValues(alpha: 0.8),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      "Point camera at the Gym QR Code",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(
                              () => _showManualEntry = !_showManualEntry,
                            );
                          },
                          icon: Icon(
                            _showManualEntry
                                ? Icons.expand_less_rounded
                                : Icons.keyboard_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _showManualEntry
                                ? "Hide manual entry"
                                : "Can't scan? Enter code",
                          ),
                        ),
                      ),
                      if (_showManualEntry)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _manualCodeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: "Facility code, e.g. BLR1",
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.04),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onSubmitted: (_) => _submitManualCode(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _submitManualCode,
                                child: const Text("Check In"),
                              ),
                            ],
                          ),
                        ),
                    ] else ...[
                      // Checked In UI
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.greenAccent,
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 48,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "ACTIVE GYM WORKOUT SESSION",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _gymName ?? "Gym",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _gymPlace ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 16),
                            Text(
                              "Workout Duration",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(_elapsed),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Started at ${_checkInTime?.toLocal().toString().substring(11, 16) ?? ''}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Checkout Action
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showCheckoutConfirmationSheet,
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: const Text(
                          "Checkout & Log Workout",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberPinDialog extends StatefulWidget {
  const _MemberPinDialog({required this.facilityName});

  final String facilityName;

  @override
  State<_MemberPinDialog> createState() => _MemberPinDialogState();
}

class _MemberPinDialogState extends State<_MemberPinDialog> {
  final _controller = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (RegExp(r'^\d{4}$').hasMatch(value)) {
      Navigator.pop(context, value);
      return;
    }
    setState(() => _validationError = 'Enter all 4 digits');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter your 4-digit check-in code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the code issued when you became a ${AppBrand.name} member to start your workout at ${widget.facilityName}.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '4-digit code',
              errorText: _validationError,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_validationError != null) {
                setState(() => _validationError = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Start workout')),
      ],
    );
  }
}

class ScannerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final double step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
