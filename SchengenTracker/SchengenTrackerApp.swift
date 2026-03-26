import SwiftUI
import GoogleMobileAds

@main
struct SchengenTrackerApp: App {
    @StateObject private var store = TripStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasLaunched = false

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.isDarkMode ? .dark : .light)
                .onAppear {
                    if !hasLaunched {
                        hasLaunched = true
                        AppOpenAdManager.shared.loadAd()
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, hasLaunched {
                AppOpenAdManager.shared.showAdIfAvailable()
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: TripStore
    @State private var showSplash = true

    var body: some View {
        ZStack {
            ContentView()

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showSplash = false
                    }
                    AppOpenAdManager.shared.onSplashFinished()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
