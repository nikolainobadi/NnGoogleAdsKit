//
//  AppOpenAdsViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

/// A view modifier that tracks login events and displays app open ads when allowed.
struct AppOpenAdsViewModifier: ViewModifier {
    @StateObject var adENV: AppOpenAdsENV
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("AppOpenAdsLoginCount") private var loginCount = 0

    /// Determines if ads can be displayed.
    let canShowAds: Bool

    /// Initializes the ad view modifier.
    /// - Parameters:
    ///   - unitId: The ad unit ID for app open ads.
    ///   - canShowAds: A Boolean indicating whether ads are allowed.
    ///   - delegate: An optional delegate for ad events.
    ///   - loginCountBeforeStartingAds: The login count threshold before ads display.
    init(unitId: String, canShowAds: Bool, delegate: AdDelegate?, loginCountBeforeStartingAds: Int) {
        self.canShowAds = canShowAds
        self._adENV = .init(wrappedValue: .init(adUnitId: unitId, delegate: delegate, loginCountBeforeStartingAds: loginCountBeforeStartingAds))
    }

    func body(content: Content) -> some View {
        content
            .alreadyLoggedInAction(loggedInCount: $loginCount) {
                loginCount += 1
                adENV.showAdIfAuthorized(loginCount: loginCount)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active, canShowAds {
                    adENV.showAdIfAuthorized(loginCount: loginCount)
                }
            }
    }
}

public extension View {
    /// Applies the App Open Ads view modifier to the view.
    /// - Parameters:
    ///   - adUnitId: The ad unit ID for displaying ads.
    ///   - canShowAds: A Boolean indicating if ads can be shown.
    ///   - delegate: An optional delegate for ad events.
    ///   - loginCountBeforeStartingAds: The required login count before ads can display.
    func withAppOpenAds(adUnitId: String, canShowAds: Bool, delegate: AdDelegate? = nil, loginCountBeforeStartingAds: Int = 3) -> some View {
        modifier(AppOpenAdsViewModifier(unitId: adUnitId, canShowAds: canShowAds, delegate: delegate, loginCountBeforeStartingAds: loginCountBeforeStartingAds))
    }
}
