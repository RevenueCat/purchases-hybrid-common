fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump

```sh
[bundle exec] fastlane bump
```

Bump version, edit changelog, and create pull request

### automatic_bump

```sh
[bundle exec] fastlane automatic_bump
```

Automatically bumps version, edit changelog, and create pull request

### github_release_current

```sh
[bundle exec] fastlane github_release_current
```

Make GitHub release for current version

### github_release

```sh
[bundle exec] fastlane github_release
```

Make GitHub release for specific version

### trigger_update_dependencies

```sh
[bundle exec] fastlane trigger_update_dependencies
```

Trigger update dependencies to latest GitHub releases

### trigger_bump

```sh
[bundle exec] fastlane trigger_bump
```

Trigger bump

### check_typescript_api_changes

```sh
[bundle exec] fastlane check_typescript_api_changes
```

Check typescript library API changes

### update_typescript_api_report

```sh
[bundle exec] fastlane update_typescript_api_report
```

Update typescript library API report

### open_pr_upgrading_dependencies

```sh
[bundle exec] fastlane open_pr_upgrading_dependencies
```

Update dependencies to latest GitHub releases and opens a PR

### update_native_dependencies_to_latest

```sh
[bundle exec] fastlane update_native_dependencies_to_latest
```

Update dependencies to latest GitHub releases

### tag_current_branch

```sh
[bundle exec] fastlane tag_current_branch
```

Tag current branch with current version number

### run_pod_install

```sh
[bundle exec] fastlane run_pod_install
```

Run pod install

### bump_hybrid_dependencies

```sh
[bundle exec] fastlane bump_hybrid_dependencies
```

Run automatic bump in other repos

----


## iOS

### ios push_pod_PHC

```sh
[bundle exec] fastlane ios push_pod_PHC
```

Release PurchasesHybridCommon to CocoaPods

### ios push_pod_PHCUI

```sh
[bundle exec] fastlane ios push_pod_PHCUI
```

Release PurchasesHybridCommonUI to CocoaPods

### ios pod_lint

```sh
[bundle exec] fastlane ios pod_lint
```

Lint Podspec

### ios replace_api_key_integration_tests

```sh
[bundle exec] fastlane ios replace_api_key_integration_tests
```

replace API KEY for integration tests

----


## Android

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Upload and close a release

----


## typescript

### typescript deploy

```sh
[bundle exec] fastlane typescript deploy
```

Deploy npm package to npm.js

### typescript deploy_esm

```sh
[bundle exec] fastlane typescript deploy_esm
```

Deploy typescript interfaces ESNext NPM package

----


## web

### web test_js_mappings

```sh
[bundle exec] fastlane web test_js_mappings
```

Run tests for purchases-js-hybrid-mappings

### web test_js_mappings_api

```sh
[bundle exec] fastlane web test_js_mappings_api
```

Run API tests for purchases-js-hybrid-mappings

### web lint_js_mappings

```sh
[bundle exec] fastlane web lint_js_mappings
```

Run linter for purchases-js-hybrid-mappings

### web deploy_js_mappings

```sh
[bundle exec] fastlane web deploy_js_mappings
```

Deploy purchases-js-hybrid-mappings to npm.js

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
