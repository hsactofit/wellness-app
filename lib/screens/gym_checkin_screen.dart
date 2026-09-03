import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_brand.dart';
import '../services/camera_permission_gate.dart';
import '../services/facility_access_helpers.dart';
import '../services/facility_booking_service.dart';
import '../services/facility_directions_launcher.dart';
import '../services/facility_rating_service.dart';
import '../services/workout_session_service.dart';
import '../widgets/exercise_video_tile.dart';
import '../widgets/glass_card.dart';
import 'exercise_video_screen.dart';

/// Member-facing facility access surface.
///
/// A booking or an approved instant request is always carried through to the
/// server check-in call. The QR and four-digit member code are still required
/// at the door, so a stale booking/request cannot be used by itself.
class GymCheckinScreen extends StatefulWidget {
  const GymCheckinScreen({super.key, this.onStatusChanged});

  final VoidCallback? onStatusChanged;

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

enum _AccessView { home, facilities, instantFacilities, instantStatus, scanner }

class _GymCheckinScreenState extends State<GymCheckinScreen> {
  final _bookingService = FacilityBookingService.instance;
  final _ratingService = FacilityRatingService.instance;
  final _manualFacilityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _completedItems = <String>{};

  _AccessView _view = _AccessView.home;
  DateTime _selectedDay = DateTime.now();
  FacilityPage? _facilityPage;
  final Map<String, FacilityPage> _facilityCache = {};
  List<MemberBooking> _bookings = const [];
  bool? _workoutDataConsentActive;
  FacilityAccessRequest? _accessRequest;
  EligibleFacility? _instantFacility;
  ActiveWorkoutSession? _session;
  FacilityRatingPrompt? _pendingRating;
  MobileScannerController? _scannerController;
  Timer? _timer;
  Timer? _requestPollTimer;
  Duration _elapsed = Duration.zero;
  int _facilityPageNumber = 1;
  String? _expectedFacilityCode;
  String? _bookingId;
  String? _instantRequestId;
  bool _loading = true;
  bool _actionInProgress = false;
  bool _cameraPermissionGranted = false;
  bool _ratingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WorkoutSessionService.instance.sessionRefreshSignal.addListener(
      _reloadSession,
    );
    _load();
  }

  @override
  void dispose() {
    WorkoutSessionService.instance.sessionRefreshSignal.removeListener(
      _reloadSession,
    );
    _timer?.cancel();
    _requestPollTimer?.cancel();
    _scannerController?.dispose();
    _manualFacilityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    ActiveWorkoutSession? session;
    try {
      session = await WorkoutSessionService.instance.recoverActiveSession();
    } catch (_) {
      // A transient API failure should not hide the local recovery cache or
      // prevent normal facility discovery.
      session = await WorkoutSessionService.instance.loadActiveSession();
    }
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
    if (session != null) {
      _completedItems.clear();
      _startTimer();
      await WorkoutSessionService.instance.startMonitoring(
        requestLocationPermission: true,
      );
    } else {
      await Future.wait([_loadFacilities(), _loadBookings()]);
      await _restorePendingRating(present: true);
    }
  }

