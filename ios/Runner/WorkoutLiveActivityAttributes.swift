import ActivityKit
import Foundation

/// Data shared by the app and its WidgetKit extension.  It intentionally
/// carries only the facility display name, check-in time, and opaque session
/// identifier; member identity and location never leave the app process.
@available(iOS 16.1, *)
struct WorkoutLiveActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    let facilityName: String
    let checkInAt: Date
  }

  let sessionId: String
}
