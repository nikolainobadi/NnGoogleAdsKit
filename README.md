
# NnGoogleAdsKit

![Unit Tests](https://github.com/nikolainobadi/NnGoogleAdsKit/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0%2B/purple)
![Platform](https://img.shields.io/badge/iOS-17%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

`NnGoogleAdsKit` is a streamlined Swift package designed to integrate Google Mobile Ads into iOS applications with minimal setup. It enables developers to display app open ads in SwiftUI views effortlessly, with customizable thresholds and event handling.

## Why Use NnGoogleAdsKit?

Integrating Google App Open Ads with SwiftUI can be tedious and error-prone. `NnGoogleAdsKit` abstracts the setup into clean, testable, and customizable components, letting you focus on your app, not ad management.


## Features

- Simplified setup for displaying app open ads within SwiftUI views.
- **Customizable Login Threshold**: Control when ads start appearing by specifying a minimum login count.
- **Delegate Support**: Optional `AdDelegate` for handling ad events like impressions, clicks, dismissals, and errors.

## Installation
Add `NnGoogleAdsKit` to your dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnGoogleAdsKit.git", from: "0.7.0")
]
```

## Usage

**Important**: Use the `withAppOpenAds` modifier only on views that will remain visible until the user logs out. If the view disappears (e.g., due to navigation), the login state may reset, which could lead to unintended behavior with app open ad display logic.

### Adding App Open Ads to a SwiftUI View
To display app open ads within a SwiftUI view, apply the `withAppOpenAds` modifier. Here’s an example that conditionally shows either a `LoginView` or an `InAppView` based on the user’s login state:

```swift
import SwiftUI
import NnGoogleAdsKit

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var user = User(isPro: false)
    @AppStorage("AppOpenAdsLoginCount") private var loginCount = 0
    @AppStorage("IsInitialLogin") private var isInitialLogin = true

    var body: some View {
        if isLoggedIn {
            InAppView(onLogout: { isLoggedIn = false })
                .withAppOpenAds(
                    loginCount: $loginCount,
                    isInitialLogin: $isInitialLogin,
                    delegate: MyAdEventHandler(),
                    canShowAds: !user.isPro
                )
        } else {
            LoginView(onLogin: { isLoggedIn = true })
        }
    }
}

```

In this example:
- `ContentView` tracks the `isLoggedIn` state to determine whether to display the `LoginView` or `InAppView`.
- When the user logs in, `InAppView` is shown with the `withAppOpenAds` modifier applied, enabling the app open ads functionality.
- `InAppView` remains visible as long as the user is logged in, making it an ideal place for the `withAppOpenAds` modifier to work reliably.
- The `canShowAds` parameter is set based on whether the user is pro. Ads will only shown to non-pro users.

#### Parameters
- `loginCount`: A binding to the login count, which determines when ads should begin appearing.
- `isInitialLogin`: A binding to a Boolean indicating if this is the user's initial login.
- `delegate`: An object conforming to `AdDelegate` to handle ad-related events.
- `canShowAds`: A Boolean that controls whether ads can be displayed.
- `loginAdThreshold`: A customizable environment value that sets the minimum login count required before ads are displayed (default is 3).

### Setting a Custom Login Threshold
To modify the default login threshold, use the `loginAdThreshold(_:)` view modifier:

```swift
InAppView()
    .withAppOpenAds(loginCount: $loginCount, isInitialLogin: $isInitialLogin, delegate: adDelegate)
    .loginAdThreshold(5) // Require 5 logins before showing ads
```

### Handling Ad Events with `AdDelegate`
To respond to ad events like clicks, impressions, and dismissals, implement the `AdDelegate` protocol in your class:

```swift
import NnGoogleAdsKit

final class MyAdEventHandler: ObservableObject {
    @Published var user: User
}

extension MyAdEventHandler: AdDelegate {
    var adUnitId: String { "ca-app-pub-3940256099942544/5575463023" }

    func adDidRecordClick() {
        print("Ad was clicked.")
    }

    func adDidRecordImpression() {
        print("Ad impression recorded.")
    }

    func adWillDismiss() {
        print("Ad will dismiss.")
    }

    func adDidDismiss() {
        print("Ad was dismissed.")
    }

    func adFailedToPresent(error: Error) {
        print("Failed to present ad: \(error.localizedDescription)")
    }
}
```

Then, pass an instance of your `AdDelegate` when applying the `withAppOpenAds` modifier.

## Dependencies

`NnGoogleAdsKit` depends on the following external libraries:

- [GoogleMobileAds](https://developers.google.com/admob/ios/quick-start) (Google Mobile Ads SDK for iOS)
- [NnTestKit](https://github.com/nikolainobadi/NnTestKit) (for internal testing utilities)

> NnGoogleAdsKit was built against:
> - Google Mobile Ads SDK version 12.0.0 or later
> - NnTestKit version 1.0.0 or later

## Contributing
Your feedback and ideas to enhance `NnGoogleAdsKit` are welcome! Please [open an issue](https://github.com/nikolainobadi/NnGoogleAdsKit/issues) if you'd like to contribute to this Swift package.

## License
NnGoogleAdsKit is available under the MIT license. See [LICENSE](LICENSE) for details.

