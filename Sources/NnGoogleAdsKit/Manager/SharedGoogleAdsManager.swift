//
//  SharedGoogleAdsManager.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency

/// Manages shared configurations and utilities for Google Mobile Ads.
enum SharedGoogleAdsManager {
    /// Checks if the app tracking authorization status has been determined.
    static var didSetAuthStatus: Bool {
        return appTrackingAuthStatus != .notDetermined
    }
    
    /// Retrieves the current authorization status for app tracking.
    static var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
}


// MARK: - Initialization
extension SharedGoogleAdsManager {
    /// Initializes Google Mobile Ads SDK.
    static func initializeMobileAds() {
        GADMobileAds.sharedInstance().start()
    }
    
    /// Requests authorization for app tracking asynchronously.
    static func requestTrackingAuthorization() async {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}


// MARK: - AdLoader
extension SharedGoogleAdsManager {
    /// Asynchronously loads an App Open Ad with a given unit ID.
    /// - Parameter unitId: The ad unit ID to load the App Open Ad.
    /// - Returns: The loaded App Open Ad if successful.
    static func loadAppOpenAd(unitId: String) async throws -> GADAppOpenAd {
        let adId = getAppOpenAdId(unitId: unitId)
        return try await GADAppOpenAd.load(withAdUnitID: adId, request: .customInit(trackingAuthStatus: appTrackingAuthStatus))
    }
}


// MARK: - Private Methods
private extension SharedGoogleAdsManager {
    /// Retrieves the correct App Open Ad ID based on the build configuration.
    /// - Parameter unitId: The ad unit ID provided.
    /// - Returns: The ad ID to use for loading, typically a test ID for debug builds.
    static func getAppOpenAdId(unitId: String) -> String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/5575463023" // Test ID for debug builds.
        #else
        return unitId // Production ID for release builds.
        #endif
    }
}
