//
//  InitialLoginViewModifier.swift
//  
//
//  Created by Nikolai Nobadi on 11/1/24.
//

import SwiftUI

struct InitialLoginViewModifier: ViewModifier {
    @Binding var loggedInCount: Int
    @AppStorage("IsInitialLogin") private var isInitialLogin = true
    
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
    func alreadyLoggedInAction(loggedInCount: Binding<Int>, action: @escaping () -> Void) -> some View {
        modifier(InitialLoginViewModifier(loggedInCount: loggedInCount, action: action))
    }
}
