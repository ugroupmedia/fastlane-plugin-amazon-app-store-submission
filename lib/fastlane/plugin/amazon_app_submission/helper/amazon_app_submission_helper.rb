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
        uri = URI('https://api.amazon.com/auth/o2/token')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = {client_id: client_id, grant_type: 'client_credentials',
                   client_secret: client_secret, scope: "appstore::apps:readwrite" }.to_json

        res = http.request(req)
        result_json = JSON.parse(res.body)
        auth_token = "Bearer #{result_json['access_token']}"

        if result_json['error'] == 'invalid_scope'
          UI.crash!("It seems that the provided security profile is not attached to the App Submission API")
        end
        UI.crash!(res.body) unless res.code == '200'

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
        UI.crash!(res.body) unless res.code == '200'
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

        return current_edit['id'], res.header['ETag']
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
          firstAPK = apks.kind_of?(Array) ? apks[0] : apks
          apk_id = firstAPK['id']
          return apk_id
        end
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
        UI.crash!(res.body) unless res.code == '200'
        return res.header['ETag']
      end

      def self.replaceExistingApk(token, app_id, edit_id, apk_id, eTag, apk_path, transport_timeout, should_retry = true)

        replace_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}/replace"
        local_apk = File.open(apk_path, "r").read

        apk_uri = URI.parse(apk_path)
        apk_name = apk_uri.path.split('/').last

        replace_apk_url = BASE_URL + replace_apk_path
        uri = URI(replace_apk_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.write_timeout = transport_timeout
        http.read_timeout = transport_timeout
        req = Net::HTTP::Put.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/vnd.android.package-archive',
            'fileName' => apk_name,
            'If-Match' => eTag
            )

        req.body = local_apk
        res = http.request(req)
        
        replace_apk_response = JSON.parse(res.body)
        # Retry again if replace failed
        if res.code == '412' && should_retry
          UI.important("replacing the apk failed, retrying uploading it again...")
          retry_code, retry_res = replaceExistingApk(token, app_id, edit_id, apk_id, eTag, apk_path, transport_timeout, false)
          UI.crash!(retry_res) unless retry_code == '200'
        end
        return res.code, replace_apk_response
      end

      def self.delete_apk(token, app_id, edit_id, apk_id, eTag)

        delete_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}"
        delete_apk_url = BASE_URL + delete_apk_path

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
        UI.crash!(res.body) unless res.code == '200'
        result_json = JSON.parse(res.body)
      end

      def self.uploadNewApk(token, app_id, edit_id, apk_path, transport_timeout)

        add_apk_path = "/v1/applications/#{app_id}/edits/#{edit_id}/apks/upload"
        add_apk_url = BASE_URL + add_apk_path
        local_apk = File.open(apk_path, 'r').read

        uri = URI(add_apk_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.write_timeout = transport_timeout
        http.read_timeout = transport_timeout
        req = Net::HTTP::Post.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/vnd.android.package-archive'
            )

        req.body = local_apk
        res = http.request(req)
        UI.crash!(res.body) unless res.code == '200'
        result_json = JSON.parse(res.body)
      end

      def self.update_listings(token, app_id, edit_id, changelogs_path, upload_changelogs)

        listings_path = "/v1/applications/#{app_id}/edits/#{edit_id}/listings"
        listings_url = BASE_URL + listings_path

        uri = URI(listings_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/json'
        )

        res = http.request(req)
        UI.crash!(res.body) unless res.code == '200'
        listings_response = JSON.parse(res.body)

        # Iterating over the languages for getting the ETag.
        listings_response['listings'].each do |lang, listing|
        lang_path = "/v1/applications/#{app_id}/edits/#{edit_id}/listings/#{lang}"
        lang_url = BASE_URL + lang_path

        uri = URI(lang_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(
              uri.path,
              'Authorization' => token,
              'Content-Type' => 'application/json'
          )
        etag_response = http.request(req)
        UI.crash!(etag_response) unless etag_response.code == '200'
        etag = etag_response.header['Etag']

        recent_changes = find_changelog(
          changelogs_path,
          lang,
          upload_changelogs,
        )

        listing[:recentChanges] = recent_changes

        update_listings_path = "/v1/applications/#{app_id}/edits/#{edit_id}/listings/#{lang}"
        update_listings_url = BASE_URL + update_listings_path

        uri = URI(update_listings_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Put.new(
            uri.path,
            'Authorization' => token,
            'Content-Type' => 'application/json',
            'If-Match' => etag
        )

        req.body = listing.to_json
        res = http.request(req)
        UI.crash!(res.body) unless res.code == '200'
        listings_response = JSON.parse(res.body)
        end
      end

      def self.find_changelog(changelogs_path, language, upload_changelogs)
        # The Amazon appstore requires you to enter changelogs before reviewing.
        # Therefore, if there is no metadata, hyphen text is returned.
        changelog_text = '-'
        return changelog_text if !upload_changelogs

        path = File.join(changelogs_path, "#{language}.txt")
        if File.exist?(path) && !File.zero?(path)
          changelog_text = File.read(path, encoding: 'UTF-8')
        else
          defalut_changelog_path = File.join(changelogs_path, 'default.txt')
          if File.exist?(defalut_changelog_path) && !File.zero?(defalut_changelog_path)
            changelog_text = File.read(defalut_changelog_path, encoding: 'UTF-8')
          else
            UI.message("Could not find changelog for language '#{language}' at path #{path}...")
          end
        end
        changelog_text
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
        UI.crash!(res.body) unless res.code == '200'
        result_json = JSON.parse(res.body)
      end
    end
  end
end
