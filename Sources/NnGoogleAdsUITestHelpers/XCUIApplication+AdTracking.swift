import XCTest

/// The user's response to the App Tracking Transparency alert during a UI test.
public enum TrackingAlertResponse {
    /// Tap "Ask App Not to Track" to deny tracking permission.
    case denyTracking
    /// Tap "Allow" to grant tracking permission.
    case allowTracking
}

extension XCUIApplication {
    /// Dismisses the iOS App Tracking Transparency alert and taps a "continue" button to proceed past an ad-gated screen.
    ///
    /// Call this early in your UI test launch sequence when your app shows ads that trigger the tracking permission dialog.
    ///
    /// ```swift
    /// let app = XCUIApplication()
    /// app.launch()
    /// app.handleAdTrackingAlert(.denyTracking)
    /// ```
    ///
    /// - Parameters:
    ///   - response: The tracking alert action to take — either ``TrackingAlertResponse/denyTracking`` or ``TrackingAlertResponse/allowTracking``.
    ///   - continueButtonID: The accessibility identifier of the button that appears after the ad loads. Defaults to `"Continue to app"`.
    ///   - alertTimeout: Maximum time in seconds to wait for the tracking alert to appear. Defaults to `3`.
    ///   - continueTimeout: Maximum time in seconds to wait for the continue button to appear after dismissing the alert. Defaults to `10`.
    public func handleAdTrackingAlert(
        _ response: TrackingAlertResponse,
        continueButtonID: String = "Continue to app",
        alertTimeout: TimeInterval = 3,
        continueTimeout: TimeInterval = 10
    ) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        if alert.waitForExistence(timeout: alertTimeout) {
            let buttonLabel: String = switch response {
            case .denyTracking: "Ask App Not to Track"
            case .allowTracking: "Allow"
            }
            alert.scrollViews.buttons[buttonLabel].tap()
        }

        let continueButton = staticTexts[continueButtonID]
        XCTAssertTrue(continueButton.waitForExistence(timeout: continueTimeout), "Continue button not found")
        continueButton.tap()
    }
}
