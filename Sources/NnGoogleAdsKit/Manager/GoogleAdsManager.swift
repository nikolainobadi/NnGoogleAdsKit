//
//  GoogleAdsManager.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds
import AppTrackingTransparency

/// Manages shared configurations and utilities for Google Mobile Ads.
final class GoogleAdsManager: AdService {
    private let debugEnabled: Bool

    var didSetAuthStatus: Bool {
        return appTrackingAuthStatus != .notDetermined
    }

    /// Creates a new instance of `GoogleAdsManager`.
    ///
    /// - Parameter debugEnabled: When `true`, prints ad loading details to the console. Nothing is printed when `false` (default).
    init(debugEnabled: Bool = false) {
        self.debugEnabled = debugEnabled
    }

    func initializeMobileAds() {
        log("Starting Mobile Ads SDK")
        MobileAds.shared.start()
    }

    func requestTrackingAuthorization() async {
        log("Requesting tracking authorization")
        await ATTrackingManager.requestTrackingAuthorization()
        log("Tracking authorization status: \(appTrackingAuthStatus.rawValue)")
    }

    func loadAppOpenAd(unitId: String) async -> AppOpenAd? {
        let adId = getAppOpenAdId(unitId: unitId)

        log("Loading app open ad with unit id: \(adId)")

        return await AppOpenAd.loadAdOnMainThread(with: adId, request: .customInit(trackingAuthStatus: appTrackingAuthStatus))
    }
}


// MARK: - Private Helpers
private extension GoogleAdsManager {
    var appTrackingAuthStatus: ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
    
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

    /// Prints a message to the console when debug logging is enabled.
    ///
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        AdsKitLogger.log(message, isEnabled: debugEnabled)
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
