//
//  AppOpenAdsViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

/// A view modifier that manages App Open Ad display based on login events and app activity.
///
/// This modifier tracks user logins and shows App Open Ads after a specified number of successful logins,
/// using the `loginAdThreshold` environment value. It also monitors the app’s scene phase to show ads
/// whenever the app becomes active.
///
/// - Important:
///   Apply this modifier only to a **persistent view** that stays active for the duration of the user session (e.g., a main tab view or dashboard).
///   Applying it to transient views (such as views pushed onto a navigation stack) can cause incorrect ad behavior,
///   as it resets the `isInitialLogin` state upon disappearance.
///
/// - Environment Values:
///   - `loginAdThreshold`: The minimum number of logins before ads are eligible to appear (default is 3).
///   - `scenePhase`: Used to detect when the app becomes active and show ads appropriately.
struct AppOpenAdsViewModifier: ViewModifier {
    @Binding var loginCount: Int
    @Binding var isInitialLogin: Bool
    @StateObject var adENV: AppOpenAdsENV
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.loginAdThreshold) private var loginAdThreshold

    let canShowAds: Bool

    private func showAd() async {
        await adENV.showAdIfAuthorized(loginCount: loginCount, threshold: loginAdThreshold, canShowAds: canShowAds)
    }

    func body(content: Content) -> some View {
        content
            .performAfterFirstLogin(isInitialLogin: $isInitialLogin) {
                if loginCount <= loginAdThreshold {
                    loginCount += 1
                }
                
                await showAd()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await showAd()
                    }
                }
            }
    }
}

public extension View {
    /// Tracks user login activity and displays App Open Ads after the login threshold is met.
    ///
    /// This modifier integrates App Open Ad display based on the number of completed logins
    /// and app lifecycle events (e.g., when the app returns to the foreground).
    ///
    /// - Important:
    ///   Attach this modifier to a persistent root view to ensure correct ad display behavior across the user session.
    ///
    /// - Parameters:
    ///   - loginCount: A binding tracking the number of completed user logins.
    ///   - isInitialLogin: A binding indicating whether the current session is the initial login.
    ///   - delegate: An object conforming to `AdDelegate` that manages ad display behavior.
    ///   - canShowAds: A Boolean flag indicating whether ads should be allowed for the current session.
    ///
    /// ### Example
    /// ```swift
    /// struct MainTabView: View {
    ///     @State private var loginCount = 0
    ///     @State private var isInitialLogin = true
    ///
    ///     var body: some View {
    ///         TabView {
    ///             HomeView()
    ///             ProfileView()
    ///         }
    ///         .withAppOpenAds(
    ///             loginCount: $loginCount,
    ///             isInitialLogin: $isInitialLogin,
    ///             delegate: MyAdDelegate(),
    ///             canShowAds: true
    ///         )
    ///     }
    /// }
    /// ```
    func withAppOpenAds(loginCount: Binding<Int>, isInitialLogin: Binding<Bool>, delegate: AdDelegate, canShowAds: Bool) -> some View {
        modifier(
            AppOpenAdsViewModifier(
                loginCount: loginCount,
                isInitialLogin: isInitialLogin,
                adENV: .init(delegate: delegate, adManager: GoogleAdsManager()),
                canShowAds: canShowAds
            )
        )
    }
}
