//
//  InitialLoginViewModifier.swift
//  
//
//  Created by Nikolai Nobadi on 11/1/24.
//

import SwiftUI

/// A view modifier that triggers an action based on whether the user is logging in for the first time.
struct InitialLoginViewModifier: ViewModifier {
    @Binding var loggedInCount: Int
    @Binding var isInitialLogin: Bool

    /// Action to perform when the user is not logging in for the first time.
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
                loggedInCount = 0
                isInitialLogin = true
            }
    }
}

extension View {
    /// Applies the Initial Login Action modifier, triggering an action if the user is already logged in.
    /// - Parameters:
    ///   - loggedInCount: The count of login attempts.
    ///   - action: The action to trigger if the user is not logging in for the first time.
    func alreadyLoggedInAction(loggedInCount: Binding<Int>, isInitialLogin: Binding<Bool>, action: @escaping () -> Void) -> some View {
        modifier(InitialLoginViewModifier(loggedInCount: loggedInCount, isInitialLogin: isInitialLogin, action: action))
    }
}
