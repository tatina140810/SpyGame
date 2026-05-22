import UIKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var transactionListener: Task<Void, Never>?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        transactionListener = PremiumIAP.startTransactionListener()
        Task { await PremiumIAP.refreshUnlockedState() }
        // Yandex Mobile Ads — no-op if premium is already unlocked. AdManager
        // also preloads the first interstitial inside the SDK init callback.
        AdManager.shared.startSDK()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    deinit {
        transactionListener?.cancel()
    }
}

extension AppDelegate {
    static var shared: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
}
