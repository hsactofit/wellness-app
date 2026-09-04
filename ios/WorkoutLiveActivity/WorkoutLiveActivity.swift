import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct WorkoutLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: WorkoutLiveActivityAttributes.self) { context in
      VStack(alignment: .leading, spacing: 8) {
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
          Spacer()
          Text(context.state.checkInAt, style: .timer)
            .monospacedDigit()
        }
        Link(destination: URL(string: "medifit://workout/checkout")!) {
          Label("Open checkout", systemImage: "rectangle.portrait.and.arrow.right")
            .font(.subheadline.weight(.semibold))
        }
      }
      .padding(.horizontal)
      .widgetURL(URL(string: "medifit://workout/checkout"))
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
          Link(destination: URL(string: "medifit://workout/checkout")!) {
            Label("Open checkout", systemImage: "rectangle.portrait.and.arrow.right")
              .frame(maxWidth: .infinity)
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
      .widgetURL(URL(string: "medifit://workout/checkout"))
    }
  }
}

@main
struct WorkoutLiveActivityWidgetBundle: WidgetBundle {
  var body: some Widget {
    WorkoutLiveActivityWidget()
  }
}
