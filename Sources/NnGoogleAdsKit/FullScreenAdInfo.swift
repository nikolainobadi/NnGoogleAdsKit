//
//  FullScreenAdInfo.swift
//  
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import Foundation
import GoogleMobileAds

public struct FullScreenAdInfo<Ad: GADFullScreenPresentingAd>: Identifiable {
    public let ad: Ad
    public let id: String
    private let loadTime: Date
    
    public init(ad: Ad, id: String = UUID().uuidString, loadTime: Date = Date()) {
        self.ad = ad
        self.id = id
        self.loadTime = loadTime
    }
}


// MARK: - Equatable
extension FullScreenAdInfo: Equatable {
    public static func == (lhs: FullScreenAdInfo<Ad>, rhs: FullScreenAdInfo<Ad>) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - Helpers
public extension FullScreenAdInfo {
    var isExpired: Bool {
        let freshnessInterval: TimeInterval = 4 * 3600 // 4 hours
        
        return Date().timeIntervalSince(loadTime) > freshnessInterval
    }
    
    func showAd(failure: (() -> Void)? = nil) {
        guard var topController = UIApplication.shared.getTopViewController() else {
            failure?()
            return
        }

        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        if let interstitialAd = ad as? GADInterstitialAd {
            interstitialAd.present(fromRootViewController: topController)
        } else if let appOpenAd = ad as? GADAppOpenAd {
            appOpenAd.present(fromRootViewController: topController)
        } else {
            failure?()
        }
    }
}
