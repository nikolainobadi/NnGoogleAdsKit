//
//  UIApplication+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import UIKit

internal extension UIApplication {
    func getTopViewController() -> UIViewController? {
        return connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController
    }
}
