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
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true
    @State private var splashFinished = false
    @State private var attAndAdsHandled = false

    var body: some View {
        ZStack {
            ContentView()

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showSplash = false
                    }
                    splashFinished = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && splashFinished && !attAndAdsHandled {
                attAndAdsHandled = true
                handleATTAndAds()
            }
        }
        .onChange(of: splashFinished) { _, finished in
            if finished && scenePhase == .active && !attAndAdsHandled {
                attAndAdsHandled = true
                handleATTAndAds()
            }
        }
    }

    private func handleATTAndAds() {
        // Delay to ensure UI is fully settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = ATTrackingManager.trackingAuthorizationStatus

            if status == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    DispatchQueue.main.async {
                        startAds()
                    }
                }
            } else {
                startAds()
            }
        }
    }

    private func startAds() {
        GADMobileAds.sharedInstance().start { _ in
            AppOpenAdManager.shared.loadAndShowOnce()
        }
    }
}
