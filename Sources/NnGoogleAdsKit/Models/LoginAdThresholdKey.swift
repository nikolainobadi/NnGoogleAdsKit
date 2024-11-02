//
//  LoginAdThresholdKey.swift
//
//
//  Created by Nikolai Nobadi on 11/2/24.
//

import SwiftUI

/// Defines a custom environment key for controlling the login count threshold required to display ads.
///
/// This key allows the app to specify the minimum number of logins a user must complete before ads are displayed,
/// making it possible to set a threshold value that components in the environment can access and modify as needed.
struct LoginAdThresholdKey: EnvironmentKey {
    /// The default threshold value for login count, set to 3.
    /// This means ads will be displayed only after the user has logged in three times, unless overridden.
    static let defaultValue: Int = 3
}

/// Extends `EnvironmentValues` to include the `loginAdThreshold` property, which represents
/// the minimum login count required to trigger ad display.
///
/// Components in the view hierarchy can access or modify this property through the SwiftUI environment,
/// allowing customization of the ad display threshold on a per-view basis.
public extension EnvironmentValues {
    /// The login count threshold for displaying ads.
    ///
    /// By default, this value is 3. You can override it by using the `loginAdThreshold(_:)` view modifier.
    /// Setting this property on a view will apply the threshold for all child views in the hierarchy,
    /// enabling a consistent ad display threshold across relevant components.
    var loginAdThreshold: Int {
        get { self[LoginAdThresholdKey.self] }
        set { self[LoginAdThresholdKey.self] = newValue }
    }
}

/// A view modifier that allows setting the `loginAdThreshold` environment value for ad display.
///
/// This modifier can be applied to any view to override the default login threshold, specifying
/// the number of logins required before ads are shown. Useful for dynamically adjusting the
/// ad threshold based on user behavior or context.
///
/// - Parameter threshold: The minimum number of logins before ads are shown.
/// - Returns: A modified view with the custom login ad threshold applied to its environment.
public extension View {
    func loginAdThreshold(_ threshold: Int) -> some View {
        environment(\.loginAdThreshold, threshold)
    }
}
