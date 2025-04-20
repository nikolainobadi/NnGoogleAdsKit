//
//  AppOpenAdsENVTests.swift
//  NnGoogleAdsKit
//
//  Created by Nikolai Nobadi on 4/20/25.
//

import Testing
import Foundation
import GoogleMobileAds
import NnSwiftTestingHelpers
@testable import NnGoogleAdsKit

@MainActor
final class AppOpenAdsENVTests: TrackingMemoryLeaks {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (sut, delegate, manager) = makeSUT()
        
        #expect(!sut.isLoadingAd)
        #expect(sut.nextAd == nil)
        #expect(!sut.didInitializeAds)
        #expect(!manager.didInitializeAds)
        #expect(manager.unitIdToLoad == nil)
        #expect(!manager.didRequestTrackingAuth)
        #expect(delegate.recordedEvents.isEmpty)
    }
    
    @Test("Does nothing if ads cannot be shown")
    func doesNothingIfCannotShowAds() async {
        let (sut, delegate, manager) = makeSUT()
        
        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: false)
        
        #expect(!manager.didInitializeAds)
        #expect(manager.unitIdToLoad == nil)
        #expect(delegate.recordedEvents.isEmpty)
    }
    
    @Test("Initializes Mobile Ads if not initialized")
    func initializesMobileAdsOnFirstAttempt() async {
        let (sut, _, manager) = makeSUT()
        
        await sut.showAdIfAuthorized(loginCount: 2, threshold: 3, canShowAds: true)
        
        #expect(manager.didInitializeAds)
    }
    
    @Test("Requests tracking authorization if auth status not set")
    func requestsTrackingAuthorizationIfNeeded() async {
        let (sut, _, manager) = makeSUT(didSetAuthStatus: false)
        
        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: true)
        
        #expect(manager.didRequestTrackingAuth)
    }
    
    @Test("Loads and presents ad if authorized and login count exceeds threshold")
    func loadsAndPresentsAdWhenEligible() async {
        let (sut, delegate, manager) = makeSUT(didSetAuthStatus: true, adToLoad: MockAppOpenAd())
        
        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: true)
        
        #expect(manager.unitIdToLoad == delegate.adUnitId)
    }
}

// MARK: - SUT
private extension AppOpenAdsENVTests {
    func makeSUT(adUnitId: String = "myAddUnitId", didSetAuthStatus: Bool = false, adToLoad: AppOpenAd? = nil, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (sut: AppOpenAdsENV, delegate: MockDelegate, manager: MockManager) {
        let delegate = MockDelegate(adUnitId: adUnitId)
        let manager = MockManager(adToLoad: adToLoad, didSetAuthStatus: didSetAuthStatus)
        let sut = AppOpenAdsENV(delegate: delegate, adManager: manager)
        
        trackForMemoryLeaks(sut, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(manager, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(delegate, fileID: fileID, filePath: filePath, line: line, column: column)
        
        return (sut, delegate, manager)
    }
}

// MARK: - Mocks
private extension AppOpenAdsENVTests {
    final class MockManager: AdService, @unchecked Sendable {
        private let adToLoad: AppOpenAd?
        private(set) var unitIdToLoad: String?
        private(set) var didInitializeAds = false
        private(set) var didRequestTrackingAuth = false
        
        let didSetAuthStatus: Bool
        
        init(adToLoad: AppOpenAd?, didSetAuthStatus: Bool) {
            self.adToLoad = adToLoad
            self.didSetAuthStatus = didSetAuthStatus
        }
        
        func initializeMobileAds() {
            didInitializeAds = true
        }
        
        func requestTrackingAuthorization() async {
            didRequestTrackingAuth = true
        }
        
        func loadAppOpenAd(unitId: String) async -> AppOpenAd? {
            unitIdToLoad = unitId
            return adToLoad
        }
    }
    
    final class MockDelegate: AdDelegate {
        let adUnitId: String
        private(set) var recordedEvents: [String] = []
        
        init(adUnitId: String) {
            self.adUnitId = adUnitId
        }
        
        func adDidDismiss() {
            recordedEvents.append("adDidDismiss")
        }
        
        func adWillDismiss() {
            recordedEvents.append("adWillDismiss")
        }
        
        func adDidRecordClick() {
            recordedEvents.append("adDidRecordClick")
        }
        
        func adDidRecordImpression() {
            recordedEvents.append("adDidRecordImpression")
        }
        
        func adFailedToPresent(error: Error) {
            recordedEvents.append("adFailedToPresent")
        }
    }
    
    final class MockAppOpenAd: AppOpenAd, @unchecked Sendable { }
}
