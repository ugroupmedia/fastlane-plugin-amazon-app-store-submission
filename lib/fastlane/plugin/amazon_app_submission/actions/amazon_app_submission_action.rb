require 'fastlane/action'
require_relative '../helper/amazon_app_submission_helper'

module Fastlane
  module Actions
    class AmazonAppSubmissionAction < Action
      def self.run(params)
        UI.message("The amazon_app_submission plugin is working!")

        token = Helper::AmazonAppSubmissionHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.user_error!("Cannot retrieve token, please check your client ID and client secret", show_github_issues: false)
        end

        UI.message("Getting current edit")
        current_edit_id, edit_eTag = Helper::AmazonAppSubmissionHelper.open_edit(token, params[:app_id])

        if current_edit_id.nil?
        UI.message("Current edit not found, creating a new edit")
        Helper::AmazonAppSubmissionHelper.create_new_edit(token, params[:app_id])
        current_edit_id, edit_eTag = Helper::AmazonAppSubmissionHelper.open_edit(token, params[:app_id])
        end  

        if current_edit_id.nil?
        UI.crash!("Creating new edit failed!")
        return
        end

        if params[:upload_apk]
          UI.message("Get current apk id")
          current_apk_id = Helper::AmazonAppSubmissionHelper.get_current_apk_id(token, params[:app_id], current_edit_id)

          if current_apk_id.nil?
            UI.message("No apk found. Uploading new apk.")
            Helper::AmazonAppSubmissionHelper.uploadNewApk(token, params[:app_id], current_edit_id, params[:apk_path], params[:read_timeout], params[:write_timeout])
          else
            UI.message("Get current apk ETag")
            current_apk_eTag = Helper::AmazonAppSubmissionHelper.get_current_apk_etag(token, params[:app_id], current_edit_id, current_apk_id)

            UI.message("Replacing the apk with apk from #{params[:apk_path]}")
            Helper::AmazonAppSubmissionHelper.replaceExistingApk(token, params[:app_id], current_edit_id, current_apk_id, current_apk_eTag, params[:apk_path], params[:read_timeout], params[:write_timeout])
          end
        end

        if params[:upload_changelogs]
          UI.message("Updating the changelogs")
          Helper::AmazonAppSubmissionHelper.update_listings( token, params[:app_id],current_edit_id, params[:changelogs_path], params[:changelogs_path])
        end

        if params[:upload_apk] && params[:submit_for_review]
          UI.message("Submitting to Amazon app store")
          Helper::AmazonAppSubmissionHelper.commit_edit(token, params[:app_id], current_edit_id, edit_eTag)
        end

        UI.success("Amazon app submission finished successfully!")
      end

      def self.description
        "Fastlane plugin for Amazon App Submissions"
      end

      def self.authors
        ["mohammedhemaid", "saschagraeff"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it doesmmed
      end

      def self.details
        # Optional:
        "Creates an Upcoming Version for an Amazon Appstore app, uploads the data, then and submits the new Version for review"
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
                                        type: String),

            FastlaneCore::ConfigItem.new(key: :upload_apk,
                                    env_name: "AMAZON_APP_SUBMISSION_UPLOAD_APK",
                                 description: "Amazon App Submission upload apk file",
                               default_value: true,
                                    optional: true,
                                        type: Boolean),

            FastlaneCore::ConfigItem.new(key: :apk_path,
                                    env_name: "AMAZON_APP_SUBMISSION_APK_PATH",
                                 description: "Amazon App Submission APK Path",
                               default_value: "",
                                    optional: true,
                                        type: String),

            FastlaneCore::ConfigItem.new(key: :changelogs_path,
                                    env_name: "AMAZON_APP_SUBMISSION_CHANGELOGS_PATH",
                                 description: "Amazon App Submission changelogs path",
                               default_value: "",
                                    optional: true,
                                        type: String),

            FastlaneCore::ConfigItem.new(key: :upload_changelogs,
                                    env_name: "AMAZON_APP_SUBMISSION_SKIP_UPLOAD_CHANGELOGS",
                                 description: "Amazon App Submission upload changelogs",
                               default_value: false,
                                    optional: true,
                                        type: Boolean),

            FastlaneCore::ConfigItem.new(key: :submit_for_review,
                                    env_name: "AMAZON_APP_SUBMISSION_SUBMIT_FOR_REVIEW",
                                 description: "Amazon App Submission submit for review",
                               default_value: false,
                                    optional: true,
                                        type: Boolean),

            FastlaneCore::ConfigItem.new(key: :read_timeout,
                                    env_name: "AMAZON_APP_SUBMISSION_READ_TIMEOUT",
                                 description: "Read timeout in seconds for the apk upload process",
                               default_value: 1000,
                                    optional: true,
                                        type: Fixnum),

            FastlaneCore::ConfigItem.new(key: :write_timeout,
                                    env_name: "AMAZON_APP_SUBMISSION_WRITE_TIMEOUT",
                                 description: "Write timeout in seconds for the apk upload process",
                               default_value: 1000,
                                    optional: true,
                                        type: Fixnum)

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
