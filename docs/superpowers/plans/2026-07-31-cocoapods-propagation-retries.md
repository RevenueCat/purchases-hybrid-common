# CocoaPods Propagation Retries Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent `dependency-update` from failing while new RevenueCat pods propagate, without holding an expensive macOS executor for up to an hour.

**Architecture:** A standalone Ruby preflight selects the latest stable `purchases-ios` release in the current major and polls the CocoaPods CDN version shards for both required pods. CircleCI runs it on a small Linux executor before the existing macOS job; a separate pure-Ruby helper gives the final `pod install` short retries and skips that command when iOS is unchanged.

**Tech Stack:** Ruby 3.3 standard library (`net/http`, `json`, `digest`, `rubygems`, `minitest`), Fastlane, CocoaPods, CircleCI 2.1.

## Global Constraints

- Poll CocoaPods every 300 seconds for up to 3,600 seconds.
- Require both `RevenueCat` and `RevenueCatUI` before starting macOS work.
- Keep the existing `pod install --repo-update` as the final source of truth.
- Do not change public SDK APIs or any platform minimum version.
- Do not update `fastlane-plugin-revenuecat_internal`; the lockfile already points at upstream `main`.
- Do not split dependency updates into separate pull requests.

---

## File Structure

- Create `fastlane/lib/cocoapods_propagation.rb`: release selection, CocoaPods CDN availability checks, and bounded polling.
- Create `scripts/wait-for-cocoapods`: thin executable entry point for CircleCI.
- Create `fastlane/test/cocoapods_propagation_test.rb`: deterministic tests with fake HTTP responses and no real sleep.
- Create `fastlane/lib/dependency_update_resilience.rb`: bounded retry helper plus conditional execution when the iOS version changes.
- Create `fastlane/test/dependency_update_resilience_test.rb`: deterministic retry and conditional-execution tests.
- Modify `fastlane/Fastfile`: use the resilience helper around `pod install` and only invoke it for an iOS change.
- Modify `.circleci/config.yml`: add the Linux preflight job and make the macOS dependency-update job depend on it.

### Task 1: CocoaPods CDN Readiness Utility

**Files:**
- Create: `fastlane/lib/cocoapods_propagation.rb`
- Create: `scripts/wait-for-cocoapods`
- Create: `fastlane/test/cocoapods_propagation_test.rb`

**Interfaces:**
- Produces: `CocoaPodsPropagation::ReleaseFinder#latest_stable_same_major(current_version) -> Gem::Version`
- Produces: `CocoaPodsPropagation::CdnChecker#available?(pod_name, version) -> Boolean`
- Produces: `CocoaPodsPropagation::Waiter#wait(current_version) -> :current | :available`
- Raises: `CocoaPodsPropagation::TimeoutError` after the configured attempt limit.
- CLI environment: `COCOAPODS_WAIT_INTERVAL_SECONDS` defaults to `300`; `COCOAPODS_WAIT_MAX_SECONDS` defaults to `3600`; `GITHUB_TOKEN` is optional.

- [ ] **Step 1: Write failing release-selection and CDN-shard tests**

Create `fastlane/test/cocoapods_propagation_test.rb` with fake HTTP objects and tests that assert:

```ruby
finder = CocoaPodsPropagation::ReleaseFinder.new(http: fake_http)
assert_equal Gem::Version.new("5.83.0"),
             finder.latest_stable_same_major(Gem::Version.new("5.82.0"))

checker = CocoaPodsPropagation::CdnChecker.new(http: fake_http)
assert checker.available?("RevenueCat", Gem::Version.new("5.83.0"))
refute checker.available?("RevenueCatUI", Gem::Version.new("5.83.0"))
```

