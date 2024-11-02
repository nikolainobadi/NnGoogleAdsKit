//
//  AppOpenAdsViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

struct AppOpenAdsViewModifier: ViewModifier {
    @StateObject var adENV: AppOpenAdsENV
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("AppOpenAdsLoginCount") private var loginCount = 0
    
    let canShowAds: Bool
    
    init(unitId: String, canShowAds: Bool, delegte: AdDelegate?, loginCountBeforeStartingAds: Int) {
        self.canShowAds = canShowAds
        self._adENV = .init(wrappedValue: .init(adUnitId: unitId, delegate: delegte, loginCountBeforeStartingAds: loginCountBeforeStartingAds))
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
    func withAppOpenAds(adUnitId: String, canShowAds: Bool, delegate: AdDelegate? = nil, loginCountBeforeStartingAds: Int = 3) -> some View {
        modifier(AppOpenAdsViewModifier(unitId: adUnitId, canShowAds: canShowAds, delegte: delegate, loginCountBeforeStartingAds: loginCountBeforeStartingAds))
    }
}

