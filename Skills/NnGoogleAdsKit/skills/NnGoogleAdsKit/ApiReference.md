# NnGoogleAdsKit API Reference

SwiftUI integration for Google App Open Ads with login-count-gated display and ATT-aware ad requests.

---

## Protocol: AdDelegate

Delegate protocol for receiving app open ad lifecycle events. Only `adUnitId` is required — all callback methods have default no-op implementations.

```swift
public protocol AdDelegate {
    var adUnitId: String { get }
    func adDidDismiss()
    func adWillDismiss()
    func adDidRecordClick()
    func adDidRecordImpression()
    func adFailedToPresent(error: Error)
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `adUnitId` | `String` | The Google Ads unit ID for app open ads. Ignored in DEBUG builds (test ID used instead) |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `adDidDismiss()` | `Void` | Called after the ad is dismissed. Default: no-op |
| `adWillDismiss()` | `Void` | Called before the ad dismisses. Default: no-op |
| `adDidRecordClick()` | `Void` | Called when the user taps the ad. Default: no-op |
| `adDidRecordImpression()` | `Void` | Called when the ad records an impression. Default: no-op |
| `adFailedToPresent(error:)` | `Void` | Called when ad presentation fails. A replacement ad begins loading immediately after this callback. Default: no-op |

### Usage Example

```swift
struct MyAdDelegate: AdDelegate {
    var adUnitId: String { "ca-app-pub-XXXXX/YYYYY" }

    func adDidRecordImpression() {
        analytics.trackAdImpression()
    }