The release fixture must include a draft, a prerelease, a stable `6.0.0`, and stable `5.82.0`/`5.83.0` releases so the test proves filtering and same-major selection. The CDN fixture for `RevenueCat` must include a single slash-delimited line containing `5.83.0`; the `RevenueCatUI` fixture must omit it.

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
```

Expected: failure with `cannot load such file -- cocoapods_propagation`.

- [ ] **Step 3: Implement release selection and CDN checks**

Create `fastlane/lib/cocoapods_propagation.rb` with:

```ruby
module CocoaPodsPropagation
  GITHUB_RELEASES_URI =
    URI("https://api.github.com/repos/RevenueCat/purchases-ios/releases?per_page=100")
  COCOAPODS_CDN_BASE = "https://cdn.cocoapods.org"
  REQUIRED_PODS = %w[RevenueCat RevenueCatUI].freeze

  class ReleaseFinder
    def initialize(http:, github_token: nil)
      @http = http
      @github_token = github_token
    end

    def latest_stable_same_major(current_version)
      releases = JSON.parse(@http.get(GITHUB_RELEASES_URI, headers).body)
      versions = releases.filter_map do |release|
        next if release["draft"] || release["prerelease"]

        version = Gem::Version.new(release.fetch("tag_name").delete_prefix("v"))
        version if version.segments.first == current_version.segments.first
      end
      versions.max || current_version
    end
  end

  class CdnChecker
    def initialize(http:)
      @http = http
    end

    def available?(pod_name, version)
      shard = Digest::MD5.hexdigest(pod_name).chars.first(3).join("_")
      body = @http.get(URI("#{COCOAPODS_CDN_BASE}/all_pods_versions_#{shard}.txt")).body
      line = body.lines.find { |entry| entry.start_with?("#{pod_name}/") }
      line&.split("/")&.drop(1)&.map(&:strip)&.include?(version.to_s) || false
    end
  end
end
```

Add explicit non-success HTTP handling so GitHub and CDN response codes outside
200–299 raise a descriptive error that the waiter can retry.

- [ ] **Step 4: Run the focused test and verify release/CDN checks pass**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
```

Expected: release-selection and CDN-check tests pass.

- [ ] **Step 5: Add failing waiter tests**

Extend `fastlane/test/cocoapods_propagation_test.rb` with:

```ruby
assert_equal :current, waiter.wait(Gem::Version.new("5.83.0"))
assert_equal :available, waiter.wait(Gem::Version.new("5.82.0"))
assert_equal [300, 300], sleeps
assert_raises(CocoaPodsPropagation::TimeoutError) do
  timeout_waiter.wait(Gem::Version.new("5.82.0"))
end
```

Use fakes where both pod checks become true on the third attempt, and a second
fake where at least one pod remains false for every attempt. Configure
`max_seconds: 600` and `interval_seconds: 300`, which means an immediate check
plus checks after two sleeps. Make the first release lookup raise a request
error before returning normally so the same success test proves transient
GitHub failures are retried.

- [ ] **Step 6: Run the waiter tests and verify they fail**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
```

Expected: failure because `CocoaPodsPropagation::Waiter` and
`CocoaPodsPropagation::TimeoutError` are not defined.

- [ ] **Step 7: Implement bounded polling and the CLI**

Add `CocoaPodsPropagation::NetHttpClient`, `TimeoutError`, and `Waiter`. The
waiter must recalculate the candidate release on each attempt, exit `:current`
when it is not newer, check both `REQUIRED_PODS`, log missing pods, rescue
request/parse errors as retryable, and perform exactly
`max_seconds / interval_seconds` sleeps before raising `TimeoutError`.

Create `scripts/wait-for-cocoapods`:

```ruby
#!/usr/bin/env ruby

require_relative "../fastlane/lib/cocoapods_propagation"

current_version_text = File.read(
  File.expand_path("../PurchasesHybridCommon.podspec", __dir__)
)[/s\.dependency 'RevenueCat', '([^']+)'/, 1]
abort("Could not read the current RevenueCat version") unless current_version_text

http = CocoaPodsPropagation::NetHttpClient.new
finder = CocoaPodsPropagation::ReleaseFinder.new(
  http: http,
  github_token: ENV["GITHUB_TOKEN"]
)
checker = CocoaPodsPropagation::CdnChecker.new(http: http)
waiter = CocoaPodsPropagation::Waiter.new(
  release_finder: finder,
  cdn_checker: checker,
  interval_seconds: Integer(ENV.fetch("COCOAPODS_WAIT_INTERVAL_SECONDS", "300")),
  max_seconds: Integer(ENV.fetch("COCOAPODS_WAIT_MAX_SECONDS", "3600")),
  sleeper: ->(seconds) { sleep(seconds) },
  logger: ->(message) { puts(message) }
)

