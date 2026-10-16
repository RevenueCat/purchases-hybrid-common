require "minitest/autorun"
require "dependency_update_resilience"

class DependencyUpdateResilienceTest < Minitest::Test
  def test_retries_with_exponential_delays_until_operation_succeeds
    attempts = 0
    sleeps = []
    messages = []

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
    assert_equal 3, attempts
    assert_equal [30, 60], sleeps
    assert_equal 2, messages.length
  end

  def test_reraises_the_final_failure
    attempts = 0

    error = assert_raises(RuntimeError) do
      DependencyUpdateResilience.with_retries(
        max_attempts: 3,
        initial_delay: 30,
        sleeper: ->(_seconds) {},
        logger: ->(_message) {}
      ) do
        attempts += 1
        raise "permanent"
      end
    end

    assert_equal "permanent", error.message
    assert_equal 3, attempts
  end

  def test_skips_operation_when_ios_version_is_unchanged
    result = DependencyUpdateResilience.if_ios_changed(
      current_version: "5.83.0",
      new_version: "5.83.0"
    ) do
      flunk("must not yield")
    end

    refute result
  end

  def test_runs_operation_when_ios_version_changes
    yielded = false

    result = DependencyUpdateResilience.if_ios_changed(
      current_version: "5.82.0",
      new_version: "5.83.0"
    ) do
      yielded = true
    end

    assert result
    assert yielded
  end
end
