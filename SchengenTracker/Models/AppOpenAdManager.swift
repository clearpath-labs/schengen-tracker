import GoogleMobileAds
import UIKit

class AppOpenAdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = AppOpenAdManager()

    private let adUnitID = AdConfig.appOpenAdUnitID
    private var appOpenAd: GADAppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?
    private var showAfterSplash = false

    private override init() {
        super.init()
    }

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

            // If splash already finished while ad was loading, show now
            if self.showAfterSplash {
                self.showAfterSplash = false
                DispatchQueue.main.async {
                    self.showAdIfAvailable()
                }
            }
        }
    }

    private var isAdAvailable: Bool {
        guard let loadTime, appOpenAd != nil else { return false }
        return Date().timeIntervalSince(loadTime) < 4 * 3600
    }

    /// Called when splash screen finishes
    func onSplashFinished() {
        if isAdAvailable {
            showAdIfAvailable()
        } else {
            // Ad still loading — show it as soon as it arrives
            showAfterSplash = true
        }
    }

    func showAdIfAvailable() {
        guard !isShowingAd, isAdAvailable else {
            if !isAdAvailable { loadAd() }
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        isShowingAd = true
        appOpenAd?.present(fromRootViewController: rootVC)
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        loadAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        appOpenAd = nil
        loadAd()
    }
}
