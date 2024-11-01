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
