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
@MainActor
final class SharedGoogleAdsManager {
    static let shared = SharedGoogleAdsManager()
    
    /// Checks if the app tracking authorization status has been determined.
    var didSetAuthStatus: Bool {
        return appTrackingAuthStatus != .notDetermined
    }
    
    /// Retrieves the current authorization status for app tracking.
    var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
    
    private init() { }
}


// MARK: - Initialization
extension SharedGoogleAdsManager {
    /// Initializes Google Mobile Ads SDK.
    func initializeMobileAds() {
        MobileAds.shared.start()
    }
    
    /// Requests authorization for app tracking asynchronously.
    func requestTrackingAuthorization() async {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}


// MARK: - AdLoader
extension SharedGoogleAdsManager {
    /// Asynchronously loads an App Open Ad with a given unit ID.
    /// - Parameter unitId: The ad unit ID to load the App Open Ad.
    /// - Returns: The loaded App Open Ad if successful.
    func loadAppOpenAd(unitId: String) async -> AppOpenAd? {
        let adId = getAppOpenAdId(unitId: unitId)
        
        // use 'safe' method to ensure ad is loaded on main thread regardless of where it was originally loaded
        return await AppOpenAd.loadAdOnMainThread(with: adId, request: .customInit(trackingAuthStatus: appTrackingAuthStatus))
    }
}


// MARK: - Private Methods
private extension SharedGoogleAdsManager {
    /// Retrieves the correct App Open Ad ID based on the build configuration.
    /// - Parameter unitId: The ad unit ID provided.
    /// - Returns: The ad ID to use for loading, typically a test ID for debug builds.
    func getAppOpenAdId(unitId: String) -> String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/5575463023" // Test ID for debug builds.
        #else
        return unitId // Production ID for release builds.
        #endif
    }
}


// MARK: - Extension Dependences
/// Declares that `AppOpenAd` is `Sendable`, even though it doesn't conform explicitly.
///
/// This is marked `@unchecked` because the type is from a third-party SDK (Google Mobile Ads)
/// and doesn't declare thread-safety. By marking it manually, we're taking responsibility
/// for ensuring it's only accessed safely—specifically, from the main actor.
extension AppOpenAd: @unchecked @retroactive Sendable {
    
    /// Loads an `AppOpenAd` instance and guarantees that the returned value is isolated to the main actor.
    ///
    /// Google’s `load(with:request:)` method may complete on a background thread, and `AppOpenAd` itself
    /// is not marked `Sendable`. This method ensures that the ad is safely returned from the main actor,
    /// making it safe to use in `@MainActor`-isolated contexts without violating Swift's strict concurrency rules.
    ///
    /// - Parameters:
    ///   - unitId: The ad unit ID to request.
    ///   - request: A `GADRequest` to use when loading the ad.
    /// - Returns: A loaded `AppOpenAd` instance returned from the main actor context, or `nil` if loading failed.
    static func loadAdOnMainThread(with unitId: String, request: Request) async -> AppOpenAd? {
        // Attempt to load the ad using the standard Google SDK API.
        guard let ad = try? await load(with: unitId, request: request) else {
            return nil
        }

        // Transfer the non-Sendable result back onto the main actor explicitly,
        // so it can be used safely without triggering Swift concurrency violations.
        return await MainActor.run { ad }
    }
}
