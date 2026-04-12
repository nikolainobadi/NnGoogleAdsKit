# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2026-04-12

### Added
- Add `NnGoogleAdsUITestHelpers` library with `XCUIApplication.handleAdTrackingAlert` for dismissing App Tracking Transparency alerts and ad-gated screens in UI tests
- Add `TrackingAlertResponse` enum for choosing tracking permission behavior in UI tests
- Add configurable timeouts for tracking alert and continue button in `handleAdTrackingAlert`

## [0.7.2] - 2026-02-03

### Changed
- Update NnTestKit dependency from 1.0.0 to 2.0.0
- Migrate test infrastructure to `@LeakTracked` macro (replacing deprecated `TrackingMemoryLeaks`)

## [0.7.1] - 2025-05-12

### Changed
- Update .gitignore

## [0.7.0] - 2025-04-25

### Added
- Unit tests for `AppOpenAdsENV`, `FullScreenAdInfo`, and `Request`
- `GoogleAdsManager` replacing `SharedGoogleAdsManager`
- `PostInitialLoginActionViewModifier` replacing `InitialLoginViewModifier`
- CI workflow (`ci.yml`)
- Test plan for accurate coverage reporting

### Changed
- Update to Swift 6 strict concurrency
- Update Google Mobile Ads SDK to 12.0.0
- Refactor `AppOpenAdsENV` for Sendable conformance

### Removed
- `SharedGoogleAdsManager`
- `InitialLoginViewModifier`

## [0.6.0] - 2024-11-05

### Added
- `LoginAdThresholdKey` environment key for configurable ad thresholds

### Changed
- Move `canShowAds` from delegate to view modifier parameter
- Remove internal `AppStorage` calls for improved testability

### Removed
- `canShowAds` from `AdDelegate` protocol

## [0.5.0] - 2024-11-01

### Added
- Initial release
- `AppOpenAdsENV` for managing app open ad lifecycle
- `AppOpenAdsViewModifier` for SwiftUI integration
- `AdDelegate` protocol
- `FullScreenAdInfo` model

[Unreleased]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/v0.8.0...HEAD
[0.8.0]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/0.7.2...v0.8.0
[0.7.2]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/v0.7.1...0.7.2
[0.7.1]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/nikolainobadi/NnGoogleAdsKit/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/nikolainobadi/NnGoogleAdsKit/releases/tag/v0.5.0
