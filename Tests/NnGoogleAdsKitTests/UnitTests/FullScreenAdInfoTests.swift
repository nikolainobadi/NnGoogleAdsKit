//
//  FullScreenAdInfoTests.swift
//  NnGoogleAdsKit
//
//  Created by Nikolai Nobadi on 4/20/25.
//

import Testing
import Foundation
import GoogleMobileAds
@testable import NnGoogleAdsKit

struct FullScreenAdInfoTests {
    private let oldDate = Date.from(year: 2020, month: 1, day: 1)

    @Test
    func `Defaults set correctly on init`() {
        let sut = makeSUT()

        #expect(sut.freshnessInterval == 4 * 3600)
        #expect(abs(sut.loadTime.timeIntervalSinceNow) < 1)
        #expect(!sut.isExpired)
    }

    @Test
    func `Custom parameters set correctly on init`() {
        let interval: TimeInterval = 100
        let sut = makeSUT(loadTime: oldDate, freshnessInterval: interval)

        #expect(sut.loadTime == oldDate)
        #expect(sut.freshnessInterval == interval)
    }

    @Test
    func `Ad is not expired when fresh`() {
        #expect(!makeSUT(loadTime: Date()).isExpired)
    }

    @Test
    func `Ad is expired when freshness interval has elapsed`() {
        #expect(makeSUT(loadTime: oldDate, freshnessInterval: 3600).isExpired)
    }

    @Test
    func `Ads with matching ids are equal`() {
        let id = UUID().uuidString
        let sut1 = makeSUT(id: id)
        let sut2 = makeSUT(id: id)
        
        #expect(sut1 == sut2)
    }

    @Test
    func `Ads with different ids are not equal`() {
        #expect(makeSUT() != makeSUT())
    }
}

// MARK: - SUT
private extension FullScreenAdInfoTests {
    func makeSUT(ad: MockAd = .init(), id: String = UUID().uuidString, loadTime: Date = Date(), freshnessInterval: TimeInterval = 4 * 3600) -> FullScreenAdInfo<MockAd> {
        return .init(ad: ad, id: id, loadTime: loadTime, freshnessInterval: freshnessInterval)
    }
}


// MARK: - Mocks
private extension FullScreenAdInfoTests {
    final class MockAd: NSObject, FullScreenPresentingAd {
        var fullScreenContentDelegate: (any FullScreenContentDelegate)?
    }
}


// MARK: - Helpers
private extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
