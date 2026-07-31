# CocoaPods Propagation Retry Design

## Problem

The scheduled `dependency-update` workflow discovers the latest stable
`purchases-ios` GitHub release and immediately updates this repository to use
that version. CocoaPods CDN metadata can take significantly longer to expose a
newly published `RevenueCat` or `RevenueCatUI` version. On 2026-07-31, this
propagation took roughly 45 minutes.

The workflow currently runs `pod install --repo-update` once on an
`m4pro.medium` macOS executor. A missing CDN entry therefore fails the whole
dependency update, while waiting for propagation directly in that job would
hold an expensive macOS executor.

The internal Fastlane plugin is already pinned to its upstream `main` revision,
so no plugin update is available or required.

## Design

### CocoaPods readiness preflight

Add a small Linux job before the existing macOS `dependency-update` job. The
preflight will:

1. Read the current iOS dependency version from the repository.
2. Query GitHub for the latest stable `purchases-ios` release in the same major
   version.
3. Exit immediately when there is no newer iOS release.
4. Poll the CocoaPods CDN version-index shards for both `RevenueCat` and
   `RevenueCatUI`.
5. Continue only when both pods list the selected version.

The check will run immediately and then every five minutes for up to one hour.
Transient GitHub or CDN request failures will be treated as unavailable and
retried. On timeout, the job will report the selected version and which pods
were still unavailable. The macOS dependency-update job will require this
preflight and will not start if it times out.

The preflight will use a repository-owned Ruby utility with injectable HTTP and
sleep behavior. This keeps the CircleCI configuration small and allows the
selection, availability, retry, success, and timeout behavior to be tested
without real waits or network calls.

### Last-mile `pod install` retries

The Fastlane `run_pod_install` lane will retain the real
`pod install --repo-update` as the source of truth. It will make up to three
total attempts with short exponential delays between failures. These retries
cover transient networking and the small interval between a successful CDN
preflight and CocoaPods resolving its metadata.

The final failure will remain visible and fail the dependency update. The retry
loop will not swallow permanent CocoaPods errors.

### Avoid unnecessary CocoaPods work

`update_native_dependencies_to_latest` will call `run_pod_install` only when
the selected iOS version differs from the current iOS version. Android-only and
JavaScript-only dependency updates will no longer perform CocoaPods network
work.

## Data flow

```text
CircleCI schedule/manual trigger
        |
        v
small Linux CocoaPods readiness job
        |
        +-- no new iOS version ----------------------+
        |                                            |
        +-- new version -> poll RevenueCat + UI CDN  |
                             |                       |
                             +-- timeout -> fail     |
                             |                       |
                             v                       v
                    macOS dependency-update job
                             |
                             +-- update iOS files and SwiftPM resolution
                             +-- update Android and JavaScript files
                             +-- iOS changed? -> pod install with short retries
                             +-- open dependency-update pull request
```

## Testing

Automated tests will cover:

- selecting the latest stable release within the current major version;
- exiting immediately when the iOS dependency is already current;
- waiting until both CocoaPods CDN entries become available;
- retrying request failures;
- reporting a timeout after the configured attempt limit;
- retrying `pod install` and succeeding after a transient failure;
- failing after the final `pod install` attempt;
- skipping `pod install` when the iOS version is unchanged.

The CircleCI configuration will be validated locally, and the Ruby/Fastlane
tests will be run before completion.

## Out of scope

- Changing the `purchases-ios` release process.
- Splitting iOS, Android, and JavaScript updates into separate pull requests.
- Adding a general-purpose retry action to the internal Fastlane plugin.
- Retrying unrelated permanent failures for an hour.
