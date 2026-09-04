import ActivityKit
import CoreLocation
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate {
  private static let channelName = "com.medifit/workout_background"
  private static let notificationCategory = "MEDIFIT_WORKOUT_PROMPT"
  private static let checkoutAction = "MEDIFIT_WORKOUT_CHECKOUT"
  private static let continueAction = "MEDIFIT_WORKOUT_CONTINUE"

  private var workoutChannel: FlutterMethodChannel?
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
    guard url.scheme == "medifit", url.host == "workout", url.path == "/checkout" else {
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
    guard response.notification.request.content.categoryIdentifier == Self.notificationCategory else {
      super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
      return
    }
    switch response.actionIdentifier {
    case Self.checkoutAction, UNNotificationDefaultActionIdentifier:
      emitToFlutter("checkoutRequested")
    case Self.continueAction:
      emitToFlutter("continueRequested")
      scheduleHourlyPrompt(after: Date().addingTimeInterval(60 * 60))
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
    guard region.identifier == pendingRegion?.identifier else { return }
    emitToFlutter("geofenceExited")
    scheduleExitPrompt()
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
      let latitude = values["latitude"] as? Double
      let longitude = values["longitude"] as? Double
      result(latitude != nil && longitude != nil)
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
    let slotEndMilliseconds = values["slotEndAt"] as? NSNumber
    let slotEndAt = slotEndMilliseconds.map { Date(timeIntervalSince1970: $0.doubleValue / 1000) }

    requestNotificationPermission()
    scheduleHourlyPrompt(after: slotEndAt ?? checkInAt.addingTimeInterval(60 * 60))
    // A Live Activity must be started while the app is foregrounded. It stays
    // active even while the in-app workout view is visible, so it is ready
    // when the member returns to the Home or Lock Screen.
    _ = showWorkoutTimer(values)

    guard let latitude = values["latitude"] as? Double,
          let longitude = values["longitude"] as? Double else { return }
    let configuredRadius = (values["geofenceRadiusMeters"] as? NSNumber)?.doubleValue ?? 2000
    let radius = min(configuredRadius, locationManager.maximumRegionMonitoringDistance)
    guard radius > 0, CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
    let region = CLCircularRegion(
      center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
      radius: radius,
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
      break
    @unknown default:
      break
    }
  }

  private func stopWorkoutSurface() {
    if let region = pendingRegion {
      locationManager.stopMonitoring(for: region)
    }
    pendingRegion = nil
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
      promptNotificationId,
      exitNotificationId,
    ])
    if let sessionId = activeSessionId, #available(iOS 16.1, *) {
      endLiveActivity(sessionId: sessionId)
    }
    activeSessionId = nil
    activeCheckInAt = nil
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

  private var exitNotificationId: String {
    "medifit.workout.exit.\(activeSessionId ?? "active")"
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
    let category = UNNotificationCategory(
      identifier: Self.notificationCategory,
      actions: [checkout, keepWorking],
      intentIdentifiers: [],
      options: []
    )
    UNUserNotificationCenter.current().setNotificationCategories([category])
  }

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
  }

  private func scheduleHourlyPrompt(after date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Is your workout complete?"
    content.body = "Your workout at \(activeFacilityName) is still active. Open checkout when you are done."
    content.categoryIdentifier = Self.notificationCategory
    let delay = max(1, date.timeIntervalSinceNow)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: promptNotificationId, content: content, trigger: trigger)
    )
  }

  private func scheduleExitPrompt() {
    let content = UNMutableNotificationContent()
    content.title = "Have you left \(activeFacilityName)?"
    content.body = "Your phone left the facility area. Checkout when your workout is complete."
    content.categoryIdentifier = Self.notificationCategory
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: exitNotificationId, content: content, trigger: trigger)
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
