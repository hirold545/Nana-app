import UIKit

/// The entry point of the app (@main). iOS creates this first. It does almost nothing here
/// because the window and first screen are created in SceneDelegate.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Called once when the app finishes launching. Return true to say "all good".
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    /// Called when iOS wants to open a new window. We hand back the "Default Configuration"
    /// that is described in Info.plist (it points to SceneDelegate).
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
