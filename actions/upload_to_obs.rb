require 'fastlane/action'

module Fastlane
  module Actions

    module SharedValues
      OBS_IPA_OUTPUT_URL = :OBS_IPA_OUTPUT_URL
    end

    class UploadToObsAction < Action
      def self.run(params)

        ipa = params[:ipa]
        dsym = params[:dsym]
        endpoint = params[:endpoint]
        key = params[:key]
        secret = params[:secret]
        bucket = params[:bucket]
        object_path = params[:object_path]


        # Split the ipa path by "/"
        ipa_segments = ipa.split("/")
        # Get the last segment of the path
        ipa_name = ipa_segments[-1]

        object_key = object_path + '/' + ipa_name

        dysm_object_key = "#{object_path}/#{dsym.split("/")[-1]}"

        script_path = File.expand_path("./fastlane/scripts/upload_to_obs_helper.py")
        result = system "python3 #{script_path} -k #{key} -s #{secret} -e #{endpoint} -b #{bucket} -o #{object_key} -a #{ipa} -d #{dysm_object_key} -y #{dsym}"
        # result = `python3 #{script_path} -k #{key} -s #{secret} -e #{endpoint} -b #{bucket} -o #{object_key} -a #{ipa}`
        UI.message("Python script returned: #{result}")

        if result
          endpoint_host = URI.parse(endpoint).host
          ipa_url = "https://#{bucket}.#{endpoint_host}/#{object_key}"
          Actions.lane_context[SharedValues::OBS_IPA_OUTPUT_URL] = ipa_url
          UI.message("lane_context OBS_IPA_OUTPUT_URL:#{Actions.lane_context[SharedValues::OBS_IPA_OUTPUT_URL]}")
        else
          # UI.error("upload fail")
          UI.user_error!("upload failed")
        end

        return ipa_url
      end

      

      def self.description
        "上传ipa文件到obs"
      end

      def self.authors
        ["zhaozq"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.output
        [
          ['OBS_IPA_OUTPUT_URL', 'ipa file obs url']
        ]
      end

      def self.details
        # Optional:
        "上传ipa文件到obs, 上传结果共享到 SharedValues::OBS_IPA_OUTPUT_URL"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                  env_name: "UPLOAD_TO_OBS_IPA",
                               description: ".ipa file for the build",
                                  optional: true,
                             default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                  env_name: "UPLOAD_TO_OBS_DSYM",
                               description: "zipped .dsym package for the build ",
                                  optional: true,
                             default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                  env_name: "UPLOAD_TO_OBS_ENDPOINT",
                               description: "obs endpoint, default value http://obs.cn-north-4.myhuaweicloud.com",
                                  optional: true,
                             default_value: "http://obs.cn-north-4.myhuaweicloud.com"),

          FastlaneCore::ConfigItem.new(key: :key,
                                  env_name: "UPLOAD_TO_OBS_KEY",
                               description: "obs key",
                                  optional: true,
                             default_value: ENV['OBS_ACCESS_KEY_ID']),
          FastlaneCore::ConfigItem.new(key: :secret,
                                  env_name: "UPLOAD_TO_OBS_SECRET",
                               description: "obs secret",
                                  optional: true,
                             default_value: ENV['OBS_ACCESS_KEY_SECRET']),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                  env_name: "UPLOAD_TO_OBS_BUCKET",
                               description: "obs bucket",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :object_path,
                                  env_name: "UPLOAD_TO_OBS_OBJECT_PATH",
                               description: "obs object key 'foo/bar/file', object path 'foo/bar'",
                                  optional: false,
                                      type: String),
          #TODO:  add verify_block
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        platform == :ios
      end
    end
  end
end