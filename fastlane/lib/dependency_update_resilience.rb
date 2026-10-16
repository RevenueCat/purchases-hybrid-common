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
