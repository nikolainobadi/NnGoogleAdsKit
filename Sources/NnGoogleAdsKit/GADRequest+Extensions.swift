//
//  GADRequest+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import GoogleMobileAds
import AppTrackingTransparency

extension GADRequest {
    static func customInit(trackingAuthStatus: ATTrackingManager.AuthorizationStatus) -> GADRequest {
        let request = GADRequest()
        
        request.requestAgent = trackingAuthStatus.gadRequestAgent
        
        return request
    }
}


// MARK: - Extension Depencies
extension ATTrackingManager.AuthorizationStatus {
    var gadRequestAgent: String {
        switch self {
        case .authorized:
            return "Ads/GMA_IDFA"
        case .denied, .restricted:
            return "Ads/GMA"
        default:
            return ""
        }
    }
}
