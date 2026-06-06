//
//  AppOpenAdsENVTests.swift
//  NnGoogleAdsKit
//
//  Created by Nikolai Nobadi on 4/20/25.
//

import Testing
import GoogleMobileAds
import NnSwiftTestingHelpers
@testable import NnGoogleAdsKit

@MainActor
@LeakTracked
final class AppOpenAdsENVTests {
    @Test
    func `Starting values empty`() {
        let (sut, delegate, manager) = makeSUT()
        
        #expect(!sut.isLoadingAd)
        #expect(sut.nextAd == nil)
        #expect(!sut.didInitializeAds)
        #expect(!manager.didInitializeAds)
        #expect(manager.unitIdToLoad == nil)
        #expect(!manager.didRequestTrackingAuth)
        #expect(delegate.recordedEvent == nil)
    }
    
    @Test
    func `Does nothing if ads cannot be shown`() async {
        let (sut, delegate, manager) = makeSUT()
        
        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: false)
        
        #expect(!manager.didInitializeAds)
        #expect(manager.unitIdToLoad == nil)
        #expect(delegate.recordedEvent == nil)
    }
    
    @Test
    func `Initializes Mobile Ads if not initialized`() async {
        let (sut, _, manager) = makeSUT()
        
        await sut.showAdIfAuthorized(loginCount: 2, threshold: 3, canShowAds: true)
        
        #expect(manager.didInitializeAds)
    }
    
    @Test
    func `Requests tracking authorization if auth status not set`() async {
        let (sut, _, manager) = makeSUT(didSetAuthStatus: false)
        
        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: true)
        
        #expect(manager.didRequestTrackingAuth)
    }
    
    @Test
    func `Loads and presents ad if authorized and login count exceeds threshold`() async throws {
        let (sut, delegate, manager) = makeSUT(didSetAuthStatus: true, loadsAd: true)

        await sut.showAdIfAuthorized(loginCount: 5, threshold: 3, canShowAds: true)

        let unitIdToLoad = try #require(manager.unitIdToLoad)
        #expect(unitIdToLoad == delegate.adUnitId)
    }
}

// MARK: - SUT
private extension AppOpenAdsENVTests {
    func makeSUT(adUnitId: String = "myAddUnitId", didSetAuthStatus: Bool = false, loadsAd: Bool = false, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (sut: AppOpenAdsENV, delegate: MockDelegate, manager: MockManager) {
        let delegate = MockDelegate(adUnitId: adUnitId)
        let manager = MockManager(adToLoad: loadsAd ? MockAppOpenAd() : nil, didSetAuthStatus: didSetAuthStatus)
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
        private(set) var recordedEvent: String?

        init(adUnitId: String) {
            self.adUnitId = adUnitId
        }

        func adDidDismiss() {
            recordedEvent = "adDidDismiss"
        }

        func adWillDismiss() {
            recordedEvent = "adWillDismiss"
        }

        func adDidRecordClick() {
            recordedEvent = "adDidRecordClick"
        }

        func adDidRecordImpression() {
            recordedEvent = "adDidRecordImpression"
        }

        func adFailedToPresent(error: Error) {
            recordedEvent = "adFailedToPresent"
        }
    }
    
    final class MockAppOpenAd: AppOpenAd, @unchecked Sendable { }
}
