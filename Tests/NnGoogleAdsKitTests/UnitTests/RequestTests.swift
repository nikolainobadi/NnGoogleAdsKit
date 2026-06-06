//
//  RequestTests.swift
//  NnGoogleAdsKit
//
//  Created by Nikolai Nobadi on 4/20/25.
//

import Testing
import GoogleMobileAds
import AppTrackingTransparency
@testable import NnGoogleAdsKit

struct RequestTests {
    @Test(arguments: [
        (ATTrackingManager.AuthorizationStatus.authorized, "Ads/GMA_IDFA"),
        (.denied, "Ads/GMA"),
        (.restricted, "Ads/GMA"),
        (.notDetermined, "")
    ])
    func `Request agent matches tracking authorization status`(status: ATTrackingManager.AuthorizationStatus, expectedAgent: String) {
        let request = makeSUT(trackingAuthStatus: status)
        #expect(request.requestAgent == expectedAgent)
    }
}


// MARK: - SUT
private extension RequestTests {
    func makeSUT(trackingAuthStatus: ATTrackingManager.AuthorizationStatus = .notDetermined) -> Request {
        return Request.customInit(trackingAuthStatus: trackingAuthStatus)
    }
}
