//
//  FullScreenAdInfo.swift
//  
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds

/// A structure representing information about a full-screen ad, including its identifier, load time, and freshness interval.
struct FullScreenAdInfo<Ad: FullScreenPresentingAd>: Identifiable {
    /// The full-screen ad instance.
    let ad: Ad
    
    /// A unique identifier for the ad instance.
    let id: String
    
    /// The date and time when the ad was loaded.
    let loadTime: Date
    
    /// The time interval for which the ad remains "fresh" and valid.
    let freshnessInterval: TimeInterval
    
    /// Initializes a new instance of `FullScreenAdInfo`.
    /// - Parameters:
    ///   - ad: The ad instance to present.
    ///   - id: A unique identifier for the ad (defaults to a random UUID).
    ///   - loadTime: The load time of the ad (defaults to the current date).
    ///   - freshnessInterval: The time interval for ad freshness (defaults to 4 hours).
    init(ad: Ad, id: String = UUID().uuidString, loadTime: Date = Date(), freshnessInterval: TimeInterval = 4 * 3600) {
        self.ad = ad
        self.id = id
        self.loadTime = loadTime
        self.freshnessInterval = freshnessInterval
    }
}


// MARK: - Equatable
extension FullScreenAdInfo: Equatable {
    static func == (lhs: FullScreenAdInfo<Ad>, rhs: FullScreenAdInfo<Ad>) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - Helpers
extension FullScreenAdInfo {
    /// Checks whether the ad has expired based on the freshness interval.
    var isExpired: Bool {
        return Date().timeIntervalSince(loadTime) > freshnessInterval
    }
    
    /// Presents the ad if a top view controller is available, falling back to a failure callback if it cannot.
    /// - Parameter failure: An optional closure to call if the ad cannot be presented.
    func showAd(failure: (() -> Void)? = nil) {
        // TODO: - 
//        guard var topController = UIApplication.shared.getTopViewController() else {
//            failure?()
//            return
//        }
//        
//        // Traverse the view controller stack to the topmost view controller.
//        while let presentedViewController = topController.presentedViewController {
//            topController = presentedViewController
//        }
//        
//        // Present the appropriate ad type based on the ad instance.
//        if let interstitialAd = ad as? GADInterstitialAd {
//            interstitialAd.present(fromRootViewController: topController)
//        } else if let appOpenAd = ad as? GADAppOpenAd {
//            appOpenAd.present(fromRootViewController: topController)
//        } else {
//            failure?()
//        }
    }
}
