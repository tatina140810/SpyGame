import UIKit
import YandexMobileAds

/// Centralised wrapper around Yandex Mobile Ads SDK (8.0). Premium users see nothing —
/// every public method short-circuits when `PremiumIAP.isUnlocked()` is true.
///
/// Ad unit IDs are Yandex' public test IDs for development. After registering at
/// https://partner.yandex.com and creating real units, replace the two constants below
/// with strings of the form `R-M-XXXXXX-Y`.
@MainActor
final class AdManager: NSObject {

    static let shared = AdManager()

    // MARK: - Test ad units (replace with real ones in production)

    private let bannerAdUnitID = "demo-banner-yandex"
    private let interstitialAdUnitID = "demo-interstitial-yandex"

    // MARK: - Interstitial throttle

    private let lastInterstitialKey = "AdManager.lastInterstitialShownAt"
    private let interstitialMinInterval: TimeInterval = 3 * 60

    // MARK: - Interstitial state

    private var interstitialLoader: InterstitialAdLoader?
    private var loadedInterstitial: InterstitialAd?

    private override init() {
        super.init()
    }

    // MARK: - SDK init

    /// Call once from `AppDelegate.didFinishLaunchingWithOptions`.
    func startSDK() {
        guard !PremiumIAP.isUnlocked() else { return }
        YandexAds.initializeSDK { [weak self] in
            Task { @MainActor in self?.preloadInterstitial() }
        }
    }

    // MARK: - Banner

    @discardableResult
    func attachBanner(to container: UIView, viewController: UIViewController) -> BannerAdView? {
        guard !PremiumIAP.isUnlocked() else { return nil }

        let width = container.bounds.width > 0 ? container.bounds.width : UIScreen.main.bounds.width
        let adSize = BannerAdSize.inline(width: width, maxHeight: 90)
        let adView = BannerAdView(adSize: adSize)
        adView.delegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            adView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
        ])

        let request = AdRequest(adUnitID: bannerAdUnitID)
        adView.loadAd(with: request)
        return adView
    }

    // MARK: - Interstitial

    func preloadInterstitial() {
        guard !PremiumIAP.isUnlocked() else { return }
        if interstitialLoader == nil {
            interstitialLoader = InterstitialAdLoader()
        }
        let request = AdRequest(adUnitID: interstitialAdUnitID)
        interstitialLoader?.loadAd(with: request) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let ad):
                    ad.delegate = self
                    self?.loadedInterstitial = ad
                case .failure(let error):
                    #if DEBUG
                    print("[AdManager] interstitial load failed: \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }

    func showInterstitialIfReady(from viewController: UIViewController) {
        guard !PremiumIAP.isUnlocked() else { return }

        let last = UserDefaults.standard.double(forKey: lastInterstitialKey)
        let elapsed = Date().timeIntervalSince1970 - last
        guard last == 0 || elapsed >= interstitialMinInterval else { return }

        guard let ad = loadedInterstitial else {
            preloadInterstitial()
            return
        }

        ad.show(from: viewController)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastInterstitialKey)
        loadedInterstitial = nil
        preloadInterstitial()
    }
}

// MARK: - BannerAdViewDelegate

extension AdManager: BannerAdViewDelegate {
    func bannerAdViewDidLoad(_ bannerAdView: BannerAdView) {}

    func bannerAdViewDidFailLoading(_ bannerAdView: BannerAdView, error: Error) {
        #if DEBUG
        print("[AdManager] banner failed: \(error.localizedDescription)")
        #endif
    }

    func bannerAdViewDidClick(_ bannerAdView: BannerAdView) {}

    func bannerAdView(_ bannerAdView: BannerAdView, didTrackImpression impressionData: ImpressionData?) {}
}

// MARK: - InterstitialAdDelegate

extension AdManager: InterstitialAdDelegate {
    func interstitialAd(_ interstitialAd: InterstitialAd, didFailToShow error: Error) {
        #if DEBUG
        print("[AdManager] interstitial show failed: \(error.localizedDescription)")
        #endif
        loadedInterstitial = nil
    }

    func interstitialAdDidShow(_ interstitialAd: InterstitialAd) {}

    func interstitialAdDidDismiss(_ interstitialAd: InterstitialAd) {
        loadedInterstitial = nil
    }

    func interstitialAdDidClick(_ interstitialAd: InterstitialAd) {}

    func interstitialAd(_ interstitialAd: InterstitialAd, didTrackImpression impressionData: ImpressionData?) {}
}
