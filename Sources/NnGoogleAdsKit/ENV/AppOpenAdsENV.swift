//
//  AppOpenAdsENV.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds

/// Manages the environment for handling app open ads, including initialization, loading, and display conditions.
final class AppOpenAdsENV: NSObject, ObservableObject {
    private let delegate: AdDelegate
    private let adManager = SharedGoogleAdsManager.self
    
    private var isLoadingAd = false
    private var didInitializeAds = false
    private var nextAd: FullScreenAdInfo<GADAppOpenAd>?
    
    /// Initializes the app open ads environment.
    /// - Parameter delegate: An optional delegate for handling ad events.
    ///
    /// The delegate provides necessary configuration such as the ad unit ID and ad visibility authorization.
    init(delegate: AdDelegate) {
        self.delegate = delegate
    }
}


// MARK: - Actions
extension AppOpenAdsENV {
    /// Shows an ad if the user is authorized and the login count meets the specified threshold.
    ///
    /// This function ensures the ads are initialized and only shown if the `loginCount` is greater than the threshold,
    /// and if the delegate allows ads to be displayed.
    ///
    /// - Parameters:
    ///   - loginCount: The current login count.
    ///   - threshold: The number of logins required before starting ads.
    func showAdIfAuthorized(loginCount: Int, threshold: Int) {
        guard delegate.canShowAds else { return }
        
        if !didInitializeAds {
            SharedGoogleAdsManager.initializeMobileAds()
            didInitializeAds = true
        }
        
        guard loginCount > threshold else { return }
        
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
        delegate.adDidRecordClick()
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        delegate.adDidRecordImpression()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        delegate.adWillDismiss()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        nextAd = nil
        delegate.adDidDismiss()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        nextAd = nil
        delegate.adFailedToPresent(error: error)
        
        Task {
            nextAd = await loadNextAd()
        }
    }
}


// MARK: - MainActor
@MainActor
private extension AppOpenAdsENV {
    /// Presents the given app open ad from the root view controller.
    /// - Parameter ad: The app open ad to present.
    func presentAd(ad: GADAppOpenAd) {
        guard let rootVC = UIApplication.shared.getTopViewController() else { return }
        ad.present(fromRootViewController: rootVC)
    }
}


// MARK: - Private Methods
private extension AppOpenAdsENV {
    /// Retrieves an ad to display if available and not expired, otherwise loads a new ad.
    /// - Returns: A valid, non-expired ad if available, otherwise loads a new ad asynchronously.
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
        
        guard let ad = try? await adManager.loadAppOpenAd(unitId: delegate.adUnitId) else { return nil }
        
        ad.fullScreenContentDelegate = self
        isLoadingAd = false
        
        return .init(ad: ad)
    }
}


// MARK: - Dependencies
/// A protocol that defines the requirements for handling ad-related events in an app.
///
/// Conforming to this protocol allows an object to respond to various ad lifecycle events,
/// such as dismissals, clicks, impressions, and presentation errors. It also provides the
/// configuration needed to manage ad display permissions.
public protocol AdDelegate {
    /// The ad unit ID used to load and display ads.
    var adUnitId: String { get }
    
    /// A Boolean value indicating whether ads can currently be shown.
    var canShowAds: Bool { get }
    
    /// Called when an ad has completely dismissed.
    ///
    /// This method is called after the ad has been fully removed from the screen, making it
    /// suitable for resetting state or triggering any post-dismissal actions.
    func adDidDismiss()
    
    /// Called when an ad is about to be dismissed.
    ///
    /// This method is called just before the ad starts to disappear, making it ideal for
    /// performing actions or notifying other components that the ad is closing.
    func adWillDismiss()
    
    /// Called when the user records a click on the ad.
    ///
    /// This method is triggered each time the user interacts with the ad by clicking on it,
    /// allowing tracking of ad engagement.
    func adDidRecordClick()
    
    /// Called when the ad records an impression.
    ///
    /// This method is triggered when the ad is displayed and registers an impression, enabling
    /// tracking of the ad's viewability.
    func adDidRecordImpression()
    
    /// Called when the ad fails to present due to an error.
    ///
    /// This method is called if there is an error when trying to show the ad, providing an
    /// opportunity to log or handle the error.
    /// - Parameter error: The error that prevented the ad from presenting.
    func adFailedToPresent(error: Error)
}

public extension AdDelegate {
    /// Default implementation that does nothing when an ad is dismissed.
    func adDidDismiss() { }
    
    /// Default implementation that does nothing when an ad is about to be dismissed.
    func adWillDismiss() { }
    
    /// Default implementation that does nothing when a click is recorded on the ad.
    func adDidRecordClick() { }
    
    /// Default implementation that does nothing when an impression is recorded for the ad.
    func adDidRecordImpression() { }
    
    /// Default implementation that does nothing when the ad fails to present.
    /// - Parameter error: The error that prevented the ad from presenting.
    func adFailedToPresent(error: Error) { }
}
