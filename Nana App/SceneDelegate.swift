import UIKit

/// iOS creates one of these for the app window. It is where the app starts showing its first
/// screen.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    /// Called when the app window is created. We style the navigation bar, put the Start screen
    /// inside a navigation controller (which handles the back buttons), and show the window.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let bar = UINavigationBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = Palette.bg
        bar.shadowColor = .clear
        bar.titleTextAttributes = [.foregroundColor: Palette.text,
                                   .font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        UINavigationBar.appearance().standardAppearance = bar
        UINavigationBar.appearance().scrollEdgeAppearance = bar

        let nav = UINavigationController(rootViewController: StartViewController())
        nav.navigationBar.tintColor = Palette.primary

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        window.tintColor = Palette.primary
        window.makeKeyAndVisible()
        self.window = window
    }
}
