
# NnGoogleAdsKit

`NnGoogleAdsKit` is a streamlined Swift package designed to integrate Google Mobile Ads into iOS applications with minimal setup. It enables developers to display app open ads in SwiftUI views effortlessly, with customizable thresholds and event handling.

## Features

- Simplified setup for displaying app open ads within SwiftUI views.
- **Customizable Login Threshold**: Control when ads start appearing by specifying a minimum login count.
- **Delegate Support**: Optional `AdDelegate` for handling ad events like impressions, clicks, dismissals, and errors.

## Installation
Add `NnGoogleAdsKit` to your dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnGoogleAdsKit.git", from: "0.5.0")
]
```

## Usage

### Adding App Open Ads to a SwiftUI View
To display app open ads within a SwiftUI view, apply the `withAppOpenAds` modifier:

```swift
import NnGoogleAdsKit

struct ContentView: View {
    @StateObject var adEventHandler = MyAdEventHandler()
    @AppStorage("AppOpenAdsLoginCount") private var loginCount = 0
    @AppStorage("IsIntialLogin") private var isInitialLogin = true

    var body: some View {
        Text("Welcome to the App!")
            .withAppOpenAds(loginCount: $loginCount, isInitialLogin: $isInitialLogin, delegate: adEventHandler)
    }
}
```

#### Parameters
- `loginCount`: A binding to the login count, which determines when ads should begin appearing.
- `isInitialLogin`: A binding to a Boolean indicating if this is the user's initial login.
- `delegate`: An object conforming to `AdDelegate` to handle ad-related events.
- `loginAdThreshold`: A customizable environment value that sets the minimum login count required before ads are displayed (default is 3).

### Setting a Custom Login Threshold
To modify the default login threshold, use the `loginAdThreshold(_:)` view modifier:

```swift
Text("Main View")
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
    var canShowAds: Bool { !user.isPro }

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

## Contributing
Your feedback and ideas to enhance `NnGoogleAdsKit` are welcome! Please [open an issue](https://github.com/nikolainobadi/NnGoogleAdsKit/issues/new) if you'd like to contribute to this Swift package.

## License
NnGoogleAdsKit is available under the MIT license. See [LICENSE](LICENSE) for details. 
