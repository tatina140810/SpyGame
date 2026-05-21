import UIKit

/// Lightweight "is there a newer version on the App Store?" check.
///
/// On launch we hit the public iTunes Lookup endpoint, compare the App Store version
/// with the installed `CFBundleShortVersionString`, and if there's a newer one show
/// a non-blocking alert with an Update / Later choice. We throttle the check to once
/// every 24 hours per device so users aren't nagged on every launch.
enum AppVersionChecker {

    private static let bundleID = "kg.tatina.SpyFinder"
    private static let lookupURL = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)")!
    private static let lastCheckKey = "appVersionChecker.lastCheckTimestamp"
    private static let throttleInterval: TimeInterval = 24 * 60 * 60 // 24 hours

    /// Result of a single lookup.
    struct UpdateInfo {
        let appStoreVersion: String
        let trackViewURL: URL
    }

    /// Returns information about an update if one is available, otherwise nil.
    /// Returns nil also when the throttle window hasn't elapsed yet, when the network
    /// call fails, or when the app isn't on the App Store yet.
    static func checkForUpdate(ignoringThrottle: Bool = false) async -> UpdateInfo? {
        if !ignoringThrottle, !throttleElapsed() { return nil }
        markChecked()

        guard let installed = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return nil
        }
        do {
            var request = URLRequest(url: lookupURL)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let result = results.first,
                  let storeVersion = result["version"] as? String,
                  let trackURLString = result["trackViewUrl"] as? String,
                  let trackURL = URL(string: trackURLString) else {
                return nil
            }
            guard storeVersion.compare(installed, options: .numeric) == .orderedDescending else {
                return nil
            }
            return UpdateInfo(appStoreVersion: storeVersion, trackViewURL: trackURL)
        } catch {
            #if DEBUG
            print("[AppVersionChecker] lookup failed: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    /// Runs `checkForUpdate` and presents a localized "Update available" alert
    /// from `presenter` if there is one. Safe to call from any thread.
    @MainActor
    static func checkAndPromptIfNeeded(from presenter: UIViewController) {
        Task { @MainActor in
            guard let info = await checkForUpdate() else { return }
            let alert = UIAlertController(
                title: "update_available_title".localized,
                message: String(format: "update_available_message".localized, info.appStoreVersion),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "update_button".localized, style: .default) { _ in
                UIApplication.shared.open(info.trackViewURL)
            })
            alert.addAction(UIAlertAction(title: "later_button".localized, style: .cancel))
            // Walk to the topmost VC so we don't try to present from a stale parent.
            var top: UIViewController = presenter
            while let next = top.presentedViewController { top = next }
            top.present(alert, animated: true)
        }
    }

    // MARK: - Throttle

    private static func throttleElapsed() -> Bool {
        let last = UserDefaults.standard.double(forKey: lastCheckKey)
        if last == 0 { return true }
        return Date().timeIntervalSince1970 - last >= throttleInterval
    }

    private static func markChecked() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckKey)
    }
}