    func adFailedToPresent(error: Error) {
        logger.error("Ad failed: \(error)")
    }
}
```

### Ad Lifecycle Flow

When an ad fails to present, the internal `AppOpenAdsENV` automatically spawns a background task to load a replacement ad. This means `adFailedToPresent(error:)` is followed by an implicit reload — you do not need to trigger a reload yourself.

The full callback sequence for a successful ad display is:
1. `adDidRecordImpression()` — ad appeared on screen
2. `adDidRecordClick()` — only if user tapped the ad
3. `adWillDismiss()` — ad is about to close
4. `adDidDismiss()` — ad has closed; `nextAd` is set to nil

---

## Extension: EnvironmentValues — loginAdThreshold

SwiftUI environment value controlling the minimum login count before ads are eligible to show.

```swift
public extension EnvironmentValues {
    var loginAdThreshold: Int { get set }  // default: 3
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `loginAdThreshold` | `Int` | Minimum login count before ads display. Ads show when `loginCount > loginAdThreshold`. Default: `3` |

### Usage Example

```swift
ContentView()
    .loginAdThreshold(5)  // require 6+ logins before showing ads
```

---

## Extension: View — loginAdThreshold

Convenience modifier to set the login ad threshold in the SwiftUI environment.

```swift
public extension View {
    func loginAdThreshold(_ threshold: Int) -> some View
}
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `threshold` | `Int` | Minimum login count before ads appear (default: 3) |

### Usage Example

```swift
MainTabView()
    .loginAdThreshold(5)
    .withAppOpenAds(
        loginCount: $loginCount,
        isInitialLogin: $isInitialLogin,
        delegate: MyAdDelegate(),
        canShowAds: true
    )
```

---

## Extension: View — withAppOpenAds

Primary entry point for attaching app open ad display logic to a SwiftUI view hierarchy.

```swift
public extension View {
    func withAppOpenAds(
        loginCount: Binding<Int>,
        isInitialLogin: Binding<Bool>,
        delegate: AdDelegate,
        canShowAds: Bool,
        debugEnabled: Bool = false
    ) -> some View
}
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `loginCount` | `Binding<Int>` | Persistent login counter. Incremented automatically up to `threshold + 1` |
| `isInitialLogin` | `Binding<Bool>` | Tracks whether the current session is the first login. Reset on view disappear |
| `delegate` | `AdDelegate` | Your ad delegate providing the ad unit ID and lifecycle callbacks |
| `canShowAds` | `Bool` | Master toggle. When `false`, no ads SDK initialization occurs at all |
| `debugEnabled` | `Bool` | Opt-in console logging of ad lifecycle details. Default: `false` (completely silent) |

### Usage Example

```swift
@main
struct MyApp: App {
    @AppStorage("loginCount") private var loginCount = 0
    @State private var isInitialLogin = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withAppOpenAds(
                    loginCount: $loginCount,
                    isInitialLogin: $isInitialLogin,
                    delegate: MyAdDelegate(),
                    canShowAds: purchaseManager.showAds
                )
                .loginAdThreshold(3)
        }
    }
}
```

### Ad Display Decision Tree

The internal `showAdIfAuthorized` method evaluates this sequence on every trigger:

1. `canShowAds == false` → **exit** (no SDK initialization, no ad)
2. First eligible call → initializes Google Mobile Ads SDK (once per app lifetime)
3. `loginCount <= loginAdThreshold` → **exit** (threshold not met)
4. ATT status is `.notDetermined` → requests tracking authorization, then **exit** (no ad this invocation)
5. ATT status is determined → loads ad (if none cached or cached ad expired), presents it

### Dual Trigger Paths

| Trigger | loginCount incremented? | When |
|---------|------------------------|------|
| Login (view re-appearance) | Yes, if `<= threshold` | After `isInitialLogin` flips to `false` on second+ appearance |
| Foreground return | No | Every `scenePhase` transition to `.active` |

### isInitialLogin State Machine

| Event | isInitialLogin before | Action | isInitialLogin after |
|-------|----------------------|--------|---------------------|
| View appears (first time) | `true` | Skip ad logic, flip flag | `false` |
| View appears (subsequent) | `false` | Increment loginCount, show ad | `false` |
| View disappears | any | Reset for next cycle | `true` |

The ad logic **never runs on the very first appearance** after app launch. It starts on the second `.task` execution (after navigation away and back, or re-login).

### Ad Caching & Expiration

Loaded ads are cached as `FullScreenAdInfo` with a 4-hour freshness interval. If a cached ad exists and is not expired, it is reused without a network request. Expiration uses strict comparison: an ad exactly at the freshness boundary is still considered fresh.

### Debug Logging

Pass `debugEnabled: true` to print ad lifecycle details to the console, prefixed with `[NnGoogleAdsKit]`. Nothing is printed when `false` (the default). The flag is threaded internally into both the ad environment (flow decisions) and the ads manager (SDK calls).

Logged events cover every step and exit of the decision tree above:

| Layer | Logged events |
|-------|---------------|
| Flow | `canShowAds` exit, SDK init trigger, threshold exit (with counts), ATT request branch, cached-ad reuse, load start/success/failure, duplicate-load skip, presentation, missing top view controller, ad dismissal, failed-to-present (with error) |
| SDK | Mobile Ads SDK start, ATT request + resulting status raw value, resolved ad unit id (shows the test-ID substitution in DEBUG builds) |

This makes `debugEnabled: true` the primary tool for diagnosing "why isn't my ad showing?" — the console output identifies exactly which decision-tree step exited.

```swift
.withAppOpenAds(
    loginCount: $loginCount,
    isInitialLogin: $isInitialLogin,
    delegate: MyAdDelegate(),
    canShowAds: true,
    debugEnabled: true
)
```

---

## Library: NnGoogleAdsUITestHelpers

A separate product for UI test targets. It links `XCTest`, so add it **only** to a UI test target, never to the app target.

```swift
import NnGoogleAdsUITestHelpers
```

### Enum: TrackingAlertResponse

```swift
public enum TrackingAlertResponse {
    case denyTracking   // taps "Ask App Not to Track"
    case allowTracking  // taps "Allow"
}
```

### Extension: XCUIApplication — handleAdTrackingAlert

Dismisses the App Tracking Transparency alert (via Springboard) and then taps a "continue" element that your app shows after the ad flow.

```swift
extension XCUIApplication {
    public func handleAdTrackingAlert(
        _ response: TrackingAlertResponse,
        continueButtonID: String = "Continue to app",
        alertTimeout: TimeInterval = 3,
        continueTimeout: TimeInterval = 10
    )
}
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `response` | `TrackingAlertResponse` | Which ATT alert button to tap |
| `continueButtonID` | `String` | Identifier/label looked up in `staticTexts` after the alert. Default: `"Continue to app"` |
| `alertTimeout` | `TimeInterval` | Seconds to wait for the ATT alert. Default: `3` |
| `continueTimeout` | `TimeInterval` | Seconds to wait for the continue element. Default: `10` |

### Behavior

- **Missing alert is tolerated** — if no alert appears within `alertTimeout` (e.g. ATT already determined on that simulator), it skips straight to the continue step.
- **Missing continue element fails the test** — it `XCTAssertTrue`s that the continue element exists, then taps it. Your app must expose a matching `staticTexts` element after the ad flow.

### Usage Example

```swift
let app = XCUIApplication()
app.launch()
app.handleAdTrackingAlert(.denyTracking)
```

---

## Best Practices

- **Set `canShowAds` to `false` for non-ad users** — When `canShowAds` is `false`, the Google Mobile Ads SDK is never initialized. This avoids unnecessary SDK overhead for users who purchased an ad-free tier.
- **Persist `loginCount` with `@AppStorage`** — The login counter must survive app termination. Use `@AppStorage` or another persistence mechanism to avoid resetting the count.
- **Only `adUnitId` is required on `AdDelegate`** — All five lifecycle callbacks default to no-ops. Only implement the ones you need (e.g., analytics tracking on impression).
- **First ATT prompt consumes a trigger** — When the ATT dialog is shown (first eligible ad attempt), no ad displays on that invocation. The ad will show on the next trigger (foreground return or next login).
- **DEBUG builds ignore your `adUnitId`** — The Google test ad unit ID is hardcoded in debug builds. Your real ad unit is only used in release builds.
- **Troubleshoot with `debugEnabled: true`** — Ad display is silent by default; the debug flag prints every decision-tree step and failure path with a `[NnGoogleAdsKit]` prefix. Turn it off (or just omit it) for production.
- **Failed ad loads block future loads** — If a network ad load fails (returns nil), the internal `isLoadingAd` flag remains `true` for that instance's lifetime. Subsequent load attempts return nil immediately. This is mitigated by the view modifier creating a fresh `AppOpenAdsENV` on each `withAppOpenAds` call.
- **`loginCount` is self-capping** — The counter only increments while `<= threshold`, reaching at most `threshold + 1`. It will not grow unbounded.
- **Attach `.withAppOpenAds` to a persistent root view** — The modifier tracks login state and scene phase. Applying it to transient views (e.g., pushed navigation destinations) resets state incorrectly and causes unpredictable ad behavior.
- **No ad if no key window** — If `UIApplication` has no foreground active key window (e.g., the app is backgrounded during the async ad load), the ad is silently dropped with no callback.
