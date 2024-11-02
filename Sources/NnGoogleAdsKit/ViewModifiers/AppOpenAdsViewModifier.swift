//
//  AppOpenAdsViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

/// A view modifier that tracks login events and displays app open ads based on a specified threshold.
///
/// This modifier observes the login count and displays app open ads once the count meets the specified threshold
/// set in the `loginAdThreshold` environment value.
///
/// - Parameters:
///   - loginCount: A binding to the current login count, which is incremented upon each login.
///   - isInitialLogin: A binding to a Boolean indicating if this is the user’s initial login session.
///   - adENV: An `AppOpenAdsENV` object that manages ad display authorization and functionality.
///   - canShowAds: A Boolean determining whether ads can be shown.
///
/// - Environment Values:
///   - `loginAdThreshold`: The minimum number of logins required before showing ads, with a default of 3.
///   - `scenePhase`: The current scene phase of the view, used to trigger ads when the app becomes active.
struct AppOpenAdsViewModifier: ViewModifier {
    @Binding var loginCount: Int
    @Binding var isInitialLogin: Bool
    @StateObject var adENV: AppOpenAdsENV
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.loginAdThreshold) var loginAdThreshold
    
    /// Displays an ad if the login count meets or exceeds the login ad threshold.
    private func showAd() {
        adENV.showAdIfAuthorized(loginCount: loginCount, threshold: loginAdThreshold)
    }

    func body(content: Content) -> some View {
        content
            .alreadyLoggedInAction(isInitialLogin: $isInitialLogin) {
                loginCount += 1
                showAd()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    showAd()
                }
            }
    }
}

public extension View {
    /// Applies the App Open Ads view modifier to the view.
    ///
    /// This modifier initializes `AppOpenAdsViewModifier` with the provided ad visibility status and delegate,
    /// allowing control over ad display based on the specified login threshold.
    ///
    /// - Parameters:
    ///   - loginCount: A binding to the current login count, allowing incrementing and tracking logins.
    ///   - isInitialLogin: A binding to a Boolean indicating if this is the user’s initial login.
    ///   - delegate: An object conforming to `AdDelegate` for handling ad events and configuration.
    func withAppOpenAds(loginCount: Binding<Int>, isInitialLogin: Binding<Bool>, delegate: AdDelegate) -> some View {
        modifier(AppOpenAdsViewModifier(loginCount: loginCount, isInitialLogin: isInitialLogin, adENV: .init(delegate: delegate)))
    }
}
