module Fastlane
  module Actions
    module SharedValues
      GET_LATEST_GITHUB_RELEASE_INFO = :GET_LATEST_GITHUB_RELEASE_INFO
    end

    class GetLatestGithubReleaseAction < Action
      def self.run(params)
        UI.message("Getting latest release on GitHub (https://api.github.com/#{params[:repo_name]})")

        GithubApiAction.run(
          server_url: "https://api.github.com",
          api_token: ENV["GITHUB_API_TOKEN"],
          api_bearer: nil,
          http_method: 'GET',
          path: "repos/#{params[:repo_name]}/releases",
          error_handlers: {
            404 => proc do |result|
              UI.error("Repository #{params[:repo_name]} cannot be found, please double check its name and that you provided a valid API token (if it's a private repository).")
              return nil
            end,
            401 => proc do |result|
              UI.error("You are not authorized to access #{params[:repo_name]}, please make sure you provided a valid API token.")
              return nil
            end,
            '*' => proc do |result|
              UI.error("GitHub responded with #{result[:status]}:#{result[:body]}")
              return nil
            end
          }
        ) do |result|
          json = result[:json]
          puts json
          json.each do |current|
            Actions.lane_context[SharedValues::GET_GITHUB_RELEASE_INFO] = current
            UI.message("Version #{current['tag_name']} is latest release live on GitHub.com 🚁")
            return current
          end
        end

        UI.important("Couldn't find GitHub release #{params[:version]}")
        return nil
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

      def self.output
        [
          ['GET_LATEST_GITHUB_RELEASE_CUSTOM_VALUE', 'Contains all the information about this release']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :repo_name,
                                       env_name: "FL_GET_GITHUB_RELEASE_URL",
                                       description: "The path to your repo, e.g. 'RevenueCat/purchases-ios'",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please only pass the path, e.g. 'RevenueCat/purchases-ios'") if value.include?("github.com")
                                         UI.user_error!("Please only pass the path, e.g. 'RevenueCat/purchases-ios'") if value.split('/').count != 2
                                       end),
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
          'release_name = get_latest_github_release(url: "fastlane/fastlane")
          puts release_name'
        ]
      end

      def self.sample_return_value
        {
          "name" => "name"
        }
      end

      def self.category
        :source_control
      end
    end
  end
end