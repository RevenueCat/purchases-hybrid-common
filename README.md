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