  Future<void> _reloadSession() async {
    final session = await WorkoutSessionService.instance.loadActiveSession();
    if (!mounted) return;
    if (session == null && _session != null) {
      setState(() {
        _session = null;
        _view = _AccessView.home;
      });
      _timer?.cancel();
      widget.onStatusChanged?.call();
      return;
    }
    if (session != null && _session == null) {
      setState(() => _session = session);
      _startTimer();
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final page = await _bookingService.fetchFacilities(
        _selectedDay,
        page: _facilityPageNumber,
      );
      if (!mounted) return;
      setState(() {
        _facilityPage = page;
        _facilityCache[facilityDayKey(
              _selectedDay,
              page: _facilityPageNumber,
            )] =
            page;
      });
    } on FacilityBookingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) _showSnack('Could not load facilities.', isError: true);
    }
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _bookingService.myBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (_) {
      // A booking list is supplementary; discovery remains usable offline.
    }
  }

  Future<void> _restorePendingRating({bool present = false}) async {
    try {
      final pending = await _ratingService.pending();
      if (!mounted) return;
      setState(() => _pendingRating = pending);
      if (present && pending != null) await _presentRating(pending);
    } on FacilityRatingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } catch (_) {
      // A temporary offline state must not erase a feedback item the server
      // will re-surface before the next facility mutation.
    }
  }

  Future<bool> _ensureRatingComplete() async {
    if (_pendingRating == null) await _restorePendingRating();
    final pending = _pendingRating;
    if (pending == null) return true;
    await _presentRating(pending);
    return _pendingRating == null;
  }

  Future<void> _presentRating(FacilityRatingPrompt prompt) async {
    if (!mounted || _ratingDialogOpen) return;
    _ratingDialogOpen = true;
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FacilityRatingDialog(prompt: prompt),
    );
    _ratingDialogOpen = false;
    if (!mounted) return;
    if (submitted == true) {
      setState(() => _pendingRating = null);
      _showSnack('Thanks — your facility feedback was submitted.');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final start = _session?.checkInAt;
    if (start == null) return;
    void update() {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(start));
    }

    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 4),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _openFacilities() {
    final today = DateTime.now();
    final cached = _facilityCache[facilityDayKey(today)];
    setState(() {
      _view = _AccessView.facilities;
      _facilityPageNumber = 1;
      _selectedDay = today;
      _facilityPage = cached;
    });
    if (cached == null) {
      _loadFacilities();
    }
  }

  void _openInstant() {
    final cached = _facilityCache[facilityDayKey(_selectedDay)];
    setState(() {
      _view = _AccessView.instantFacilities;
      _facilityPageNumber = 1;
      _facilityPage = cached;
    });
    if (cached == null) {
      _loadFacilities();
    }
  }

  Future<void> _changeDay(DateTime day) async {
    final cached = _facilityCache[facilityDayKey(day)];
    setState(() {
      _selectedDay = day;
      _facilityPageNumber = 1;
      _facilityPage = cached;
    });
    if (cached == null) {
      await _loadFacilities();
    }
  }

  void _changeFacilityPage(int page) {
    final cached = _facilityCache[facilityDayKey(_selectedDay, page: page)];
    setState(() {
      _facilityPageNumber = page;
      _facilityPage = cached;
    });
    if (cached == null) {
      _loadFacilities();
    }
  }

  void _goBackFromSubView() {
    _requestPollTimer?.cancel();
    _scannerController?.dispose();
    _scannerController = null;
    setState(() {
      _view = _AccessView.home;
      _cameraPermissionGranted = false;
    });
    unawaited(_loadBookings());
  }

  Future<bool> _ensureWorkoutDataConsent({required String action}) async {
    try {
      if (_workoutDataConsentActive == true) return true;
      if ((await _bookingService.fetchWorkoutDataConsent()).active) {
        _workoutDataConsentActive = true;
        return true;
      }
      if (!mounted) return false;
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Facility workout-data sharing'),
          content: Text(
            'To $action, approve sharing your identity, facility attendance, facility workout report, and facility feedback with your assigned facility manager and your organisation’s corporate admin. Medical history, raw OCR, unrelated vitals, and workouts at unrelated facilities are never shared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Approve'),
            ),
          ],
        ),
      );
      if (approved != true) {
        _showSnack(
          'Booking and check-in cannot continue because the facility workflow requires workout-data access.',
          isError: true,
        );
        return false;
      }
      await _bookingService.setWorkoutDataConsent(granted: true);
      _workoutDataConsentActive = true;
      return true;
    } on FacilityBookingException catch (error) {
      _showSnack(error.message, isError: true);
      return false;
    } catch (_) {
      _showSnack(
        'Could not update the facility privacy setting.',
        isError: true,
      );
      return false;
    }
  }

  Future<void> _bookSlot(EligibleFacility facility, FacilitySlot slot) async {
    if (slot.remaining <= 0 || slot.isStarted) return;
    final existing = bookingOnDay(_bookings, _selectedDay);
    if (existing != null) {
      await _showAlreadyBookedDialog(existing);
      return;
    }
    if (!await _ensureRatingComplete()) return;
    if (!await _ensureWorkoutDataConsent(action: 'book this slot')) return;
    setState(() => _actionInProgress = true);
    try {
      final booking = await _bookingService.bookSlot(slot.id);
      if (!mounted) return;
      _facilityCache.remove(
        facilityDayKey(_selectedDay, page: _facilityPageNumber),
      );
      setState(() {
        _actionInProgress = false;
        _bookings = [
          booking,
          ..._bookings.where((item) => item.id != booking.id),
        ];
      });
      _showSnack('Slot booked at ${booking.facilityName}.');
      await _showBookingConfirmation(booking);
      unawaited(_loadFacilities());
      unawaited(_loadBookings());
    } on FacilityBookingException catch (error) {
      if (!mounted) return;
      setState(() => _actionInProgress = false);
      if (isAlreadyBookedMessage(error.message)) {
        await _showAlreadyBookedDialog(bookingOnDay(_bookings, _selectedDay));
      } else {
        _showSnack(error.message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _actionInProgress = false);
        _showSnack('Could not book this slot.', isError: true);
      }
    }
  }

  Future<void> _showAlreadyBookedDialog(MemberBooking? booking) async {
    if (!mounted) return;
    final details = booking == null
        ? 'You already have a facility booking on this day. Only one slot can be reserved per day.'
        : 'You already booked ${booking.facilityName} at ${_formatSlot(booking.slot)}. Cancel that booking first if you want a different slot.';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('You already have a booking on this day'),
        content: Text(details),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookingConfirmation(MemberBooking booking) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Slot booked'),
        content: Text(
          '${booking.facilityName}\n${_formatSlot(booking.slot)}\n\nScan the facility QR at the door during this hour to start your workout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _startBookedCheckin(booking);
            },
            child: const Text('Check in now'),
          ),
        ],
      ),
    );
  }

  void _startBookedCheckin(MemberBooking booking) {
    _bookingId = booking.id;
    _instantRequestId = null;
    _expectedFacilityCode = booking.facilityCode;
    _openScanner();
  }

  Future<void> _showSlotPicker(EligibleFacility facility) async {
    final selected = await showModalBottomSheet<FacilitySlot>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(_formatDate(_selectedDay)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: facility.slots
                      .map(
                        (slot) => ListTile(
                          leading: Icon(
                            slot.remaining > 0 ? Icons.schedule : Icons.block,
                            color: slot.remaining > 0
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(_formatSlot(slot)),
                          subtitle: Text(
                            slot.remaining > 0
                                ? '${slot.remaining} places left'
                                : 'Full',
                          ),
                          enabled: slot.remaining > 0 && !slot.isStarted,
                          onTap: () => Navigator.pop(sheetContext, slot),
                        ),
                      )
                      .toList(),
                ),
              ),
              if (facility.slots.isEmpty ||
                  facility.slots.every((slot) => slot.remaining == 0))
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_alert_outlined),
                    label: const Text('Request a place'),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _requestCapacity(facility);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) await _bookSlot(facility, selected);
  }

  Future<void> _requestCapacity(EligibleFacility facility) async {
    if (!await _ensureRatingComplete()) return;
    if (!await _ensureWorkoutDataConsent(
      action: 'request a capacity override',
    )) {
      return;
    }
    setState(() => _actionInProgress = true);
    try {
      final request = await _bookingService.requestCapacity(
        facility.id,
        requestedFor: _selectedDay,
        reason: 'All displayed slots are full',
      );
      if (!mounted) return;
      setState(() {
        _accessRequest = request;
        _instantFacility = facility;
        _instantRequestId = request.id;
        _view = _AccessView.instantStatus;
      });
      _startRequestPolling();
    } on FacilityBookingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _requestInstant(EligibleFacility facility) async {
    if (!await _ensureRatingComplete()) return;
    if (!await _ensureWorkoutDataConsent(action: 'request instant check-in')) {
      return;
    }
    setState(() {
      _actionInProgress = true;
      _instantFacility = facility;
    });
    try {
      final request = await _bookingService.requestInstant(
        facility.id,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _accessRequest = request;
        _instantRequestId = request.id;
        _view = _AccessView.instantStatus;
      });
      _startRequestPolling();
    } on FacilityBookingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  void _startRequestPolling() {
    _requestPollTimer?.cancel();
    _requestPollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final requestId = _instantRequestId;
      if (requestId == null) return;
      try {
        final request = await _bookingService.requestStatus(requestId);
        if (!mounted) return;
        setState(() => _accessRequest = request);
        if (request.approved) {
          _requestPollTimer?.cancel();
          if (request.requestType == 'instant_checkin') {
            _expectedFacilityCode = _instantFacility?.code;
            _openScanner();
          } else if (request.requestType == 'capacity_override') {
            _showSnack(
              'The facility manager granted an extra place. Open the scanner when you arrive.',
            );
          }
        } else if (request.rejected || request.expired) {
          _requestPollTimer?.cancel();
        }
      } on FacilityBookingException catch (error) {
        if (error.statusCode == 410) {
          _requestPollTimer?.cancel();
          if (mounted) {
            _showSnack('This facility request has expired.', isError: true);
          }
        }
      } catch (_) {
        // Keep polling; transient connectivity should not lose a pending ID.
      }
    });
  }

  Future<void> _raiseIssue() async {
    final requestId = _instantRequestId;
    if (requestId == null) return;
    setState(() => _actionInProgress = true);
    try {
      final issue = await _bookingService.raiseIssue(
        requestId,
        reason: _reasonController.text.trim().isEmpty
            ? 'I need help booking a facility slot.'
            : _reasonController.text.trim(),
      );
      if (mounted) {
        _showSnack(
          issue.resolvedByName == null
              ? 'Issue raised to the facility manager.'
              : 'Issue assigned to ${issue.resolvedByName}.',
        );
        setState(() => _view = _AccessView.home);
      }
    } on FacilityBookingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _acceptSuggestion() async {
    final requestId = _instantRequestId;
    if (requestId == null || _accessRequest?.suggestedSlotId == null) return;
    if (!await _ensureRatingComplete()) return;
    if (!await _ensureWorkoutDataConsent(
      action: 'accept this suggested slot',
    )) {
      return;
    }
    setState(() => _actionInProgress = true);
    try {
      final booking = await _bookingService.acceptSuggestion(requestId);
      if (!mounted) return;
      setState(() {
        _bookings = [
          booking,
          ..._bookings.where((item) => item.id != booking.id),
        ];
      });
      _showSnack('Suggested slot booked at ${booking.facilityName}.');
      _startBookedCheckin(booking);
      unawaited(_loadBookings());
    } on FacilityBookingException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _startApprovedCapacityCheckin() async {
    final request = _accessRequest;
    if (request == null || request.requestType != 'capacity_override') return;
    await _loadBookings();
    if (!mounted) return;
    final booking = _bookings.where((candidate) {
      if (candidate.facilityId != request.facilityId) return false;
      if (request.slotId != null && candidate.slot.id != request.slotId) {
        return false;
      }
      return candidate.status == 'booked';
    }).firstOrNull;
    if (booking == null) {
      _showSnack(
        'The granted place is not ready yet. Please refresh your bookings.',
        isError: true,
      );
      return;
    }
    _startBookedCheckin(booking);
  }

  Future<void> _openMaps(EligibleFacility facility) async {
    final result = await FacilityDirectionsLauncher(
      launch: (uri, {required mode}) => launchUrl(uri, mode: mode),
    ).open(facility.mapsUrl);
    if (result == DirectionsLaunchResult.unavailable && mounted) {
      _showSnack('Directions could not be opened.', isError: true);
    }
  }

  Future<void> _openScanner() async {
    final gate = CameraPermissionGate();
    final result = await gate.ensure();
    if (!mounted) return;
    if (result != CameraPermissionResult.granted) {
      _showSnack(
        result == CameraPermissionResult.permanentlyDenied
            ? 'Camera access is required to scan the facility QR. Enable it in Settings.'
            : 'Camera access is required to scan the facility QR.',
        isError: true,
      );
      if (result == CameraPermissionResult.permanentlyDenied) {
        await gate.openSettings();
      }
      return;
    }
    _scannerController?.dispose();
    setState(() {
      _cameraPermissionGranted = true;
      _scannerController = MobileScannerController();
      _view = _AccessView.scanner;
    });
  }

  Future<void> _handleQr(String rawValue) async {
    if (_actionInProgress) return;
    String code = rawValue.trim();
    try {
      final parsed = jsonDecode(rawValue);
      if (parsed is Map) {
        code =
            (parsed['code'] ??
                    parsed['facility_code'] ??
                    parsed['name'] ??
                    code)
                .toString();
      }
    } catch (_) {
      // Raw facility codes are supported for regenerated demo stickers.
    }
    if (_expectedFacilityCode != null &&
        code.toUpperCase() != _expectedFacilityCode!.toUpperCase()) {
      _showSnack('This QR belongs to another facility.', isError: true);
      return;
    }
    if (!await _ensureRatingComplete()) return;
    if (!await _ensureWorkoutDataConsent(action: 'check in')) return;
    _scannerController?.stop();
    if (!mounted) return;
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _MemberPinDialog(
        facilityName: _instantFacility?.name ?? 'your facility',
      ),
    );
    if (pin == null || !mounted) {
      if (mounted) _scannerController?.start();
      return;
    }
    setState(() => _actionInProgress = true);
    try {
      final session = await WorkoutSessionService.instance.checkIn(
        facilityCode: _expectedFacilityCode ?? code,
        memberPin: pin,
        bookingId: _bookingId,
        instantRequestId: _instantRequestId,
      );
      await WorkoutSessionService.instance.saveCheckIn(
        session: session,
        fallbackFacilityName: _instantFacility?.name ?? 'Facility',
        fallbackFacilityPlace: _instantFacility?.address ?? '',
      );
      // Start slot/hourly prompts and contextual location handling as soon as
      // the server confirms check-in; waiting for a future app resume leaves
      // a newly started workout without its reminder schedule.
      await WorkoutSessionService.instance.startMonitoring(
        requestLocationPermission: true,
      );
      final active = await WorkoutSessionService.instance.loadActiveSession();
      if (!mounted) return;
      setState(() {
        _session = active;
        _view = _AccessView.home;
        _bookingId = null;
        _instantRequestId = null;
        _accessRequest = null;
      });
      _startTimer();
      widget.onStatusChanged?.call();
      _showSnack('Workout started. Your timer is running.');
    } on WorkoutSessionException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
      _scannerController?.start();
    } catch (_) {
      if (mounted) _showSnack('Could not start the workout.', isError: true);
      _scannerController?.start();
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _submitManualCode() async {
    final code = _manualFacilityController.text.trim();
    if (code.isEmpty) {
      _showSnack('Enter the facility code first.', isError: true);
      return;
    }
    _expectedFacilityCode = code;
    await _openScanner();
  }

  Future<void> _checkout() async {
    if (_session == null || _actionInProgress) return;
    setState(() => _actionInProgress = true);
    try {
      final result = await WorkoutSessionService.instance.checkout(
        completedItemIds: _completedItems.toList(),
      );
      if (!mounted) return;
      setState(() {
        _session = null;
        _view = _AccessView.home;
        _elapsed = Duration.zero;
        _completedItems.clear();
      });
      _timer?.cancel();
      widget.onStatusChanged?.call();
      _showSnack('Checked out at ${_formatTime(result.checkOutAt)}.');
      await _loadFacilities();
      await _loadBookings();
      if (!mounted) return;
      if (result.ratingRequest != null) {
        setState(() => _pendingRating = result.ratingRequest);
        await _presentRating(result.ratingRequest!);
      }
    } on WorkoutSessionException catch (error) {
      if (mounted) _showSnack(error.message, isError: true);
    } catch (_) {
      if (mounted) _showSnack('Could not complete checkout.', isError: true);
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _showCheckoutDialog() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish workout?'),
        content: Text(
          _completedItems.isEmpty
              ? 'No exercises are selected. You can still check out.'
              : '${_completedItems.length} exercise(s) selected. You can still check out if the checklist is incomplete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep working'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Check out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _checkout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return PopScope(
      canPop: _view == _AccessView.home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBackFromSubView();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session == null ? 'Gym access' : 'Active workout'),
          leading: _view == _AccessView.home
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBackFromSubView,
                ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SafeArea(
                    child: _session != null
                        ? _buildActiveWorkout(isDark)
                        : _buildAccessView(isDark),
                  ),
                  if (_actionInProgress)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x55000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildAccessView(bool isDark) {
    switch (_view) {
      case _AccessView.facilities:
        return _buildFacilityList(isDark, instant: false);
      case _AccessView.instantFacilities:
        return _buildFacilityList(isDark, instant: true);
      case _AccessView.instantStatus:
        return _buildInstantStatus(isDark);
      case _AccessView.scanner:
        return _buildScanner(isDark);
      case _AccessView.home:
        return _buildAccessHome(isDark);
    }
  }

  Widget _buildAccessHome(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Start a facility workout',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Reserve a one-hour slot in advance, or ask the facility manager for an instant check-in.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _accessChoice(
            icon: Icons.event_available_outlined,
            title: 'Book a Slot',
            subtitle: 'Choose a facility and hourly availability',
            onTap: _openFacilities,
            color: Colors.indigoAccent,
          ),
          _accessChoice(
            icon: Icons.flash_on_outlined,
            title: 'Instant Check-in',
            subtitle: 'Request approval from the facility manager',
            onTap: _openInstant,
            color: Colors.orangeAccent,
          ),
          if (upcomingBookings(_bookings).isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'My upcoming bookings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            ...upcomingBookings(_bookings).take(5).map(_bookingCard),
          ],
        ],
      ),
    );
  }

  Widget _accessChoice({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.16),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFacilityList(bool isDark, {required bool instant}) {
    final page = _facilityPage;
    final multi = page?.items.any((item) => item.multiFacility) == true;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                instant ? 'Choose a facility' : 'Choose a facility and slot',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (!instant) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final day = DateTime.now().add(Duration(days: index));
                      final selected = _sameDay(day, _selectedDay);
                      return ChoiceChip(
                        selected: selected,
                        label: Text(index == 0 ? 'Today' : _shortDate(day)),
                        onSelected: (_) => _changeDay(day),
                      );
                    },
                  ),
                ),
              ],
              if (instant) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    hintText: 'I forgot to book a slot',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (multi && !instant)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Facilities are ordered by your preference, recommendations, and visits.',
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: page == null
              ? const Center(child: CircularProgressIndicator())
              : page.items.isEmpty
              ? const Center(
                  child: Text('No facilities are linked to your organisation.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: page.items.length,
                  itemBuilder: (context, index) => _facilityCard(
                    page.items[index],
                    instant: instant,
                    isDark: isDark,
                  ),
                ),
        ),
        if (page != null && (page.hasNext || page.page > 1))
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${page.page} of ${(page.total / 10).ceil().clamp(1, 999)}',
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous page',
                      onPressed: page.page > 1
                          ? () => _changeFacilityPage(page.page - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: 'Next page',
                      onPressed: page.hasNext
                          ? () => _changeFacilityPage(page.page + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _facilityCard(
    EligibleFacility facility, {
    required bool instant,
    required bool isDark,
  }) {
    final badges = <Widget>[];
    if (facility.multiFacility && facility.previouslyVisited) {
      badges.add(const Chip(label: Text('Previously visited')));
    }
    if (facility.multiFacility && facility.recommended) {
      badges.add(const Chip(label: Text('Recommended')));
    }
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      facility.address ?? '${facility.city} · ${facility.code}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Route in Google Maps',
                onPressed: () => _openMaps(facility),
                icon: const Icon(Icons.directions_outlined),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(spacing: 6, runSpacing: 2, children: badges),
          ],
          const SizedBox(height: 10),
          Text(
            instant
                ? 'Ask the manager for a one-time approval.'
                : facility.bookingClosed
                ? 'Bookings for today have closed at 10:00 PM. Choose tomorrow to reserve a slot.'
                : '${facility.availableSlots} places left across ${facility.slots.length} hourly slots',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: instant
                  ? () => _requestInstant(facility)
                  : facility.bookingClosed
                  ? () =>
                        _changeDay(DateTime.now().add(const Duration(days: 1)))
                  : () => _showSlotPicker(facility),
              icon: Icon(
                instant
                    ? Icons.flash_on
                    : facility.bookingClosed
                    ? Icons.calendar_today_outlined
                    : Icons.event_available,
              ),
              label: Text(
                instant
                    ? 'Request instant check-in'
                    : facility.bookingClosed
                    ? "View tomorrow's slots"
                    : 'View hourly slots',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(MemberBooking booking) {
    return Card(
      child: ListTile(
        title: Text(
          booking.facilityName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${_formatSlot(booking.slot)} · ${booking.status}'),
        trailing: booking.status == 'booked'
            ? IconButton(
                tooltip: 'Check in',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () => _startBookedCheckin(booking),
              )
            : null,
      ),
    );
  }

  Widget _buildInstantStatus(bool isDark) {
    final request = _accessRequest;
    if (request == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final pending = request.status == 'pending';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            pending
                ? Icons.hourglass_top
                : request.approved
                ? Icons.check_circle
                : Icons.info_outline,
            size: 64,
            color: pending
                ? Colors.orange
                : request.approved
                ? Colors.green
                : Colors.redAccent,
          ),
          const SizedBox(height: 14),
          Text(
            pending
                ? 'Waiting for ${request.facilityName}'
                : request.approved
                ? 'Request approved'
                : request.status == 'expired'
                ? 'Request expired'
                : 'Request denied',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            pending
                ? 'The facility manager has up to 15 minutes to approve this request.'
                : request.approved
                ? 'Scan the facility QR and enter your member code to begin.'
                : request.resolutionNote ??
                      'Choose an available slot or ask the manager for help.',
            textAlign: TextAlign.center,
          ),
          if (request.approved) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: request.requestType == 'capacity_override'
                  ? _startApprovedCapacityCheckin
                  : _openScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                request.requestType == 'capacity_override'
                    ? 'Scan granted slot at the facility'
                    : 'Scan facility QR',
              ),
            ),
          ],
          if (!pending && !request.approved) ...[
            const SizedBox(height: 20),
            if (request.suggestedSlotId != null)
              FilledButton.icon(
                onPressed: _acceptSuggestion,
                icon: const Icon(Icons.event_available),
                label: const Text('Book suggested slot'),
              ),
            OutlinedButton.icon(
              onPressed: _raiseIssue,
              icon: const Icon(Icons.support_agent),
              label: const Text('Raise booking issue'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanner(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scan facility QR',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the QR displayed at the facility entrance. The member code is required next.',
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 310,
              child: _cameraPermissionGranted && _scannerController != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _scannerController!,
                          onDetect: (capture) {
                            for (final barcode in capture.barcodes) {
                              final value = barcode.rawValue;
                              if (value != null && value.isNotEmpty) {
                                _handleQr(value);
                                break;
                              }
                            }
                          },
                        ),
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'Camera permission required',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text('Can’t scan the sticker? Enter the facility code.'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualFacilityController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Facility code',
                    hintText: 'BLR1',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _submitManualCode,
                child: const Text('Use code'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkout(bool isDark) {
    final session = _session!;
    final plan = session.planSnapshot;
    final videoPlan = exercisesWithDemonstrationVideos(plan);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(
                  session.facilityName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (session.facilityPlace.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.facilityPlace,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 10),
                Chip(
                  label: Text(
                    session.instantRequestId != null
                        ? 'Instant check-in'
                        : 'Booked slot',
                  ),
                  avatar: Icon(
                    session.instantRequestId != null
                        ? Icons.flash_on
                        : Icons.event_available,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'WORKOUT DURATION',
                  style: TextStyle(
                    letterSpacing: 1.1,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDuration(_elapsed),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Started ${_formatTime(session.checkInAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Today's workout plan",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (plan.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No workout assigned today. You can still check out when you finish.',
                ),
              ),
            )
          else
            ...plan.map(_planItem),
          if (videoPlan.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Exercise videos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...videoPlan.map(_videoItem),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _showCheckoutDialog,
            icon: const Icon(Icons.logout),
            label: const Text('Checkout'),
          ),
        ],
      ),
    );
  }

  Widget _planItem(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? item['name']?.toString() ?? 'exercise';
    final name = item['name']?.toString() ?? 'Exercise';
    final details = exerciseDetails(item);
    return Card(
      child: CheckboxListTile(
        value: _completedItems.contains(id),
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _completedItems.add(id);
            } else {
              _completedItems.remove(id);
            }
          });
        },
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: details.isEmpty ? null : Text(details),
      ),
    );
  }

  Widget _videoItem(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Exercise';
    final videoId = exerciseVideoId(item)!;
    return ExerciseVideoTile(
      name: name,
      details: exerciseDetails(item),
      onOpen: () => _openExerciseVideo(name, videoId),
    );
  }

  Future<void> _openExerciseVideo(String name, String videoId) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ExerciseVideoScreen(exerciseName: name, videoId: videoId),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDate(DateTime day) => '${day.day}/${day.month}/${day.year}';

  String _shortDate(DateTime day) =>
      '${_weekday(day.weekday)} ${day.day}/${day.month}';

  String _weekday(int day) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];

  String _formatSlot(FacilitySlot slot) =>
      '${_formatTime(slot.startsAt)} – ${_formatTime(slot.endsAt)}';

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MemberPinDialog extends StatefulWidget {
  const _MemberPinDialog({required this.facilityName});

  final String facilityName;

  @override
  State<_MemberPinDialog> createState() => _MemberPinDialogState();
}

class _FacilityRatingDialog extends StatefulWidget {
  const _FacilityRatingDialog({required this.prompt});

  final FacilityRatingPrompt prompt;

  @override
  State<_FacilityRatingDialog> createState() => _FacilityRatingDialogState();
}

class _FacilityRatingDialogState extends State<_FacilityRatingDialog> {
  final _commentController = TextEditingController();
  int _overall = 0;
  int _service = 0;
  int _cleanliness = 0;
  int _equipment = 0;
  int _amenities = 0;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _complete =>
      _overall > 0 &&
      _service > 0 &&
      _cleanliness > 0 &&
      _equipment > 0 &&
      _amenities > 0 &&
      _commentController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_complete) {
      setState(
        () => _error =
            'Rate every area and add a short comment before submitting.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await FacilityRatingService.instance.submit(
        widget.prompt,
        overallRating: _overall,
        serviceRating: _service,
        cleanlinessRating: _cleanliness,
        equipmentRating: _equipment,
        amenitiesRating: _amenities,
        comment: _commentController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on FacilityRatingException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not submit feedback. Try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _ratingRow(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          ...List.generate(
            5,
            (index) => IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: '${index + 1} of 5',
              onPressed: _submitting
                  ? null
                  : () => setState(() => onChanged(index + 1)),
              icon: Icon(
                index < value ? Icons.star_rounded : Icons.star_border_rounded,
                color: index < value ? Colors.amber.shade800 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate ${widget.prompt.facilityName}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your first completed visit helps your organisation understand the facility experience.',
              ),
              const SizedBox(height: 12),
              _ratingRow(
                'Overall experience',
                _overall,
                (value) => _overall = value,
              ),
              _ratingRow(
                'Staff and service',
                _service,
                (value) => _service = value,
              ),
              _ratingRow(
                'Cleanliness',
                _cleanliness,
                (value) => _cleanliness = value,
              ),
              _ratingRow(
                'Equipment and resources',
                _equipment,
                (value) => _equipment = value,
              ),
              _ratingRow(
                'Amenities and comfort',
                _amenities,
                (value) => _amenities = value,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                enabled: !_submitting,
                minLines: 2,
                maxLines: 5,
                maxLength: 500,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  hintText: 'Tell us what worked well or could improve.',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text('Rate later'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit rating'),
        ),
      ],
    );
  }
}

class _MemberPinDialogState extends State<_MemberPinDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (RegExp(r'^\d{4}$').hasMatch(value)) {
      Navigator.pop(context, value);
    } else {
      setState(() => _error = 'Enter all 4 digits');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter member code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the four-digit code issued for your ${AppBrand.name} membership at ${widget.facilityName}.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 4,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '4-digit code',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
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
