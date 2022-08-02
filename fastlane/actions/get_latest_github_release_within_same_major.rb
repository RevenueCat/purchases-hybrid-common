module Fastlane
  module Actions

    class GetLatestGithubReleaseWithinSameMajorAction < Action
      def self.run(params)
        repo_name = params[:repo_name]
        current_version = Gem::Version.new(params[:current_version])
        UI.message("Getting latest release for #{repo_name} on GitHub within same major as #{current_version}")
        GithubApiAction.run(
          server_url: "https://api.github.com",
          api_token: ENV["GITHUB_API_TOKEN"],
          api_bearer: nil,
          http_method: 'GET',
          path: "repos/RevenueCat/#{repo_name}/releases",
          error_handlers: {
            404 => proc do |result|
              UI.error("Repository #{repo_name} cannot be found, please double check its name and that you provided a valid API token (if it's a private repository).")
            end,
            401 => proc do |result|
              UI.error("You are not authorized to access #{repo_name}, please make sure you provided a valid API token.")
            end,
            '*' => proc do |result|
              UI.error("GitHub responded with #{result[:status]}:#{result[:body]}")
            end
          }
        ) do |result|
          json = result[:json]
          if json.count == 0
            UI.user_error!("Couldn't find latest GitHub release for #{params[:repo_name]}")
            return
          end

          highest_version = json.reject { |item| item["prerelease"] }
            .map { |item| item_version(item) }
            .select { |item_version| same_major_range?(item_version, current_version) }
            .max

          UI.message("Version #{highest_version.version} is latest release in the same major live on GitHub.com 🚁")
          return highest_version.version
        end
      end

      private_class_method def self.item_version(item)
        Gem::Version.new(item['tag_name'])
      end
      
      private_class_method def self.same_major_range?(version_a, version_b)
        version_a.canonical_segments[0] == version_b.canonical_segments[0]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will get latest release version that is available on GitHub"
      end

      def self.details
        sample = "1.8.0"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repo_name,
                                       env_name: "FL_GET_GITHUB_LATEST_RELEASE_REPO_NAME",
                                       description: "The path to your RevenueCat repository name, e.g. 'purchases-ios'",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please only pass the repository name, e.g. 'purchases-ios'") if value.include?("github.com")
                                         UI.user_error!("Please only pass the repository name, e.g. 'purchases-ios'") if value.split('/').count != 1
                                       end),
          FastlaneCore::ConfigItem.new(key: :current_version,
                                       env_name: "FL_GET_GITHUB_LATEST_RELEASE_CURRENT_VERSION",
                                       description: "The current release version to check for next minor or patch"),
        ]
      end

      def self.authors
        ["vegaro"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'release_name = get_latest_github_release_within_same_major(repo_name: "fastlane/fastlane")
          puts release_name'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end