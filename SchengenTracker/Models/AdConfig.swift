import Foundation

enum AdConfig {
    #if DEBUG
    static let appOpenAdUnitID = "ca-app-pub-3940256099942544/5575463023"
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    #else
    static let appOpenAdUnitID = "ca-app-pub-4218998263424275/3694897763"
    static let bannerAdUnitID = "ca-app-pub-4218998263424275/4760567427"
    #endif
}
