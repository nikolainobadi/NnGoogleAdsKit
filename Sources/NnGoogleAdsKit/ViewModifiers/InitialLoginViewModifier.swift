//
//  InitialLoginViewModifier.swift
//  
//
//  Created by Nikolai Nobadi on 11/1/24.
//

import SwiftUI

/// A view modifier that triggers an action based on whether the user is logging in for the first time.
///
/// This modifier checks the `isInitialLogin` binding to determine if the user is logging in for the first time:
/// - If `isInitialLogin` is `true`, it updates `isInitialLogin` to `false` without triggering the action, indicating the user's first login.
/// - If `isInitialLogin` is `false`, it performs the specified action, marking the user as already logged in.
///
/// This setup allows distinct behaviors for initial versus subsequent logins.
struct InitialLoginViewModifier: ViewModifier {
    @Binding var isInitialLogin: Bool

    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isInitialLogin {
                    isInitialLogin = false
                } else {
                    action()
                }
            }
            .onDisappear {
                isInitialLogin = true
            }
    }
}

extension View {
    /// Applies the Initial Login Action modifier, triggering an action if the user is already logged in.
    ///
    /// - Parameters:
    ///   - isInitialLogin: A binding indicating if this is the user’s initial login. When `false`, the action is triggered.
    ///   - action: The action to trigger if the user is not logging in for the first time.
    /// - Returns: A view with the `InitialLoginViewModifier` applied, differentiating behavior for initial versus repeat logins.
    func alreadyLoggedInAction(isInitialLogin: Binding<Bool>, action: @escaping () -> Void) -> some View {
        modifier(InitialLoginViewModifier(isInitialLogin: isInitialLogin, action: action))
    }
}
