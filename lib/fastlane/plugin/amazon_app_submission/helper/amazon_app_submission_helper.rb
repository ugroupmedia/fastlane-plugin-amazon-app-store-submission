require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AmazonAppSubmissionHelper
      # class methods that you define here become available in your action
      # as `Helper::AmazonAppSubmissionHelper.your_method`
      #

      BASE_URL = 'https://developer.amazon.com/api/appstore'

      def self.get_token(client_id, client_secret)
        UI.important("Fetching app access token")

        UI.important("client_id #{client_id}")
        UI.important("client_secret #{client_secret}")

        uri = URI('https://api.amazon.com/auth/o2/token')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = {client_id: client_id, grant_type: 'client_credentials',
                   client_secret: client_secret, scope: "appstore::apps:readwrite" }.to_json

        res = http.request(req)
        result_json = JSON.parse(res.body)

        auth_token = "Bearer #{result_json['access_token']}"

        return auth_token
      end

      def self.create_new_edit(token, app_id)
        
        create_edit_path = "/v1/applications/#{app_id}/edits"
        create_edit_url = BASE_URL + create_edit_path

        uri = URI(create_edit_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(
            uri.path,
           'Content-Type' => 'application/json',
           'Authorization' => token
        )

        res = http.request(req)
        current_edit = JSON.parse(res.body)

        return current_edit['id']
      end
      
      def self.open_edit(token, app_id)
        
        get_edit_path = "/v1/applications/#{app_id}/edits"
        get_edit_url = BASE_URL + get_edit_path

        uri = URI(get_edit_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/json'
        )

        res = http.request(req)
        current_edit = JSON.parse(res.body)

        UI.message("eTag #{res.header['ETag']}")

        return current_edit['id'], res.header['ETag']
      end

      def self.get_current_apk_etag(token, app_id, edit_id, apk_id)

        get_apks_etag = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}"
        get_apks_etag_url = BASE_URL + get_apks_etag

        uri = URI(get_apks_etag_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/json'
        )

        res = http.request(req)
        return res.header['ETag']
      end

      def self.get_current_apk_id(token, app_id, edit_id)

        get_apks_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks"
        get_apks_url = BASE_URL + get_apks_path

        uri = URI(get_apks_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/json'
        )

        res = http.request(req)
        if !res.body.nil? 
        apks = JSON.parse(res.body)
        firstAPK = apks[0]
        apk_id = firstAPK['id']
        return apk_id
        end
      end

      def self.replaceExistingApk(token, app_id, edit_id, apk_id, eTag, apk_path)

        replace_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}/replace"
        local_apk = File.open(apk_path, "r").read
              
        replace_apk_url = BASE_URL + replace_apk_path
        uri = URI(replace_apk_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.write_timeout = 10000
        req = Net::HTTP::Put.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/vnd.android.package-archive',
            'If-Match' => eTag
            )

        req.body = local_apk
        res = http.request(req)
        return res.code
      end

      def self.delete_apk(token, app_id, edit_id, apk_id, eTag)

        delete_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}" 
        delete_apk_url = BASE_URL + delete_apk_path

        UI.message("delete_apk_url #{delete_apk_url}")

        uri = URI(delete_apk_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Delete.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/vnd.android.package-archive',
            'If-Match' => eTag
            )

        res = http.request(req)
        result_json = JSON.parse(res.body)
      end

      def self.uploadNewApk(token, app_id, edit_id, apk_path)

        add_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/upload" 
        add_apk_url = BASE_URL + add_apk_path
        local_apk = File.open(apk_path, 'r').read

        uri = URI(add_apk_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.write_timeout = 10000
        http.read_timeout = 10000
        req = Net::HTTP::Post.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/vnd.android.package-archive'
            )

        req.body = local_apk
        res = http.request(req)
        result_json = JSON.parse(res.body)
      end

      def self.commit_edit(token, app_id, edit_id, eTag)

        commit_edit_path = "/v1/applications/#{app_id}/edits/#{edit_id}/commit" 
        commit_edit_url = BASE_URL + commit_edit_path

        uri = URI(commit_edit_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(
            uri.path,
            'Authorization' => token,
            'If-Match' => eTag
            )

        res = http.request(req)
        result_json = JSON.parse(res.body)
      end

      def self.show_message
        UI.message("Hello from the amazon_app_submission plugin helper!")
      end
    end
  end
end
