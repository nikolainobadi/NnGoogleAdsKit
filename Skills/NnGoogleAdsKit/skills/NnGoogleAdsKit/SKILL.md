---
name: NnGoogleAdsKit
description: NnGoogleAdsKit Swift API reference for Google App Open Ads in SwiftUI. USE WHEN implementing app open ads, AdDelegate, loginAdThreshold, withAppOpenAds, Google Ads integration, ad display on login, SwiftUI ad view modifier, debugEnabled, troubleshooting ads not showing, ad debug logging, NnGoogleAdsUITestHelpers, handleAdTrackingAlert, TrackingAlertResponse, dismissing the tracking alert in UI tests.
user-invocable: true
---

# NnGoogleAdsKit

SwiftUI wrapper for Google Mobile Ads App Open Ads with login-count-based display logic.

**Repo:** `https://github.com/nikolainobadi/NnGoogleAdsKit.git`
**Platforms:** iOS 17+ | **Swift:** 6.0
**Products:** `NnGoogleAdsKit` (app target) · `NnGoogleAdsUITestHelpers` (UI test target only — links XCTest)

## Context Files

| File | Purpose | Load When |
|------|---------|-----------|
| `ApiReference.md` | Full API surface, behavioral docs, best practices, UI test helpers | Implementing or debugging app open ads, or UI-testing an ad-gated app |

## Quick Reference

- **Entry point:** `View.withAppOpenAds(loginCount:isInitialLogin:delegate:canShowAds:debugEnabled:)` — attaches ad display logic to any SwiftUI view
- **AdDelegate protocol** — requires only `adUnitId: String`; all 5 lifecycle callbacks have default no-op implementations
- **Login threshold** — ads only show after `loginCount > loginAdThreshold` (default: 3); set via `.loginAdThreshold(_:)` modifier
- **Dual trigger paths** — ads trigger on login (with count increment) and on every foreground return (no increment)
- **DEBUG builds** — use Google's test ad unit ID regardless of the `adUnitId` you provide
- **Debug logging** — pass `debugEnabled: true` to print `[NnGoogleAdsKit]`-prefixed ad lifecycle logs; completely silent by default
- **UI tests** — `import NnGoogleAdsUITestHelpers`, then `app.handleAdTrackingAlert(.denyTracking)` dismisses the ATT alert and taps past the ad-gated screen

## Examples

- "Add app open ads to my SwiftUI app" -> Loads `ApiReference.md`
- "Configure AdDelegate for my ad unit" -> Loads `ApiReference.md`
- "Change the login threshold for showing ads" -> Loads `ApiReference.md`
- "Why isn't my app open ad showing?" -> Loads `ApiReference.md` (enable `debugEnabled` to trace the decision tree)
- "Get my UI tests past the tracking permission alert" -> Loads `ApiReference.md`
