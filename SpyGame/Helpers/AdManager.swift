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

    // MARK: - Ad units

    private let bannerAdUnitID = "R-M-15706877-1"
    private let interstitialAdUnitID = "R-M-15706877-1"

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
        #if DEBUG
        YandexAds.enableLogging()
        print("[AdManager] startSDK called, isUnlocked=false, initialising SDK...")
        #endif
        YandexAds.initializeSDK { [weak self] in
            #if DEBUG
            print("[AdManager] SDK initialised, preloading interstitial")
            #endif
            Task { @MainActor in self?.preloadInterstitial() }
        }
    }

    // MARK: - Banner

    /// Standard 320x50 banner; callers must reserve at least `bannerHeight` of space
    /// at the bottom of their layout so it doesn't cover interactive UI.
    static let bannerHeight: CGFloat = 50
    static let bannerWidth: CGFloat = 320

    @discardableResult
    func attachBanner(to container: UIView, viewController: UIViewController) -> BannerAdView? {
        guard !PremiumIAP.isUnlocked() else {
            #if DEBUG
            print("[AdManager] attachBanner skipped: premium unlocked")
            #endif
            return nil
        }

        let adSize = BannerAdSize.fixed(width: Self.bannerWidth, height: Self.bannerHeight)
        let adView = BannerAdView(adSize: adSize)
        adView.delegate = self
        adView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            adView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            adView.widthAnchor.constraint(equalToConstant: Self.bannerWidth),
            adView.heightAnchor.constraint(equalToConstant: Self.bannerHeight)
        ])

        let request = AdRequest(adUnitID: bannerAdUnitID)
        #if DEBUG
        print("[AdManager] attachBanner: loading \(bannerAdUnitID) into \(type(of: viewController))")
        #endif
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
    func bannerAdViewDidLoad(_ bannerAdView: BannerAdView) {
        #if DEBUG
        print("[AdManager] banner LOADED — size: \(bannerAdView.frame.size)")
        #endif
    }

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
