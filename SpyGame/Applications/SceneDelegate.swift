import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        UINavigationBar.appearance().tintColor = .white
        let mainVC = MainViewController()
        mainVC.presenter = MainPresenter(view: mainVC)
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Ask App Store once per 24 hours whether a newer version is available;
        // if so, show a non-blocking update prompt. Throttle lives inside the checker.
        if let root = window?.rootViewController {
            AppVersionChecker.checkAndPromptIfNeeded(from: root)
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

