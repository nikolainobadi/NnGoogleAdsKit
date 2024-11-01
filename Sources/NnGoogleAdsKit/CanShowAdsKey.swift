//
//  CanShowAdsKey.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

struct CanShowAdsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var canShowAds: Bool {
        get { self[CanShowAdsKey.self] }
        set { self[CanShowAdsKey.self] = newValue }
    }
}
