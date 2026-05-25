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

    // MARK: - Ad units (from Yandex Partner Network)

    /// Banner placement (Активно in Yandex Partner).
    private let bannerAdUnitID = "R-M-15706877-1"
    /// Interstitial placement (Межстраничная реклама).
    private let interstitialAdUnitID = "R-M-15706877-2"

    // MARK: - Interstitial throttle

    private let lastInterstitialKey = "AdManager.lastInterstitialShownAt"
    private let interstitialMinInterval: TimeInterval = 3 * 60

    // MARK: - Interstitial state

    private var interstitialLoader: InterstitialAdLoader?
    private var loadedInterstitial: InterstitialAd?

    /// Called once after the interstitial is dismissed (or fails to show / is skipped),
    /// so a caller like "New Game" can chain navigation right after the ad.
    private var interstitialDismissHandler: (() -> Void)?

    // MARK: - SDK init queue

    /// Yandex SDK silently ignores `loadAd` calls made before `initializeSDK`
    /// finishes. We queue banner load requests until init completes.
    private var sdkInitialized = false
    private var pendingBanners: [(BannerAdView, AdRequest)] = []
    private var pendingInterstitialLoad = false

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
            Task { @MainActor in
                guard let self = self else { return }
                #if DEBUG
                print("[AdManager] SDK initialised, flushing \(self.pendingBanners.count) queued banner(s)")
                #endif
                self.sdkInitialized = true
                self.flushPendingBanners()
                self.preloadInterstitial()
            }
        }
    }

    private func flushPendingBanners() {
        for (view, request) in pendingBanners {
            view.loadAd(with: request)
        }
        pendingBanners.removeAll()
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
        if sdkInitialized {
            #if DEBUG
            print("[AdManager] attachBanner: load now (\(bannerAdUnitID)) in \(type(of: viewController))")
            #endif
            adView.loadAd(with: request)
        } else {
            #if DEBUG
            print("[AdManager] attachBanner: queued (SDK not ready) in \(type(of: viewController))")
            #endif
            pendingBanners.append((adView, request))
        }
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

    /// Show interstitial if loaded and throttle elapsed. `onDismiss` always fires —
    /// either after the user closes the ad, or immediately when the ad is skipped
    /// (premium user, throttle window, no preloaded ad). Callers chain navigation
    /// in `onDismiss` so the user never gets stuck if the ad doesn't show.
    func showInterstitialIfReady(from viewController: UIViewController,
                                 onDismiss: (() -> Void)? = nil) {
        guard !PremiumIAP.isUnlocked() else {
            onDismiss?()
            return
        }

        let last = UserDefaults.standard.double(forKey: lastInterstitialKey)
        let elapsed = Date().timeIntervalSince1970 - last
        guard last == 0 || elapsed >= interstitialMinInterval else {
            onDismiss?()
            return
        }

        guard let ad = loadedInterstitial else {
            preloadInterstitial()
            onDismiss?()
            return
        }

        interstitialDismissHandler = onDismiss
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

// MARK: - UIViewController convenience

extension UIViewController {
    /// Adds a Yandex banner to the bottom of this VC. Safe to call from
    /// `viewDidLoad` — `AdManager` queues the load if the SDK isn't initialised
    /// yet, and the call is a no-op for premium users.
    @discardableResult
    func installAdBanner() -> BannerAdView? {
        return AdManager.shared.attachBanner(to: view, viewController: self)
    }
}

extension AdManager: InterstitialAdDelegate {
    func interstitialAd(_ interstitialAd: InterstitialAd, didFailToShow error: Error) {
        #if DEBUG
        print("[AdManager] interstitial show failed: \(error.localizedDescription)")
        #endif
        loadedInterstitial = nil
        interstitialDismissHandler?()
        interstitialDismissHandler = nil
    }

    func interstitialAdDidShow(_ interstitialAd: InterstitialAd) {}

    func interstitialAdDidDismiss(_ interstitialAd: InterstitialAd) {
        loadedInterstitial = nil
        interstitialDismissHandler?()
        interstitialDismissHandler = nil
    }

    func interstitialAdDidClick(_ interstitialAd: InterstitialAd) {}

    func interstitialAd(_ interstitialAd: InterstitialAd, didTrackImpression impressionData: ImpressionData?) {}
}
