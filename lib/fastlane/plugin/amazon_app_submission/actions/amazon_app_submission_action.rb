  require 'fastlane/action'
require_relative '../helper/amazon_app_submission_helper'

module Fastlane
  module Actions
    class AmazonAppSubmissionAction < Action
      def self.run(params)
        UI.message("The amazon_app_submission plugin is working!")

        token = Helper::AmazonAppSubmissionHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.message("Cannot retrieve token, please check your client ID and client secret")
        else
          UI.message("the token is #{token}")
        end  

        current_edit_id, eTag = Helper::AmazonAppSubmissionHelper.open_edit(token, params[:app_id])
        
        if current_edit_id.nil?
        Helper::AmazonAppSubmissionHelper.create_new_edit(token, params[:app_id])
        current_edit_id, eTag = Helper::AmazonAppSubmissionHelper.open_edit(token, params[:app_id])
        end  

        UI.message("the editId is #{current_edit_id}")


        # replace_apk_response =  Helper::AmazonAppSubmissionHelper.replaceExistingApk(token, params[:app_id], current_edit_id, eTag, apk_path)
       
        current_apk_id = Helper::AmazonAppSubmissionHelper.get_current_apk_id(token, params[:app_id], current_edit_id)

        if !current_apk_id.nil?
        UI.message("current_apk_id is #{current_apk_id}")

        delete_apk_response = Helper::AmazonAppSubmissionHelper.delete_apk(token, params[:app_id], current_edit_id, current_apk_id, eTag)
        UI.message("delete_apk_response is #{delete_apk_response}")
        end
        
        add_new_apk_response = Helper::AmazonAppSubmissionHelper.uploadNewApk(token, params[:app_id], current_edit_id, apk_path)

        UI.message("add_new_apk_response is #{add_new_apk_response}")

      end

      def self.description
        "test"
      end

      def self.authors
        ["mohammedhemaid"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it doesmmed
      end

      def self.details
        # Optional:
        "test"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :client_id,
                                    env_name: "AMAZON_APP_SUBMISSION_CLIENT_ID",
                                 description: "Amazon App Submission Client ID",
                                    optional: false,
                                        type: String),
  
            FastlaneCore::ConfigItem.new(key: :client_secret,
                                    env_name: "AMAZON_APP_SUBMISSION_CLIENT_SECRET",
                                 description: "Amazon App Submission Client Secret",
                                    optional: false,
                                        type: String),

            FastlaneCore::ConfigItem.new(key: :app_id,
                                    env_name: "AMAZON_APP_SUBMISSION_APP_ID",
                                 description: "Amazon App Submission APP ID",
                                    optional: false,
                                        type: String)

            FastlaneCore::ConfigItem.new(key: :apk_path,
                                    env_name: "AMAZON_APP_SUBMISSION_APK_PATH",
                                 description: "Amazon App Submission APK Path",
                                    optional: false,
                                        type: String)
  
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "AMAZON_APP_SUBMISSION_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