waiter.wait(Gem::Version.new(current_version_text))
```

Rescue `CocoaPodsPropagation::TimeoutError` in the CLI, print its message with
`warn`, and exit `1`.

- [ ] **Step 8: Run utility tests and syntax checks**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
ruby -c fastlane/lib/cocoapods_propagation.rb
ruby -c scripts/wait-for-cocoapods
```

Expected: all tests pass and both syntax checks print `Syntax OK`.

- [ ] **Step 9: Commit the readiness utility**

```bash
git add fastlane/lib/cocoapods_propagation.rb \
  fastlane/test/cocoapods_propagation_test.rb \
  scripts/wait-for-cocoapods
git commit -m "ci: wait for RevenueCat pods to propagate"
```

### Task 2: Fastlane Last-Mile Resilience

**Files:**
- Create: `fastlane/lib/dependency_update_resilience.rb`
- Create: `fastlane/test/dependency_update_resilience_test.rb`
- Modify: `fastlane/Fastfile:1-5`
- Modify: `fastlane/Fastfile:234-252`
- Modify: `fastlane/Fastfile:376-381`

**Interfaces:**
- Produces: `DependencyUpdateResilience.with_retries(max_attempts:, initial_delay:, sleeper:, logger:) { ... }`
- Produces: `DependencyUpdateResilience.if_ios_changed(current_version:, new_version:) { ... } -> Boolean`
- Consumes: Fastlane `sh("pod install --repo-update")` inside the retry block.

- [ ] **Step 1: Write failing retry and conditional-execution tests**

Create `fastlane/test/dependency_update_resilience_test.rb` with tests that:

```ruby
attempts = 0
result = DependencyUpdateResilience.with_retries(
  max_attempts: 3,
  initial_delay: 30,
  sleeper: ->(seconds) { sleeps << seconds },
  logger: ->(message) { messages << message }
) do
  attempts += 1
  raise "transient" if attempts < 3
  :installed
end
assert_equal :installed, result
assert_equal [30, 60], sleeps

assert_raises(RuntimeError) do
  DependencyUpdateResilience.with_retries(
    max_attempts: 3,
    initial_delay: 30,
    sleeper: ->(_seconds) {},
    logger: ->(_message) {}
  ) { raise "permanent" }
end

refute DependencyUpdateResilience.if_ios_changed(
  current_version: "5.83.0",
  new_version: "5.83.0"
) { flunk("must not yield") }

assert DependencyUpdateResilience.if_ios_changed(
  current_version: "5.82.0",
  new_version: "5.83.0"
) { yielded = true }
assert yielded
```

- [ ] **Step 2: Run the focused test and verify it fails**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/dependency_update_resilience_test.rb
```

Expected: failure with
`cannot load such file -- dependency_update_resilience`.

- [ ] **Step 3: Implement the pure-Ruby helper**

Create `fastlane/lib/dependency_update_resilience.rb`:

```ruby
module DependencyUpdateResilience
  def self.with_retries(max_attempts:, initial_delay:, sleeper:, logger:)
    attempt = 0
    begin
      attempt += 1
      yield
    rescue StandardError => error
      raise if attempt >= max_attempts

      delay = initial_delay * (2**(attempt - 1))
      logger.call(
        "pod install failed on attempt #{attempt}/#{max_attempts}: " \
        "#{error.message}. Retrying in #{delay} seconds."
      )
      sleeper.call(delay)
      retry
    end
  end

  def self.if_ios_changed(current_version:, new_version:)
    return false if current_version == new_version

    yield
    true
  end
end
```

- [ ] **Step 4: Run the helper tests and verify they pass**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/dependency_update_resilience_test.rb
```

Expected: all tests pass.

- [ ] **Step 5: Wire the helper into Fastlane**

At the top of `fastlane/Fastfile`, add:

