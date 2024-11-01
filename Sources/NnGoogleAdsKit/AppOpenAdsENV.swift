//
//  AppOpenAdsENV.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds

final class AppOpenAdsENV: NSObject, ObservableObject {
    @Published var adToDisplay: FullScreenAdInfo<GADAppOpenAd>?
    
    private let adUnitId: String
    private let delegate: AdDelegate
    private let adManager = SharedGoogleAdsManager.self
    private var nextAd: FullScreenAdInfo<GADAppOpenAd>?
    
    init(adUnitId: String, delegate: AdDelegate) {
        self.adUnitId = adUnitId
        self.delegate = delegate
    }
}


// MARK: - Actions
extension AppOpenAdsENV {
    func showAd() {
        if adManager.didSetAuthStatus {
            setAdToDisplay()
        } else {
            requestTrackingAuth()
        }
    }
}


// MARK: - Delegate
extension AppOpenAdsENV: GADFullScreenContentDelegate {
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        delegate.adDidRecordClick()
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        delegate.adDidRecordImpression()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        resetAds()
        loadNextAd()
        delegate.adWillDismiss()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        resetAds()
        loadNextAd()
        delegate.adFailedToPresent(error: error)
    }
}


// MARK: - Private Methods
private extension AppOpenAdsENV {
    func setAdToDisplay() {
        if let nextAd = nextAd, !nextAd.isExpired {
            adToDisplay = nextAd
        } else {
            loadNextAd()
        }
    }
    
    func requestTrackingAuth() {
        Task {
            await adManager.requestTrackingAuthorization()
        }
    }
    
    func resetAds() {
        nextAd = nil
        adToDisplay = nil
    }
    
    func loadNextAd() {
        Task {
            do {
                let ad = try await adManager.loadAppOpenAd(unitId: adUnitId)
                
                ad.fullScreenContentDelegate = self

                nextAd = .init(ad: ad)
            } catch {
                // TODO: - what should I do here?
                print(error)
                print("error loading ad", error.localizedDescription)
            }
        }
    }
}


// MARK: - Dependencies
public protocol AdDelegate {
    func adDidRecordClick()
    func adDidRecordImpression()
    func adWillDismiss()
    func adFailedToPresent(error: Error)
}


