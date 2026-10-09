require "digest"
require "json"
require "net/http"
require "rubygems"
require "uri"

module CocoaPodsPropagation
  GITHUB_RELEASES_URI =
    URI("https://api.github.com/repos/RevenueCat/purchases-ios/releases?per_page=100")
  COCOAPODS_CDN_BASE = "https://cdn.cocoapods.org"
  COCOAPODS_SPECS_BASE = "https://cdn.jsdelivr.net/cocoa/Specs"
  REQUIRED_PODS = %w[RevenueCat RevenueCatUI].freeze

  class TimeoutError < StandardError; end

  class NetHttpClient
    def get(uri, headers = {})
      request = Net::HTTP::Get.new(uri)
      headers.each { |name, value| request[name] = value }

      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https"
      ) do |http|
        http.request(request)
      end
    end
  end

  class ReleaseFinder
    def initialize(http:, github_token: nil)
      @http = http
      @github_token = github_token
    end

    def latest_stable_same_major(current_version)
      response = @http.get(GITHUB_RELEASES_URI, headers)
      ensure_success!(response, GITHUB_RELEASES_URI)

      releases = JSON.parse(response.body)
      versions = releases.filter_map do |release|
        next if release["draft"] || release["prerelease"]

        version = Gem::Version.new(release.fetch("tag_name").delete_prefix("v"))
        version if version.segments.first == current_version.segments.first
      end

      versions.max || current_version
    end

    private

    def headers
      result = { "Accept" => "application/vnd.github+json" }
      result["Authorization"] = "Bearer #{@github_token}" if @github_token
      result
    end

    def ensure_success!(response, uri)
      return if response.code.to_i.between?(200, 299)

      raise "Request to #{uri} failed with HTTP #{response.code}"
    end
  end

  class CdnChecker
    def initialize(http:)
      @http = http
    end

    def available?(pod_name, version)
      uri = shard_uri(pod_name)
      response = @http.get(uri)
      ensure_success!(response, uri)

      line = response.body.lines.find do |entry|
        entry.start_with?("#{pod_name}/")
      end
      versions = line&.split("/")&.drop(1)&.map(&:strip) || []
      return false unless versions.include?(version.to_s)

      spec_response = @http.get(spec_uri(pod_name, version))
      spec_response.code.to_i.between?(200, 299)
    end

    private

    def shard_uri(pod_name)
      shard = Digest::MD5.hexdigest(pod_name).chars.first(3).join("_")
      URI("#{COCOAPODS_CDN_BASE}/all_pods_versions_#{shard}.txt")
    end

    def spec_uri(pod_name, version)
      path = Digest::MD5.hexdigest(pod_name).chars.first(3).join("/")
      URI(
        "#{COCOAPODS_SPECS_BASE}/#{path}/#{pod_name}/#{version}/" \
        "#{pod_name}.podspec.json"
      )
    end

    def ensure_success!(response, uri)
      return if response.code.to_i.between?(200, 299)

      raise "Request to #{uri} failed with HTTP #{response.code}"
    end
  end

  class Waiter
    def initialize(
      release_finder:,
      cdn_checker:,
      interval_seconds:,
      max_seconds:,
      sleeper:,
      logger:
    )
      @release_finder = release_finder
      @cdn_checker = cdn_checker
      @interval_seconds = interval_seconds
      @max_seconds = max_seconds
      @sleeper = sleeper
      @logger = logger
    end

    def wait(current_version)
      attempts = (@max_seconds / @interval_seconds) + 1
      latest_version = current_version
      missing_pods = REQUIRED_PODS
      last_error = nil

      attempts.times do |attempt|
        begin
          latest_version =
            @release_finder.latest_stable_same_major(current_version)
          if latest_version <= current_version
            @logger.call("iOS #{current_version} is already current.")
            return :current
          end

          missing_pods = REQUIRED_PODS.reject do |pod_name|
            @cdn_checker.available?(pod_name, latest_version)
          end
          if missing_pods.empty?
            @logger.call(
              "RevenueCat pods #{latest_version} are available on CocoaPods CDN."
            )
            return :available
          end

          last_error = nil
          @logger.call(
            "Waiting for #{missing_pods.join(', ')} #{latest_version} " \
            "on CocoaPods CDN."
          )
        rescue StandardError => error
          last_error = error
          @logger.call(
            "Could not check CocoaPods readiness: #{error.message}"
          )
        end

        next if attempt == attempts - 1

        @logger.call(
          "Retrying CocoaPods readiness in #{@interval_seconds} seconds."
        )
        @sleeper.call(@interval_seconds)
      end

      detail =
        if last_error
          "Last error: #{last_error.message}"
        else
          "Still missing: #{missing_pods.join(', ')} #{latest_version}"
        end
      raise TimeoutError,
            "CocoaPods CDN was not ready after #{@max_seconds} seconds. #{detail}"
    end
  end
end
