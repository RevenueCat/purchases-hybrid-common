# purchases-hybrid-common

Common files and libraries for RevenueCat's Hybrid SDKs. This repository contains 4 distinct libraries that provide shared functionality across different platforms and implementations.

## Libraries

### 1. Android (`android/`)
Contains mappings and utilities for RevenueCat hybrid SDKs to interface with the native Android library. This library provides the bridge between hybrid frameworks and the RevenueCat Android SDK, handling platform-specific implementations and data transformations.

### 2. iOS (`ios/`)
Contains mappings and utilities for RevenueCat hybrid SDKs to interface with the native iOS library. This provides the necessary bridge to connect hybrid frameworks with the RevenueCat iOS SDK, managing iOS-specific functionality and data transformations.

### 3. TypeScript (`typescript/`)
Shared TypeScript types and interfaces commonly used by both [react-native-purchases](https://github.com/RevenueCat/react-native-purchases) and [purchases-capacitor](https://github.com/RevenueCat/purchases-capacitor). This library ensures type consistency across different hybrid implementations by providing a single source of truth for common data structures, enums, and type definitions.

- **Package**: `@revenuecat/purchases-typescript-internal`
- **Purpose**: Internal shared TypeScript code for hybrid SDKs
- **Note**: Not intended for external usage

### 4. JavaScript Hybrid Mappings (`purchases-js-hybrid-mappings/`)
Contains mappings from purchases-js for use by hybrid frameworks that support web platforms. This library enables hybrid SDKs to leverage RevenueCat's web functionality through standardized mappings and interfaces.

- **Package**: `@revenuecat/purchases-js-hybrid-mappings`
- **Dependencies**: Built on top of `@revenuecat/purchases-js`
- **Purpose**: Bridge between purchases-js and hybrid implementations

## Development setup

Install [mise](https://mise.jdx.dev/), then from the repo root:

```bash
mise install
```

That installs Java, Ruby, Yarn, and SwiftLint from `mise.toml`, and Node from `.node-version`. Resolved versions are pinned in `mise.lock`.

The Yarn version is also set in the packageManager field of each `package.json`. CI installs tools from the repo root, where there is no package.json, so mise needs the version in mise.toml.

**Exceptions (not managed by mise):** Xcode for iOS work, Android SDK for local Android builds.

## Custom checkpoint paywall presentation

The experimental, invite-only checkpoint APIs in `PurchasesHybridCommonUI` and `hybridcommon-ui` support app-owned paywalls. Use the additive `CheckpointProxy.present` overload with `onPaywallPresentationRequested`, or `presentCheckpoint` with `useCustomPaywallPresenter = true` and a listener that implements `onPaywallPresentationRequested`. Each request supplies a unique request ID and a dictionary containing `checkpointIdentifier`, primitive `customVariables`, the resolved `presentationMode`, and the serialized `offering`. Use a unique call ID for each checkpoint. A nil callback on iOS or a false flag on Android leaves presentation to the native SDK. Error-dialog callbacks are independently optional and also handle synchronization errors after a custom paywall completes.

The wrapper dismisses its UI, then calls `completePaywallPresentation(requestId, result)` with `CONTINUED`, `CLOSED`, or `NAVIGATED_BACK`. The native SDK owns purchase synchronization and the checkpoint outcome. Duplicate completions are ignored; unrecognized outcomes back out. When the owning screen detaches, call `detachCheckpoint(callId, activePaywallRequestId)` with only the request whose app-owned handler actually ran, or nil/null when none ran. This cancels queued and future presentations while allowing already shown UI to complete after dismissal; errors fall back to SDK dialogs. On runtime teardown, call `invalidateCheckpointPresentations()` to drain both request protocols and reject callbacks from the old runtime while allowing new calls. Call completion and teardown methods on the main thread.
