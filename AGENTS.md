# purchases-hybrid-common — Development Guidelines

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

Shared native libraries for RevenueCat's hybrid SDKs (Flutter, React Native, Unity, Capacitor, Cordova). This repository contains iOS (Swift), Android (Kotlin), TypeScript, and JavaScript bridge code that connects platform-native SDKs to hybrid frameworks.

**Related repositories:**
- **iOS SDK**: https://github.com/RevenueCat/purchases-ios
- **Android SDK**: https://github.com/RevenueCat/purchases-android
- **Flutter SDK**: https://github.com/RevenueCat/purchases-flutter
- **React Native SDK**: https://github.com/RevenueCat/react-native-purchases
- **Unity SDK**: https://github.com/RevenueCat/purchases-unity
- **Capacitor SDK**: https://github.com/RevenueCat/purchases-capacitor

When implementing features or debugging, check these repos for reference and patterns.

## Important: Public API Stability

**Do NOT introduce breaking changes to the public API.** All hybrid SDKs depend on this library.

**Safe changes:**
- Adding new optional parameters to existing methods
- Adding new classes, methods, or properties
- Bug fixes that don't change method signatures
- Internal implementation changes

**Requires explicit approval:**
- Removing or renaming public classes/methods/properties
- Changing method signatures (parameter types, required params)
- Changing return types
- Modifying behavior in ways that break existing integrations

## Code Structure

```
purchases-hybrid-common/
├── android/                          # Android Kotlin library
│   ├── hybridcommon/                 # Main Kotlin module
│   ├── hybridcommon-ui/              # UI components (PaywallFragment, CustomerCenter)
│   └── api-tests/                    # API integration tests
├── ios/                              # iOS Swift library
│   ├── PurchasesHybridCommon/        # Main Swift module
│   └── PurchasesHybridCommonUI/      # UI components (Paywalls, CustomerCenter)
├── typescript/                       # Shared TypeScript types/interfaces
├── purchases-js-hybrid-mappings/     # JavaScript hybrid mappings for web
├── fastlane/                         # Release automation & CI/CD
└── .circleci/                        # CircleCI configuration
```

## Common Development Commands

### Android

```bash
# Build
./gradlew build
./gradlew hybridcommon:build
./gradlew hybridcommon-ui:build

# Tests
./gradlew test

# Enable local purchases-android build
./gradlew enableLocalBuild -PpurchasesPath="~/path/to/purchases-android"

# Disable local build
./gradlew disableLocalBuild

# Code quality
./gradlew detekt
```

### iOS

```bash
# Via CocoaPods
pod install

# Via SwiftPM
swift build

# Code validation
bundle exec fastlane ios pod_lint
```

### TypeScript

```bash
yarn build              # TypeScript compilation
yarn build-watch        # Watch mode
yarn lint               # ESLint
yarn extract-api        # API report generation
```

### JavaScript/Web

```bash
npm run build           # Rollup bundling
npm test                # Jest testing
npm run lint            # ESLint
npm run api-test        # API extractor validation
npm run allchecks       # Format + lint + api + test
```

### Cross-Platform (Fastlane)

```bash
bundle exec fastlane bump                           # Version bump
bundle exec fastlane automatic_bump                 # Auto bump
bundle exec fastlane ios push_pod_PHC               # Release to CocoaPods
bundle exec fastlane android deploy                 # Release to Maven Central
bundle exec fastlane typescript deploy              # Release to npm
bundle exec fastlane check_typescript_api_changes   # API validation
```

## Project Architecture

### Android (`android/`)
- **Main Entry**: `hybridcommon/src/main/java/.../common.kt`
- Core functions: `getOfferings()`, `getCurrentOfferingForPlacement()`, `configure()`
- Mappers package handles data transformations
- Two flavors: BillingClient v8 (default) and v7

### iOS (`ios/`)
- **Main Entry**: `PurchasesHybridCommon/CommonFunctionality.swift`
- Provides Objective-C compatible API for hybrid SDKs
- Handles StoreKit integration, configuration, and purchase flows

### TypeScript (`typescript/`)
- **Main Entry**: `src/index.ts`
- Exports: errors, customerInfo, offerings, enums, purchaseParams, etc.
- Package: `@revenuecat/purchases-typescript-internal`

### JavaScript/Web (`purchases-js-hybrid-mappings/`)
- **Main Entry**: `src/index.ts` and `purchases-common.ts`
- Package: `@revenuecat/purchases-js-hybrid-mappings`
- Mappers for: virtual currencies, offerings, customer info, errors

## Constraints / Support Policy

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 13.0+ |
| macOS | 10.15+ |
| tvOS | 13.0+ |
| watchOS | 6.2+ |
| visionOS | 1.0+ |
| Android | minSdk 21 |

Don't raise minimum versions unless explicitly required and justified.

## Testing

### Android
```bash
./gradlew test
```

### TypeScript
```bash
yarn lint
yarn extract-api
```

### JavaScript
```bash
npm run allchecks
```

## Pull Request Labels

When creating a pull request, **always add one of these labels** to categorize the change:

| Label | When to Use |
|-------|-------------|
| `pr:feat` | New user-facing features or enhancements |
| `pr:fix` | Bug fixes |
| `pr:other` | Internal changes, refactors, CI, docs, or anything that shouldn't trigger a release |

## When the Task is Ambiguous

1. Search for similar existing implementation in this repo first
2. Check purchases-ios and purchases-android for native SDK patterns
3. If there's a pattern, follow it exactly
4. If not, propose options with tradeoffs and pick the safest default

## Guardrails

- **Don't invent APIs or file paths** — verify they exist before referencing them
- **Don't remove code you don't understand** — ask for context first
- **Don't make large refactors** unless explicitly requested
- **Keep diffs minimal** — only touch what's necessary, preserve existing formatting
- **Don't break the public API** — if API tests fail, investigate why
- **Maintain consistency across platforms** — iOS, Android, TypeScript, and JS should expose equivalent functionality
- **Never commit API keys or secrets** — do not stage or commit credentials or sensitive data
