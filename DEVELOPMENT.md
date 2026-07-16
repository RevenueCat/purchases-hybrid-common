# iOS

## Point to a local `Purchases` project

In `ios/PurchasesHybridCommon/Podfile` replace:

```
  pod 'RevenueCat', '4.37.0'
```

with:

```
  pod 'RevenueCat', :path => '~/Development/repos/ios/purchases-ios'
```

Remember to change `'~/Development/repos/ios/purchases-ios'` with your local purchases-ios path.

# Android

## Point to a local `Purchases` project

In the  `android` directory run:
```bash
 ./gradlew enableLocalBuild -PpurchasesPath="~/Development/repos/ios/purchases-android/"
```

Then "Sync Project with Gradle files" in Android Studio

# Typescript

## Update the Typescript API Report
In the `/typescript` directory:

```bash
yarn build && yarn extract-api
```

# Bridging experimental/internal native APIs

purchases-android and purchases-ios mark some APIs as experimental (`ExperimentalPreviewRevenueCatPurchasesAPI`,
`ExperimentalPreviewRevenueCatUIPurchasesAPI`, `@_spi(Experimental)`) or internal
(`InternalRevenueCatAPI`, `@_spi(Internal)`). PHC must not silently absorb these markers and expose
the wrapped functionality as plain stable API: every native opt-in needs an explicit, in-code,
reviewable acknowledgment. A full-tree Danger rule (see `Dangerfile`) enforces this on every PR.

There are two acknowledgment paths per native marker:

1. **Propagate** (the usual choice for native `Experimental*` markers): annotate the PHC
   declaration with `@ExperimentalPreviewHybridCommonAPI`
   (`android/hybridcommon/.../ExperimentalPreviewHybridCommonAPI.kt`) and place it in a file named
   `experimental*.kt`. Kotlin consumers get a compile error without `@OptIn`; Java consumers (who
   can't see Kotlin opt-in annotations) call it via the generated `ExperimentalCommonKt` class, so
   the file placement is itself the propagation mechanism.
2. **Stabilize**: add a `// phc:stable-bridge` comment directly above the `@OptIn`/declaration,
   declaring that PHC consciously treats this native surface as stable for hybrid consumers (e.g.
   because it is foundational, already shipped, and used by every hybrid SDK). This is the usual
   choice for native `InternalRevenueCatAPI` usage, since PHC owns most of that surface (event
   forwarding, CustomerInfo mapping, etc.).

`@file:OptIn(...)` on a native marker is always a violation (it can't carry a per-declaration
acknowledgment). A gradle `-opt-in` compiler flag is also always a violation, since it silently
opts in repo-wide and bypasses the gate entirely.

## TypeScript/JS

`typescript/` and `purchases-js-hybrid-mappings/` use `@beta`/`@internal` TSDoc release tags
instead (no dts trimming: `purchases-typescript-internal` types are re-exported to app developers
by Capacitor and React Native, so they must stay visible). `purchases-js-hybrid-mappings` trims its
own internals from published types, so the only way to reach them is a `@ts-expect-error`/
`@ts-ignore` suppression; every such suppression must carry a `phc:experimental-bridge` or
`phc:stable-bridge` token on the same line. Do not use `as any` to reach purchases-js internals;
that bypasses the suppression-based gate.
