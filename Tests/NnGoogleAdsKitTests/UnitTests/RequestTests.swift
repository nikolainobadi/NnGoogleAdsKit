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
    @Test("customInit sets agent for authorized status")
    func setsAgentForAuthorized() {
        let request = Request.customInit(trackingAuthStatus: .authorized)
        #expect(request.requestAgent == "Ads/GMA_IDFA")
    }
    
    @Test("customInit sets agent for denied status")
    func setsAgentForDenied() {
        let request = Request.customInit(trackingAuthStatus: .denied)
        #expect(request.requestAgent == "Ads/GMA")
    }
    
    @Test("customInit sets agent for restricted status")
    func setsAgentForRestricted() {
        let request = Request.customInit(trackingAuthStatus: .restricted)
        #expect(request.requestAgent == "Ads/GMA")
    }
    
    @Test("customInit sets agent for not determined status")
    func setsAgentForNotDetermined() {
        let request = Request.customInit(trackingAuthStatus: .notDetermined)
        #expect(request.requestAgent == "")
    }
}
