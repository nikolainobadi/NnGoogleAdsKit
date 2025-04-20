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
    private let futureDate = Date.from(year: 2099, month: 1, day: 1)
}


// MARK: - Unit Tests
extension FullScreenAdInfoTests {
    @Test("Defaults set correctly on init")
    func defaultsAreCorrect() {
        let sut = makeSUT()
        
        #expect(sut.freshnessInterval == 4 * 3600)
        #expect(abs(sut.loadTime.timeIntervalSinceNow) < 1)
        #expect(!sut.isExpired)
    }

    @Test("Custom parameters set correctly on init")
    func customInitSetsParameters() {
        let sut = makeSUT(loadTime: oldDate, freshnessInterval: 100)
        
        #expect(sut.loadTime == oldDate)
        #expect(sut.freshnessInterval == 100)
    }

    @Test("isExpired returns false when ad is fresh")
    func isExpiredIsFalseWhenFresh() {
        #expect(!makeSUT(loadTime: Date()).isExpired)
    }

    @Test("isExpired returns true when ad is expired")
    func isExpiredIsTrueWhenExpired() {
        #expect(makeSUT(loadTime: oldDate, freshnessInterval: 3600).isExpired)
    }

    @Test("Equatable returns true when ids match")
    func equatableReturnsTrueWhenIDsMatch() {
        let id = UUID().uuidString
        let sut1 = makeSUT(id: id)
        let sut2 = makeSUT(id: id)
        
        #expect(sut1 == sut2)
    }

    @Test("Equatable returns false when ids differ")
    func equatableReturnsFalseWhenIDsDiffer() {
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
extension Date {
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
