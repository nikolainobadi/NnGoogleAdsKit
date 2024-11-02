
# NnGoogleAdsKit

`NnGoogleAdsKit` is a streamlined Swift package designed to integrate Google Mobile Ads into iOS applications with minimal setup. It enables developers to display app open ads in SwiftUI views effortlessly.

## Features

- Simplified setup for displaying app open ads within SwiftUI views.
- Customizable login threshold to control when ads start appearing.
- Optional delegate for handling ad events (e.g., impressions, clicks, dismissals).

## Installation
```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnGoogleAdsKit.git", from: "0.5.0")
]
```

## Usage

### Adding App Open Ads to a SwiftUI View
To display app open ads within a SwiftUI view, simply apply the `withAppOpenAds` modifier:

```swift
import NnGoogleAdsKit

struct ContentView: View {
    @State private var canShowAds = true

    var body: some View {
        Text("Welcome to the App!")
            .withAppOpenAds(adUnitId: "ca-app-pub-3940256099942544/5575463023", canShowAds: canShowAds)
    }
}
```

#### Parameters
- `adUnitId`: The Google ad unit ID for displaying ads.
- `canShowAds`: A Boolean indicating if ads can be shown.
- `delegate`: An optional `AdDelegate` to handle ad-related events.
- `loginCountBeforeStartingAds`: The required number of user logins before ads begin to appear (default is 3).

### Handling Ad Events with `AdDelegate`
To respond to ad events like clicks, impressions, and dismissals, implement the `AdDelegate` protocol in your class:

```swift
import NnGoogleAdsKit

class MyAdEventHandler: AdDelegate {
    func adDidRecordClick() {
        print("Ad was clicked.")
    }

    func adDidRecordImpression() {
        print("Ad impression recorded.")
    }

    func adWillDismiss() {
        print("Ad will dismiss.")
    }

    func adFailedToPresent(error: Error) {
        print("Failed to present ad: \(error.localizedDescription)")
    }
}
```

Then, pass an instance of your `AdDelegate` when applying the modifier:

```swift
Text("Main View")
    .withAppOpenAds(adUnitId: "your-ad-unit-id", canShowAds: true, delegate: MyAdEventHandler())
```

## Contributing
Any feedback or ideas to enhance `NnGoogleAdsKit` would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/NnGoogleAdsKit/issues/new) if you'd like to help improve this swift package.

## License
NnGoogleAdsKit is available under the MIT license. See [LICENSE](LICENSE) for details.