// MARK: - New code to be added
//struct AppOpenAdsViewModifier: ViewModifier {
//    @StateObject var adENV: SharedAdENV
//    @Environment(\.scenePhase) private var scenePhase
//    @AppStorage("AppOpenAdsLoginCount") private var loginCount = 0
//    
//    let canShowAds: Bool
//    
//    init(unitId: String, canShowAds: Bool, loginCountBeforeStartingAds: Int) {
//        self.canShowAds = canShowAds
//        self._adENV = .init(wrappedValue: .init(adUnitId: unitId, loginCountBeforeStartingAds: loginCountBeforeStartingAds))
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .alreadyLoggedInAction(loggedInCount: $loginCount) {
//                loginCount += 1
//                adENV.showAdIfAuthorized(loginCount: loginCount)
//            }
//            .onChange(of: scenePhase) { _, newPhase in
//                if newPhase == .active, canShowAds {
//                    adENV.showAdIfAuthorized(loginCount: loginCount)
//                }
//            }
//    }
//}
//
//public extension View {
//    func withAppOpenAds(canShowAds: Bool) -> some View {
//        modifier(AppOpenAdsViewModifier(unitId: AdMobId.openApp.id, canShowAds: canShowAds, loginCountBeforeStartingAds: 3))
//    }
//}
//
//struct InitialLoginViewModifier: ViewModifier {
//    @Binding var loggedInCount: Int
//    @AppStorage("IsInitialLogin") private var isInitialLogin = true
//    
//    let action: () -> Void
//    
//    func body(content: Content) -> some View {
//        content
//            .onAppear {
//                if isInitialLogin {
//                    isInitialLogin = false
//                } else {
//                    action()
//                }
//            }
//            .onDisappear {
//                loggedInCount = 0
//                isInitialLogin = true
//            }
//    }
//}
//
//extension View {
//    func alreadyLoggedInAction(loggedInCount: Binding<Int>, action: @escaping () -> Void) -> some View {
//        modifier(InitialLoginViewModifier(loggedInCount: loggedInCount, action: action))
//    }
//}
//
//final class SharedAdENV: NSObject, ObservableObject {
//    private let adUnitId: String
//    private let delegate: AdDelegate?
//    private let loginCountBeforeStartingAds: Int
//    private let adManager = SharedGoogleAdsManager.self
//    
//    private var isLoadingAd = false
//    private var nextAd: FullScreenAdInfo<GADAppOpenAd>?
//    
//    private var didSetAuthStatus: Bool {
//        return appTrackingAuthStatus != .notDetermined
//    }
//    
//    private var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
//        return ATTrackingManager.trackingAuthorizationStatus
//    }
//    
//    init(adUnitId: String, loginCountBeforeStartingAds: Int, delegate: AdDelegate? = nil) {
//        self.adUnitId = adUnitId
//        self.delegate = delegate
//        self.loginCountBeforeStartingAds = loginCountBeforeStartingAds
//    }
//}
//
//
//// MARK: - Actions
//extension SharedAdENV {
//    func showAdIfAuthorized(loginCount: Int) {
//        guard loginCount > loginCountBeforeStartingAds else {
//            return
//        }
//        
//        Task {
//            if didSetAuthStatus {
//                if let adToDisplay = await getAdToDisplay() {
//                    await presentAd(ad: adToDisplay.ad)
//                }
//            } else {
//                await ATTrackingManager.requestTrackingAuthorization()
//            }
//        }
//    }
//}
//
//
//// MARK: - Delegate
//extension SharedAdENV: GADFullScreenContentDelegate {
//    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
//        delegate?.adDidRecordClick()
//    }
//    
//    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
//        delegate?.adDidRecordImpression()
//    }
//    
//    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        delegate?.adWillDismiss()
//    }
//    
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        nextAd = nil
//    }
//    
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        nextAd = nil
//        delegate?.adFailedToPresent(error: error)
//        
//        Task {
//            nextAd = await loadNextAd()
//        }
//    }
//}
//
//
//// MARK: - MainActor
//@MainActor
//private extension SharedAdENV {
//    func presentAd(ad: GADAppOpenAd) {
//        guard let rootVC = UIApplication.shared.getTopViewController() else {
//            return
//        }
//        
//        ad.present(fromRootViewController: rootVC)
//    }
//}
//
//// MARK: - Private Methods
//private extension SharedAdENV {
//    func getAdToDisplay() async -> FullScreenAdInfo<GADAppOpenAd>? {
//        if let nextAd, !nextAd.isExpired {
//            return nextAd
//        }
//        
//        return await loadNextAd()
//    }
//    
//    func loadNextAd() async -> FullScreenAdInfo<GADAppOpenAd>? {
//        if isLoadingAd {
//            return nil
//        }
//        
//        isLoadingAd = true
//        
//        guard let ad = try? await adManager.loadAppOpenAd(unitId: adUnitId) else {
//            return nil
//        }
//        
//        ad.fullScreenContentDelegate = self
//        isLoadingAd = false
//        
//        return .init(ad: ad)
//    }
//}
//
//public struct FullScreenAdInfo<Ad: GADFullScreenPresentingAd>: Identifiable {
//    public let ad: Ad
//    public let id: String
//    private let loadTime: Date
//    private let freshnessInterval: TimeInterval
//    
//    public init(ad: Ad, id: String = UUID().uuidString, loadTime: Date = Date(), freshnessInterval: TimeInterval = 4 * 3600) {
//        self.ad = ad
//        self.id = id
//        self.loadTime = loadTime
//        self.freshnessInterval = freshnessInterval
//    }
//}
//
//
//// MARK: - Equatable
//extension FullScreenAdInfo: Equatable {
//    public static func == (lhs: FullScreenAdInfo<Ad>, rhs: FullScreenAdInfo<Ad>) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
//
//
//// MARK: - Helpers
//public extension FullScreenAdInfo {
//    var isExpired: Bool {
//        return Date().timeIntervalSince(loadTime) > freshnessInterval
//    }
//    
//    func showAd(failure: (() -> Void)? = nil) {
//        guard var topController = UIApplication.shared.getTopViewController() else {
//            failure?()
//            return
//        }
//
//        while let presentedViewController = topController.presentedViewController {
//            topController = presentedViewController
//        }
//
//        if let interstitialAd = ad as? GADInterstitialAd {
//            interstitialAd.present(fromRootViewController: topController)
//        } else if let appOpenAd = ad as? GADAppOpenAd {
//            appOpenAd.present(fromRootViewController: topController)
//        } else {
//            failure?()
//        }
//    }
//}
//
//public protocol AdDelegate {
//    func adDidRecordClick()
//    func adDidRecordImpression()
//    func adWillDismiss()
//    func adFailedToPresent(error: Error)
//}
//
//import AppTrackingTransparency
//
//public enum SharedGoogleAdsManager {
//    public static var didSetAuthStatus: Bool {
//        return appTrackingAuthStatus != .notDetermined
//    }
//    
//    public static var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
//        return ATTrackingManager.trackingAuthorizationStatus
//    }
//}
//
//
//// MARK: - Initialization
//public extension SharedGoogleAdsManager {
//    static func initializeMobileAds() {
//        GADMobileAds.sharedInstance().start()
//    }
//    
//    static func requestTrackingAuthorization() async {
//        await ATTrackingManager.requestTrackingAuthorization()
//    }
//}
//
//
//// MARK: - AdLoader
//public extension SharedGoogleAdsManager {
//    static func loadAppOpenAd(unitId: String) async throws -> GADAppOpenAd {
//        let adId = getAppOpenAdId(unitId: unitId)
//        
//        return try await GADAppOpenAd.load(withAdUnitID: adId, request: .customInit(trackingAuthStatus: appTrackingAuthStatus))
//    }
//}
//
//
//// MARK: - Private Methods
//private extension SharedGoogleAdsManager {
//    static func getAppOpenAdId(unitId: String) -> String {
//        #if DEBUG
//            return "ca-app-pub-3940256099942544/5575463023"
//        #else
//            return unitId
//        #endif
//    }
//}
//
//extension GADRequest {
//    static func customInit(trackingAuthStatus: ATTrackingManager.AuthorizationStatus) -> GADRequest {
//        let request = GADRequest()
//        
//        request.requestAgent = trackingAuthStatus.gadRequestAgent
//        
//        return request
//    }
//}
//
//
//// MARK: - Extension Depencies
//extension ATTrackingManager.AuthorizationStatus {
//    var gadRequestAgent: String {
//        switch self {
//        case .authorized:
//            return "Ads/GMA_IDFA"
//        case .denied, .restricted:
//            return "Ads/GMA"
//        default:
//            return ""
//        }
//    }
//}
