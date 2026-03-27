import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct SchengenTrackerApp: App {
    @StateObject private var store = TripStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.isDarkMode ? .dark : .light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: TripStore
    @State private var showSplash = true
    @State private var adsInitialized = false

    var body: some View {
        ZStack {
            ContentView()

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showSplash = false
                    }
                    // After splash finishes, request ATT then start ads
                    requestTrackingThenStartAds()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }

    private func requestTrackingThenStartAds() {
        // Small delay to let splash dismiss animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    // Only start ads after user responds to ATT
                    GADMobileAds.sharedInstance().start { _ in
                        AppOpenAdManager.shared.loadAd()
                        adsInitialized = true
                    }
                }
            }
        }
    }
}
