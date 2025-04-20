//
//  PostInitialLoginActionViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 11/1/24.
//

import SwiftUI

/// A view modifier that distinguishes between a user's initial and subsequent logins,
/// triggering an action only after the first login has completed.
///
/// On the first appearance (when `isInitialLogin` is `true`), the modifier resets `isInitialLogin` to `false`
/// without executing the provided action. On subsequent appearances (when `isInitialLogin` is `false`),
/// it executes the provided action to perform any post-login behaviors.
///
/// When the view disappears, `isInitialLogin` is reset to `true` to prepare for the next login cycle.
struct PostInitialLoginActionViewModifier: ViewModifier {
    @Binding var isInitialLogin: Bool
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                if isInitialLogin {
                    isInitialLogin = false
                } else {
                    await action()
                }
            }
            .onDisappear {
                isInitialLogin = true
            }
    }
}

extension View {
    /// Performs an action after the user’s first login by distinguishing between initial and subsequent view appearances.
    ///
    /// Use this modifier when you want an action to **only** trigger after the user has already logged in once,
    /// such as refreshing data, syncing state, or updating the UI on repeat appearances.
    ///
    /// - Parameters:
    ///   - isInitialLogin: A binding that tracks whether this is the user's initial login.
    ///   - action: The action to trigger on appearances **after** the initial login.
    /// - Returns: A view that triggers the action after the first login cycle is complete.
    ///
    /// ### Example
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var isInitialLogin = true
    ///
    ///     var body: some View {
    ///         MainView()
    ///             .performAfterFirstLogin(isInitialLogin: $isInitialLogin) {
    ///                 refreshUserData()
    ///             }
    ///     }
    ///
    ///     func refreshUserData() {
    ///         print("Refreshing user data...")
    ///     }
    /// }
    /// ```
    func performAfterFirstLogin(isInitialLogin: Binding<Bool>, action: @escaping () async -> Void) -> some View {
        modifier(PostInitialLoginActionViewModifier(isInitialLogin: isInitialLogin, action: action))
    }
}