```ruby
require_relative "lib/dependency_update_resilience"
```

Replace the unconditional call after native updates with:

```ruby
DependencyUpdateResilience.if_ios_changed(
  current_version: current_ios_version,
  new_version: latest_ios_release
) do
  run_pod_install
end
```

Wrap `pod install` in:

```ruby
DependencyUpdateResilience.with_retries(
  max_attempts: 3,
  initial_delay: 30,
  sleeper: ->(seconds) { sleep(seconds) },
  logger: ->(message) { UI.important(message) }
) do
  sh("pod install --repo-update")
end
```

- [ ] **Step 6: Run helper tests and Fastfile syntax validation**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/dependency_update_resilience_test.rb
ruby -c fastlane/Fastfile
```

Expected: tests pass and syntax validation prints `Syntax OK`.

- [ ] **Step 7: Commit Fastlane resilience**

```bash
git add fastlane/lib/dependency_update_resilience.rb \
  fastlane/test/dependency_update_resilience_test.rb \
  fastlane/Fastfile
git commit -m "ci: retry dependency update pod install"
```

### Task 3: CircleCI Preflight Wiring and Full Verification

**Files:**
- Modify: `.circleci/config.yml:353-370`
- Modify: `.circleci/config.yml:580-589`

**Interfaces:**
- Consumes: `scripts/wait-for-cocoapods`.
- Produces: CircleCI job `wait-for-ios-pods`.
- Changes: workflow job `dependency-update` requires `wait-for-ios-pods`.

- [ ] **Step 1: Add the Linux readiness job**

Before the existing `dependency-update` job, add:

```yaml
  wait-for-ios-pods:
    docker:
      - image: cimg/ruby:3.3.0
    resource_class: small
    steps:
      - checkout
      - run:
          name: Wait for RevenueCat pods to reach the CocoaPods CDN
          command: ruby scripts/wait-for-cocoapods
```

- [ ] **Step 2: Gate the macOS job in the workflow**

Change the dependency-update workflow jobs to:

```yaml
    jobs:
      - wait-for-ios-pods
      - dependency-update:
          requires:
            - wait-for-ios-pods
```

- [ ] **Step 3: Validate CircleCI configuration**

Run:

```bash
circleci config validate .circleci/config.yml
```

Expected: `Config file at .circleci/config.yml is valid.`

- [ ] **Step 4: Run all new tests and syntax checks**

Run:

```bash
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
ruby -Ifastlane/lib fastlane/test/dependency_update_resilience_test.rb
ruby -c fastlane/lib/cocoapods_propagation.rb
ruby -c fastlane/lib/dependency_update_resilience.rb
ruby -c scripts/wait-for-cocoapods
ruby -c fastlane/Fastfile
```

Expected: all tests pass and every syntax check prints `Syntax OK`.

- [ ] **Step 5: Exercise the preflight against current live metadata**

Run:

```bash
COCOAPODS_WAIT_INTERVAL_SECONDS=1 \
COCOAPODS_WAIT_MAX_SECONDS=2 \
ruby scripts/wait-for-cocoapods
```

Expected: exit `0`; because the latest currently selected release is already on
the CocoaPods CDN, the script exits on its first check without sleeping.

- [ ] **Step 6: Review the complete diff**

Run:

```bash
git diff --check origin/main...
git diff --stat origin/main...
git status --short
```

Expected: no whitespace errors; only the design, plan, readiness utility/tests,
Fastlane helper/tests, Fastfile, executable, and CircleCI configuration differ
from `origin/main`.

- [ ] **Step 7: Commit CircleCI wiring**

```bash
git add .circleci/config.yml
git commit -m "ci: gate dependency updates on CocoaPods CDN"
```

- [ ] **Step 8: Re-run verification from the committed tree**

Run:

```bash
circleci config validate .circleci/config.yml
ruby -Ifastlane/lib fastlane/test/cocoapods_propagation_test.rb
ruby -Ifastlane/lib fastlane/test/dependency_update_resilience_test.rb
git status --short
```

Expected: CircleCI configuration valid, all tests pass, and the worktree is
clean.
