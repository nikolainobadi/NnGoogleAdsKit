//
//  UIApplication+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import UIKit

internal extension UIApplication {
    /// Retrieves the topmost view controller in the current window.
    /// - Returns: The top view controller if available, otherwise `nil`.
    func getTopViewController() -> UIViewController? {
        return connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
