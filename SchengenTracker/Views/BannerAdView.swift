import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    var onAdLoaded: () -> Void = {}
    var onAdFailed: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onAdLoaded: onAdLoaded, onAdFailed: onAdFailed)
    }

    func makeUIView(context: Context) -> UIView {
        // Outer container always has 50px height so Google accepts the request
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        context.coordinator.bannerView = bannerView
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        bannerView.load(GADRequest())
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, GADBannerViewDelegate {
        var onAdLoaded: () -> Void
        var onAdFailed: () -> Void
        weak var bannerView: GADBannerView?

        init(onAdLoaded: @escaping () -> Void, onAdFailed: @escaping () -> Void) {
            self.onAdLoaded = onAdLoaded
            self.onAdFailed = onAdFailed
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            onAdLoaded()
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("[SchengenTracker] Banner ad failed: \(error.localizedDescription)")
            onAdFailed()
            // Retry after 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
                self?.bannerView?.load(GADRequest())
            }
        }
    }
}

/// Wrapper that shows 50px for loading, collapses on failure
struct BannerAdContainer: View {
    let adUnitID: String
    @State private var adState: AdState = .loading

    enum AdState { case loading, loaded, failed }

    var body: some View {
        BannerAdView(
            adUnitID: adUnitID,
            onAdLoaded: { withAnimation { adState = .loaded } },
            onAdFailed: { withAnimation { adState = .failed } }
        )
        .frame(height: adState == .failed ? 0 : 50)
        .clipped()
    }
}
