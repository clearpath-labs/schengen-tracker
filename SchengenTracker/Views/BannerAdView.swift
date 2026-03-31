import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    @Binding var adLoaded: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(adLoaded: $adLoaded)
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootVC
        }
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    class Coordinator: NSObject, GADBannerViewDelegate {
        @Binding var adLoaded: Bool

        init(adLoaded: Binding<Bool>) {
            _adLoaded = adLoaded
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            withAnimation { adLoaded = true }
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("[SchengenTracker] Banner ad failed: \(error.localizedDescription)")
            withAnimation { adLoaded = false }
            // Retry after 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                bannerView.load(GADRequest())
            }
        }
    }
}

/// Wrapper that hides the banner space when no ad is loaded
struct BannerAdContainer: View {
    let adUnitID: String
    @State private var adLoaded = false

    var body: some View {
        if adLoaded {
            BannerAdView(adUnitID: adUnitID, adLoaded: $adLoaded)
                .frame(height: 50)
        } else {
            BannerAdView(adUnitID: adUnitID, adLoaded: $adLoaded)
                .frame(height: 0)
                .opacity(0)
        }
    }
}
