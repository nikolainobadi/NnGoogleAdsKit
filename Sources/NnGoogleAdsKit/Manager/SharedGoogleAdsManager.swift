//
//  SharedGoogleAdsManager.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency

enum SharedGoogleAdsManager {
    static var didSetAuthStatus: Bool {
        return appTrackingAuthStatus != .notDetermined
    }
    
    static var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
}


// MARK: - Initialization
extension SharedGoogleAdsManager {
    static func initializeMobileAds() {
        GADMobileAds.sharedInstance().start()
    }
    
    static func requestTrackingAuthorization() async {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}


// MARK: - AdLoader
extension SharedGoogleAdsManager {
    static func loadAppOpenAd(unitId: String) async throws -> GADAppOpenAd {
        let adId = getAppOpenAdId(unitId: unitId)
        
        return try await GADAppOpenAd.load(withAdUnitID: adId, request: .customInit(trackingAuthStatus: appTrackingAuthStatus))
    }
}


// MARK: - Private Methods
private extension SharedGoogleAdsManager {
    static func getAppOpenAdId(unitId: String) -> String {
        #if DEBUG
            return "ca-app-pub-3940256099942544/5575463023"
        #else
            return unitId
        #endif
    }
}
