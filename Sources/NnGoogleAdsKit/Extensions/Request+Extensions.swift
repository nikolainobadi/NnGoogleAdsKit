//
//  Request+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import GoogleMobileAds
import AppTrackingTransparency

extension Request {
    /// Initializes a custom GADRequest with a tracking authorization status.
    /// - Parameter trackingAuthStatus: The authorization status for ad tracking.
    /// - Returns: A configured GADRequest.
    static func customInit(trackingAuthStatus: ATTrackingManager.AuthorizationStatus) -> Request {
        let request = Request()
        request.requestAgent = trackingAuthStatus.gadRequestAgent
        return request
    }
}


// MARK: - Extension Dependencies
extension ATTrackingManager.AuthorizationStatus {
    /// Maps the authorization status to a corresponding ad request agent identifier.
    var gadRequestAgent: String {
        switch self {
        case .authorized: return "Ads/GMA_IDFA"
        case .denied, .restricted: return "Ads/GMA"
        default: return ""
        }
    }
}
