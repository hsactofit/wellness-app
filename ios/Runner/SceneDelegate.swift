import Flutter
import UIKit

/// Receives custom-scheme URLs when the Flutter app uses UIKit scenes.
///
/// AppDelegate handles legacy application URL callbacks, but a foregrounded
/// or suspended scene receives its URL through this delegate. Both routes use
/// the same queued checkout signal in AppDelegate.
final class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    _ = handleWorkoutURLContexts(connectionOptions.urlContexts)
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if handleWorkoutURLContexts(URLContexts) { return }
    super.scene(scene, openURLContexts: URLContexts)
  }

  private func handleWorkoutURLContexts(_ contexts: Set<UIOpenURLContext>) -> Bool {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return false
    }
    for context in contexts where appDelegate.handleWorkoutURL(context.url) {
      return true
    }
    return false
  }
}
