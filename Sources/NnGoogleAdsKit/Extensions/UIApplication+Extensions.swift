//
//  UIApplication+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import UIKit

@MainActor
internal extension UIApplication {
    /// Retrieves the topmost view controller in the current window.
    /// - Returns: The top view controller if available, otherwise `nil`.
    func getTopViewController() -> UIViewController? {
        var topController = connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
