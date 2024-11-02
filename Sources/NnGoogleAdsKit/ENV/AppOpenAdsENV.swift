//
//  AppOpenAdsENV.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds

/// Manages the environment for handling app open ads, including initialization and ad display conditions.
final class AppOpenAdsENV: NSObject, ObservableObject {
    private let adUnitId: String
    private let delegate: AdDelegate?
    private let loginCountBeforeStartingAds: Int
    private let adManager = SharedGoogleAdsManager.self
    
    private var isLoadingAd = false
    private var didInitializeAds = false
    private var nextAd: FullScreenAdInfo<GADAppOpenAd>?
    
    /// Initializes the app open ads environment.
    /// - Parameters:
    ///   - adUnitId: The ad unit identifier.
    ///   - delegate: An optional delegate for handling ad events.
    ///   - loginCountBeforeStartingAds: Number of logins required before starting ads.
    init(adUnitId: String, delegate: AdDelegate?, loginCountBeforeStartingAds: Int) {
        self.adUnitId = adUnitId
        self.delegate = delegate
        self.loginCountBeforeStartingAds = loginCountBeforeStartingAds
    }
}


// MARK: - Actions
extension AppOpenAdsENV {
    /// Shows an ad if the user is authorized and the login count meets requirements.
    /// - Parameter loginCount: The current login count.
    func showAdIfAuthorized(loginCount: Int) {
        if !didInitializeAds {
            SharedGoogleAdsManager.initializeMobileAds()
            didInitializeAds = true
        }
        
        guard loginCount > loginCountBeforeStartingAds else { return }
        
        Task {
            if SharedGoogleAdsManager.didSetAuthStatus {
                if let adToDisplay = await getAdToDisplay() {
                    await presentAd(ad: adToDisplay.ad)
                }
            } else {
                await SharedGoogleAdsManager.requestTrackingAuthorization()
            }
        }
    }
}


// MARK: - Delegate
extension AppOpenAdsENV: GADFullScreenContentDelegate {
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        delegate?.adDidRecordClick()
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        delegate?.adDidRecordImpression()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate?.adWillDismiss()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        nextAd = nil
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        nextAd = nil
        delegate?.adFailedToPresent(error: error)
        
        Task {
            nextAd = await loadNextAd()
        }
    }
}


// MARK: - MainActor
@MainActor
private extension AppOpenAdsENV {
    /// Presents the given app open ad.
    /// - Parameter ad: The app open ad to present.
    func presentAd(ad: GADAppOpenAd) {
        guard let rootVC = UIApplication.shared.getTopViewController() else { return }
        ad.present(fromRootViewController: rootVC)
    }
}


// MARK: - Private Methods
private extension AppOpenAdsENV {
    /// Retrieves an ad to display if available and not expired.
    /// - Returns: A valid, non-expired ad if available, otherwise loads a new ad.
    func getAdToDisplay() async -> FullScreenAdInfo<GADAppOpenAd>? {
        if let nextAd, !nextAd.isExpired {
            return nextAd
        }
        return await loadNextAd()
    }
    
    /// Loads the next ad asynchronously.
    /// - Returns: The next ad if successfully loaded, otherwise `nil`.
    func loadNextAd() async -> FullScreenAdInfo<GADAppOpenAd>? {
        if isLoadingAd { return nil }
        
        isLoadingAd = true
        
        guard let ad = try? await adManager.loadAppOpenAd(unitId: adUnitId) else { return nil }
        
        ad.fullScreenContentDelegate = self
        isLoadingAd = false
        
        return .init(ad: ad)
    }
}


// MARK: - Dependencies
public protocol AdDelegate {
    func adDidRecordClick()
    func adDidRecordImpression()
    func adWillDismiss()
    func adFailedToPresent(error: Error)
}
