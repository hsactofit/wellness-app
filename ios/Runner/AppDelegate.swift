import ActivityKit
import CoreLocation
import Flutter
import HealthKit
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate {
  private var productURLScheme: String {
    Bundle.main.object(forInfoDictionaryKey: "ProductURLScheme") as? String ?? "medifit"
  }
  private static let channelName = "com.medifit/workout_background"
  private static let healthAccessChannelName = "com.medifit/health_access"
  private static let hourlyNotificationCategory = "MEDIFIT_WORKOUT_HOURLY_PROMPT"
  private static let departureNotificationCategory = "MEDIFIT_WORKOUT_DEPARTURE_PROMPT"
  private static let slotEndNotificationCategory = "MEDIFIT_WORKOUT_SLOT_END_PROMPT"
  private static let checkoutAction = "MEDIFIT_WORKOUT_CHECKOUT"
  private static let continueAction = "MEDIFIT_WORKOUT_CONTINUE"

  private var workoutChannel: FlutterMethodChannel?
  private var healthAccessChannel: FlutterMethodChannel?
  private var dartReady = false
  private var pendingEvents: [String] = []
  private let locationManager = CLLocationManager()
  private var pendingRegion: CLCircularRegion?
  private var activeSessionId: String?
  private var activeFacilityName = "your facility"
  private var activeCheckInAt: Date?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    locationManager.delegate = self
    configureWorkoutNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WorkoutBackgroundBridge") else {
      return
    }
    workoutChannel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: registrar.messenger()
    )
    workoutChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleWorkoutMethod(call, result: result)
    }
    healthAccessChannel = FlutterMethodChannel(
      name: Self.healthAccessChannelName,
      binaryMessenger: registrar.messenger()
    )
    healthAccessChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleHealthAccessMethod(call, result: result)
    }
  }

  // MARK: - Apple Health access recovery

  /// HealthKit shows its permission sheet only while at least one requested
  /// type is still undecided, and it never reveals denied read access. This
  /// bridge lets Flutter ask iOS whether another request would actually show
  /// the sheet, and otherwise jump straight to the Health app, which is the
  /// only place a person can change a decision they already made.
  private func handleHealthAccessMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "authorizationRequestStatus":
      let values = call.arguments as? [String: Any] ?? [:]
      let readNames = values["read"] as? [String] ?? []
      let writeNames = values["write"] as? [String] ?? []
      healthAuthorizationRequestStatus(readNames: readNames, writeNames: writeNames, result: result)
    case "openHealthApp":
      guard let url = URL(string: "x-apple-health://") else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func healthAuthorizationRequestStatus(
    readNames: [String],
    writeNames: [String],
    result: @escaping FlutterResult
  ) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result("unavailable")
      return
    }
    let read = Set(readNames.flatMap(Self.healthObjectTypes(forDartType:)))
    let share = Set(
      writeNames.flatMap(Self.healthObjectTypes(forDartType:)).compactMap { $0 as? HKSampleType }
    )
    guard !read.isEmpty || !share.isEmpty else {
      result("unknown")
      return
    }
    HKHealthStore().getRequestStatusForAuthorization(toShare: share, read: read) { status, error in
      if let error {
        NSLog("Health authorization status failed: %@", error.localizedDescription)
        DispatchQueue.main.async { result("unknown") }
        return
      }
      DispatchQueue.main.async {
        switch status {
        case .shouldRequest:
          result("shouldRequest")
        case .unnecessary:
          result("unnecessary")
        case .unknown:
          result("unknown")
        @unknown default:
          result("unknown")
        }
      }
    }
  }

  /// Translates the Dart `HealthDataType` names that `HealthService` requests
  /// into the HealthKit types the `health` plugin asks for. Names that are not
  /// listed here are skipped, so this can only under-report, never claim a
  /// type the plugin does not request.
  private static func healthObjectTypes(forDartType name: String) -> [HKObjectType] {
    func quantity(_ identifier: HKQuantityTypeIdentifier) -> [HKObjectType] {
      HKObjectType.quantityType(forIdentifier: identifier).map { [$0] } ?? []
    }
    func category(_ identifier: HKCategoryTypeIdentifier) -> [HKObjectType] {
      HKObjectType.categoryType(forIdentifier: identifier).map { [$0] } ?? []
    }
    switch name {
    case "STEPS": return quantity(.stepCount)
    case "DISTANCE_WALKING_RUNNING": return quantity(.distanceWalkingRunning)
    case "ACTIVE_ENERGY_BURNED": return quantity(.activeEnergyBurned)
    case "BASAL_ENERGY_BURNED": return quantity(.basalEnergyBurned)
    case "HEART_RATE": return quantity(.heartRate)
    case "RESTING_HEART_RATE": return quantity(.restingHeartRate)
    case "SLEEP_ASLEEP": return category(.sleepAnalysis)
    case "WEIGHT": return quantity(.bodyMass)
    case "BODY_MASS_INDEX": return quantity(.bodyMassIndex)
    case "BODY_FAT_PERCENTAGE": return quantity(.bodyFatPercentage)
    case "BLOOD_PRESSURE_SYSTOLIC": return quantity(.bloodPressureSystolic)
    case "BLOOD_PRESSURE_DIASTOLIC": return quantity(.bloodPressureDiastolic)
    case "BLOOD_GLUCOSE": return quantity(.bloodGlucose)
    case "BLOOD_OXYGEN": return quantity(.oxygenSaturation)
    case "WATER": return quantity(.dietaryWater)
    case "WORKOUT": return [HKObjectType.workoutType()]
    case "MINDFULNESS": return category(.mindfulSession)
    case "ELECTROCARDIOGRAM":
      return [HKObjectType.electrocardiogramType()]
    case "HIGH_HEART_RATE_EVENT": return category(.highHeartRateEvent)
    case "LOW_HEART_RATE_EVENT": return category(.lowHeartRateEvent)
    case "IRREGULAR_HEART_RATE_EVENT": return category(.irregularHeartRhythmEvent)
    case "NUTRITION":
      return quantity(.dietaryEnergyConsumed) + quantity(.dietaryProtein)
        + quantity(.dietaryCarbohydrates) + quantity(.dietaryFatTotal)
    default:
      return []
    }
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleWorkoutURL(url) { return true }
    return super.application(app, open: url, options: options)
  }

  /// Shared by UIApplication and the scene delegate because current Flutter
  /// iOS apps route warm URL opens through UISceneDelegate.
  func handleWorkoutURL(_ url: URL) -> Bool {
    guard url.scheme == productURLScheme, url.host == "workout", url.path == "/checkout" else {
      return false
    }
    emitToFlutter("checkoutRequested")
    return true
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let category = response.notification.request.content.categoryIdentifier
    guard [Self.hourlyNotificationCategory, Self.departureNotificationCategory, Self.slotEndNotificationCategory].contains(category) else {
      super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
      return
    }
    switch response.actionIdentifier {
    case Self.checkoutAction, UNNotificationDefaultActionIdentifier:
      emitToFlutter("checkoutRequested")
    case Self.continueAction:
      if category == Self.slotEndNotificationCategory {
        emitToFlutter("slotEndContinueRequested")
      } else {
        emitToFlutter("continueRequested")
        scheduleHourlyPrompt(after: Date().addingTimeInterval(60 * 60))
      }
    default:
      break
    }
    completionHandler()
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways, let region = pendingRegion {
      manager.startMonitoring(for: region)
    }
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    guard region.identifier == "medifit.workout.\(activeSessionId ?? UserDefaults.standard.string(forKey: "medifit.workout.session") ?? "")" else { return }
    emitToFlutter("departureCheckoutRequired")
    scheduleDeparturePrompt()
  }

  private func handleWorkoutMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ready":
      dartReady = true
      flushPendingEvents()
      result(nil)
    case "start":
      let values = call.arguments as? [String: Any] ?? [:]
      startWorkoutSurface(values)
      result(false)
    case "armScannerOrigin":
      let values = call.arguments as? [String: Any] ?? [:]
      result(armScannerOrigin(values))
    case "showTimer":
      result(showWorkoutTimer(call.arguments as? [String: Any] ?? [:]))
    case "hideTimer":
      hideWorkoutTimer()
      result(nil)
    case "stop":
      stopWorkoutSurface()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startWorkoutSurface(_ values: [String: Any]) {
    let sessionId = values["sessionId"] as? String ?? ""
    guard !sessionId.isEmpty else { return }
    activeSessionId = sessionId
    activeFacilityName = values["facilityName"] as? String ?? "your facility"
    let checkInMilliseconds = values["checkInAt"] as? NSNumber
    let checkInAt = Date(timeIntervalSince1970: (checkInMilliseconds?.doubleValue ?? Date().timeIntervalSince1970 * 1000) / 1000)
    activeCheckInAt = checkInAt
    UserDefaults.standard.set(sessionId, forKey: "medifit.workout.session")
    let slotEndMilliseconds = values["slotEndAt"] as? NSNumber
    let slotEndAt = slotEndMilliseconds.map { Date(timeIntervalSince1970: $0.doubleValue / 1000) }

    requestNotificationPermission()
    let firstHourly = checkInAt.addingTimeInterval(60 * 60)
    scheduleHourlyPrompt(after: firstHourly)
    if let slotEndAt,
       abs(slotEndAt.timeIntervalSince(firstHourly)) > 10 * 60,
       slotEndAt > Date() {
      scheduleSlotEndPrompt(at: slotEndAt)
    }
    // A Live Activity must be started while the app is foregrounded. It stays
    // active even while the in-app workout view is visible, so it is ready
    // when the member returns to the Home or Lock Screen.
    _ = showWorkoutTimer(values)

  }

  /// The scanner-origin coordinate arrives only after QR/PIN check-in and is
  /// stored by Core Location, not sent to Flutter's server API. A device that
  /// cannot monitor the full 2 km region returns false so Flutter can retain
  /// its foreground-only fallback without silently shrinking the threshold.
  private func armScannerOrigin(_ values: [String: Any]) -> Bool {
    let sessionId = values["sessionId"] as? String ?? ""
    guard !sessionId.isEmpty,
          sessionId == activeSessionId || sessionId == UserDefaults.standard.string(forKey: "medifit.workout.session"),
          let latitude = values["latitude"] as? Double,
          let longitude = values["longitude"] as? Double,
          CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self),
          locationManager.maximumRegionMonitoringDistance >= 2000 else { return false }
    let region = CLCircularRegion(
      center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
      radius: 2000,
      identifier: "medifit.workout.\(sessionId)"
    )
    region.notifyOnEntry = false
    region.notifyOnExit = true
    pendingRegion = region
    switch locationManager.authorizationStatus {
    case .authorizedAlways:
      locationManager.startMonitoring(for: region)
    case .notDetermined, .authorizedWhenInUse:
      // This is shown only during a confirmed check-in and never blocks a
      // manual checkout. The region itself is the only background location
      // primitive registered; no continuous coordinates are retained.
      locationManager.requestAlwaysAuthorization()
    case .denied, .restricted:
      return false
    @unknown default:
      return false
    }
    return true
  }

  private func stopWorkoutSurface() {
    for region in locationManager.monitoredRegions where region.identifier.hasPrefix("medifit.workout.") {
      locationManager.stopMonitoring(for: region)
    }
    pendingRegion = nil
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
      promptNotificationId,
      slotEndNotificationId,
      departureNotificationId,
    ])
    if let sessionId = activeSessionId, #available(iOS 16.1, *) {
      endLiveActivity(sessionId: sessionId)
    }
    activeSessionId = nil
    activeCheckInAt = nil
    UserDefaults.standard.removeObject(forKey: "medifit.workout.session")
  }

  /// iOS intentionally keeps its Live Activity active while the in-app timer
  /// is visible. Ending it here and trying to recreate it after backgrounding
  /// is unreliable because ActivityKit starts ordinary activities only while
  /// the app is foregrounded.
  private func hideWorkoutTimer() {
    // Android owns the hide/show behavior for its foreground notification.
  }

  private func showWorkoutTimer(_ values: [String: Any]) -> String {
    let sessionId = values["sessionId"] as? String ?? activeSessionId ?? ""
    guard !sessionId.isEmpty else { return "failed" }
    activeSessionId = sessionId
    activeFacilityName = values["facilityName"] as? String ?? activeFacilityName
    let checkInMilliseconds = values["checkInAt"] as? NSNumber
    let checkInAt = checkInMilliseconds.map {
      Date(timeIntervalSince1970: $0.doubleValue / 1000)
    } ?? activeCheckInAt ?? Date()
    activeCheckInAt = checkInAt
    if #available(iOS 16.1, *) {
      return startLiveActivity(
        sessionId: sessionId,
        facilityName: activeFacilityName,
        checkInAt: checkInAt
      )
    }
    return "unsupported"
  }

  private var promptNotificationId: String {
    "medifit.workout.prompt.\(activeSessionId ?? "active")"
  }

  private var slotEndNotificationId: String {
    "medifit.workout.slot-end.\(activeSessionId ?? "active")"
  }

  private var departureNotificationId: String {
    "medifit.workout.departure.\(activeSessionId ?? "active")"
  }

  private func configureWorkoutNotifications() {
    let checkout = UNNotificationAction(
      identifier: Self.checkoutAction,
      title: "Checkout",
      options: [.foreground]
    )
    let keepWorking = UNNotificationAction(
      identifier: Self.continueAction,
      title: "Still working",
      options: []
    )
    let hourly = UNNotificationCategory(
      identifier: Self.hourlyNotificationCategory,
      actions: [checkout, keepWorking],
      intentIdentifiers: [],
      options: []
    )
    let slotEnd = UNNotificationCategory(
      identifier: Self.slotEndNotificationCategory,
      actions: [checkout, keepWorking],
      intentIdentifiers: [],
      options: []
    )
    // iOS always displays its own dismiss affordance, but this app category
    // deliberately exposes no "still working" action after a 2 km departure.
    let departure = UNNotificationCategory(
      identifier: Self.departureNotificationCategory,
      actions: [checkout],
      intentIdentifiers: [],
      options: []
    )
    UNUserNotificationCenter.current().setNotificationCategories([hourly, slotEnd, departure])
  }

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
  }

  private func scheduleHourlyPrompt(after date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Are you still working out?"
    content.body = "Confirm to keep your workout timer running, or open checkout when you are done."
    content.categoryIdentifier = Self.hourlyNotificationCategory
    // A repeating OS notification also covers an ignored/dismissed prompt.
    let delay = max(60, date.timeIntervalSinceNow)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: true)
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [promptNotificationId])
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: promptNotificationId, content: content, trigger: trigger)
    )
  }

  private func scheduleSlotEndPrompt(at date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Your booked slot has ended"
    content.body = "Open checkout when you are done, or confirm that you are still working out."
    content.categoryIdentifier = Self.slotEndNotificationCategory
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: slotEndNotificationId, content: content, trigger: trigger)
    )
  }

  private func scheduleDeparturePrompt() {
    let content = UNMutableNotificationContent()
    content.title = "Have you left your workout?"
    content.body = "Your phone is 2 km from where you scanned in. Please open checkout to finish the active session."
    content.categoryIdentifier = Self.departureNotificationCategory
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: departureNotificationId, content: content, trigger: trigger)
    )
  }

  private func emitToFlutter(_ method: String) {
    guard dartReady, let workoutChannel else {
      pendingEvents.append(method)
      return
    }
    workoutChannel.invokeMethod(method, arguments: nil)
  }

  private func flushPendingEvents() {
    let events = pendingEvents
    pendingEvents.removeAll()
    for event in events {
      workoutChannel?.invokeMethod(event, arguments: nil)
    }
  }

  @available(iOS 16.1, *)
  private func startLiveActivity(sessionId: String, facilityName: String, checkInAt: Date) -> String {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return "disabled" }
    // Resuming from the timer page can request the same surface more than
    // once. Keep a single Live Activity per workout session.
    let activities = Activity<WorkoutLiveActivityAttributes>.activities
    if let activity = activities.first(where: { $0.attributes.sessionId == sessionId }) {
      let state = WorkoutLiveActivityAttributes.ContentState(
        facilityName: facilityName,
        checkInAt: checkInAt
      )
      updateLiveActivity(activity, state: state)
      return "active"
    }
    // New activities must start while foregrounded. If the OS removed the
    // surface, Flutter retries from its next foreground lifecycle event.
    guard UIApplication.shared.applicationState == .active else { return "failed" }
    for activity in activities {
      endLiveActivity(activity)
    }
    let attributes = WorkoutLiveActivityAttributes(sessionId: sessionId)
    let state = WorkoutLiveActivityAttributes.ContentState(
      facilityName: facilityName,
      checkInAt: checkInAt
    )
    do {
      if #available(iOS 16.2, *) {
        _ = try Activity<WorkoutLiveActivityAttributes>.request(
          attributes: attributes,
          content: ActivityContent(state: state, staleDate: nil),
          pushType: nil
        )
      } else {
        _ = try Activity<WorkoutLiveActivityAttributes>.request(
          attributes: attributes,
          contentState: state,
          pushType: nil
        )
      }
      return "active"
    } catch {
      NSLog("Medifit Live Activity start failed: %@", error.localizedDescription)
      return "failed"
    }
  }

  @available(iOS 16.1, *)
  private func updateLiveActivity(
    _ activity: Activity<WorkoutLiveActivityAttributes>,
    state: WorkoutLiveActivityAttributes.ContentState
  ) {
    Task {
      if #available(iOS 16.2, *) {
        await activity.update(ActivityContent(state: state, staleDate: nil))
      } else {
        await activity.update(using: state)
      }
    }
  }

  @available(iOS 16.1, *)
  private func endLiveActivity(_ activity: Activity<WorkoutLiveActivityAttributes>) {
    Task {
      if #available(iOS 16.2, *) {
        await activity.end(
          ActivityContent(state: activity.contentState, staleDate: nil),
          dismissalPolicy: .immediate
        )
      } else {
        await activity.end(using: activity.contentState, dismissalPolicy: .immediate)
      }
    }
  }

  @available(iOS 16.1, *)
  private func endLiveActivity(sessionId: String) {
    for activity in Activity<WorkoutLiveActivityAttributes>.activities where activity.attributes.sessionId == sessionId {
      endLiveActivity(activity)
    }
  }
}
