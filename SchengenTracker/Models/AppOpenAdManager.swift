import GoogleMobileAds
import UIKit

class AppOpenAdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = AppOpenAdManager()

    private let adUnitID = AdConfig.appOpenAdUnitID
    private var appOpenAd: GADAppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?
    private var hasShownColdLaunchAd = false

    private override init() {
        super.init()
    }

    /// Load an ad. Does NOT auto-show.
    func loadAd() {
        guard !isLoadingAd, !isAdAvailable else { return }
        isLoadingAd = true

        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            guard let self else { return }
            self.isLoadingAd = false
            if let error {
                print("App open ad failed to load: \(error.localizedDescription)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
        }
    }

    /// Load and show once — for cold launch only.
    func loadAndShowOnce() {
        guard !hasShownColdLaunchAd else { return }
        hasShownColdLaunchAd = true

        guard !isLoadingAd else { return }
        isLoadingAd = true

        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            guard let self else { return }
            self.isLoadingAd = false
            if let error {
                print("App open ad failed to load: \(error.localizedDescription)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()

            DispatchQueue.main.async {
                self.showAdIfAvailable()
            }
        }
    }

    private var isAdAvailable: Bool {
        guard let loadTime, appOpenAd != nil else { return false }
        return Date().timeIntervalSince(loadTime) < 4 * 3600
    }

    func showAdIfAvailable() {
        guard !isShowingAd, isAdAvailable else { return }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        isShowingAd = true
        appOpenAd?.present(fromRootViewController: rootVC)
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        // Do NOT auto-reload or auto-show
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        appOpenAd = nil
    }
}
