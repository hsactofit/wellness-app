import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct WorkoutLiveActivityWidget: Widget {
  private var checkoutURL: URL {
    let scheme = Bundle.main.object(forInfoDictionaryKey: "ProductURLScheme") as? String ?? "medifit"
    return URL(string: "\(scheme)://workout/checkout")!
  }

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: WorkoutLiveActivityAttributes.self) { context in
      HStack(spacing: 12) {
        Image(systemName: "figure.strengthtraining.traditional")
          .foregroundStyle(.orange)
        VStack(alignment: .leading, spacing: 2) {
          Text("Workout in progress")
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(context.state.facilityName)
            .font(.headline)
            .lineLimit(1)
        }
        Spacer(minLength: 8)
        VStack(alignment: .trailing, spacing: 6) {
          Text(context.state.checkInAt, style: .timer)
            .monospacedDigit()
          Link(destination: checkoutURL) {
            Text("Checkout")
              .font(.caption.weight(.bold))
              .foregroundStyle(.white)
              .padding(.horizontal, 12)
              .padding(.vertical, 7)
              .background(.red, in: Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal)
      .widgetURL(checkoutURL)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "figure.strengthtraining.traditional")
            .foregroundStyle(.orange)
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.state.facilityName).lineLimit(1)
            Text(context.state.checkInAt, style: .timer)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          Link(destination: checkoutURL) {
            Label("Checkout", systemImage: "rectangle.portrait.and.arrow.right")
              .frame(maxWidth: .infinity)
              .foregroundStyle(.red)
          }
        }
      } compactLeading: {
        Image(systemName: "figure.strengthtraining.traditional")
      } compactTrailing: {
        Text(context.state.checkInAt, style: .timer)
          .monospacedDigit()
      } minimal: {
        Image(systemName: "figure.strengthtraining.traditional")
      }
      .widgetURL(checkoutURL)
    }
  }
}

@main
struct WorkoutLiveActivityWidgetBundle: WidgetBundle {
  var body: some Widget {
    WorkoutLiveActivityWidget()
  }
}
