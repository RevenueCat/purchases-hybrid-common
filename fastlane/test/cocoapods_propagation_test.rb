require "minitest/autorun"
require "json"
require "cocoapods_propagation"

class CocoaPodsPropagationTest < Minitest::Test
  FakeResponse = Struct.new(:code, :body)

  class FakeHttp
    def initialize(responses)
      @responses = responses
    end

    def get(uri, _headers = {})
      response = @responses.fetch(uri.to_s)
      response = response.shift if response.is_a?(Array)
      raise response if response.is_a?(Exception)

      response
    end
  end

  class SequenceReleaseFinder
    def initialize(outcomes)
      @outcomes = outcomes
    end

    def latest_stable_same_major(_current_version)
      outcome = @outcomes.length > 1 ? @outcomes.shift : @outcomes.first
      raise outcome if outcome.is_a?(Exception)

      outcome
    end
  end

  class SequenceCdnChecker
    def initialize(outcomes)
      @outcomes = outcomes
    end

    def available?(pod_name, _version)
      pod_outcomes = @outcomes.fetch(pod_name)
      pod_outcomes.length > 1 ? pod_outcomes.shift : pod_outcomes.first
    end
  end

  def test_selects_latest_stable_release_in_current_major
    releases = [
      release("7.0.0", draft: true),
      release("6.0.0"),
      release("5.84.0-beta.1", prerelease: true),
      release("5.83.0"),
      release("5.82.0")
    ]
    http = FakeHttp.new(
      CocoaPodsPropagation::GITHUB_RELEASES_URI.to_s =>
        FakeResponse.new("200", JSON.generate(releases))
    )
    finder = CocoaPodsPropagation::ReleaseFinder.new(http: http)

    selected = finder.latest_stable_same_major(Gem::Version.new("5.82.0"))

    assert_equal Gem::Version.new("5.83.0"), selected
  end

  def test_checks_version_in_the_pods_cdn_shard
    revenue_cat_url =
      "https://cdn.cocoapods.org/all_pods_versions_e_9_b.txt"
    revenue_cat_ui_url =
      "https://cdn.cocoapods.org/all_pods_versions_c_3_7.txt"
    revenue_cat_spec_url =
      "https://cdn.jsdelivr.net/cocoa/Specs/e/9/b/RevenueCat/5.83.0/RevenueCat.podspec.json"
    http = FakeHttp.new(
      revenue_cat_url =>
        FakeResponse.new("200", "RevenueCat/5.81.3/5.82.0/5.83.0\n"),
      revenue_cat_spec_url => FakeResponse.new("200", "{}"),
      revenue_cat_ui_url =>
        FakeResponse.new("200", "RevenueCatUI/5.81.3/5.82.0\n")
    )
    checker = CocoaPodsPropagation::CdnChecker.new(http: http)

    assert checker.available?("RevenueCat", Gem::Version.new("5.83.0"))
    refute checker.available?("RevenueCatUI", Gem::Version.new("5.83.0"))
  end

  def test_is_unavailable_when_version_is_indexed_but_podspec_is_missing
    shard_url = "https://cdn.cocoapods.org/all_pods_versions_e_9_b.txt"
    spec_url =
      "https://cdn.jsdelivr.net/cocoa/Specs/e/9/b/RevenueCat/5.83.0/RevenueCat.podspec.json"
    http = FakeHttp.new(
      shard_url =>
        FakeResponse.new("200", "RevenueCat/5.81.3/5.82.0/5.83.0\n"),
      spec_url => FakeResponse.new("404", "not found")
    )
    checker = CocoaPodsPropagation::CdnChecker.new(http: http)

    refute checker.available?("RevenueCat", Gem::Version.new("5.83.0"))
  end

  def test_exits_immediately_when_current_version_is_latest
    current_version = Gem::Version.new("5.83.0")
    waiter = CocoaPodsPropagation::Waiter.new(
      release_finder: SequenceReleaseFinder.new([current_version]),
      cdn_checker: Object.new,
      interval_seconds: 300,
      max_seconds: 600,
      sleeper: ->(_seconds) { flunk("must not sleep") },
      logger: ->(_message) {}
    )

    assert_equal :current, waiter.wait(current_version)
  end

  def test_retries_request_errors_and_waits_for_both_pods
    current_version = Gem::Version.new("5.82.0")
    new_version = Gem::Version.new("5.83.0")
    sleeps = []
    messages = []
    waiter = CocoaPodsPropagation::Waiter.new(
      release_finder: SequenceReleaseFinder.new(
        [RuntimeError.new("GitHub unavailable"), new_version, new_version]
      ),
      cdn_checker: SequenceCdnChecker.new(
        "RevenueCat" => [true, true],
        "RevenueCatUI" => [false, true]
      ),
      interval_seconds: 300,
      max_seconds: 600,
      sleeper: ->(seconds) { sleeps << seconds },
      logger: ->(message) { messages << message }
    )

    assert_equal :available, waiter.wait(current_version)
    assert_equal [300, 300], sleeps
    assert messages.any? { |message| message.include?("GitHub unavailable") }
    assert messages.any? { |message| message.include?("RevenueCatUI") }
  end

  def test_times_out_after_configured_wait
    current_version = Gem::Version.new("5.82.0")
    new_version = Gem::Version.new("5.83.0")
    sleeps = []
    waiter = CocoaPodsPropagation::Waiter.new(
      release_finder: SequenceReleaseFinder.new([new_version]),
      cdn_checker: SequenceCdnChecker.new(
        "RevenueCat" => [true],
        "RevenueCatUI" => [false]
      ),
      interval_seconds: 300,
      max_seconds: 600,
      sleeper: ->(seconds) { sleeps << seconds },
      logger: ->(_message) {}
    )

    error = assert_raises(CocoaPodsPropagation::TimeoutError) do
      waiter.wait(current_version)
    end
    assert_equal [300, 300], sleeps
    assert_includes error.message, "RevenueCatUI"
    assert_includes error.message, "5.83.0"
  end

  private

  def release(tag_name, draft: false, prerelease: false)
    {
      "tag_name" => tag_name,
      "draft" => draft,
      "prerelease" => prerelease
    }
  end
end
