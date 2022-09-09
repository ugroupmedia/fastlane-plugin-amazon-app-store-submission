# fastlane-plugin-amazon-app-submission

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `amazon_app_submission`, add it to your project by running:

```bash
fastlane add_plugin amazon_app_submission
```

## About amazon_app_submission

* Project link on rubygems [fastlane-plugin-amazon_app_submission](https://rubygems.org/gems/fastlane-plugin-amazon_app_submission)
* Upload the apk to the Amazon Appstore using the [App Submission API](https://developer.amazon.com/docs/app-submission-api/overview.html).
* App Submission API Reference is [App Submission RESTFUL API](https://developer.amazon.com/docs/app-submission-api/appsub-api-ref.html).

## Usage

Following the [guide](https://developer.amazon.com/docs/app-submission-api/auth.html), you will need to generate `client_id` and `client_secret` to access the console in advance.

For `app_id` you can get it from Amazon app dashboard
Please set the apk path to `apk_path` field

Call `amazon_app_submission` in your Fastfile.

```ruby
  amazon_app_submission(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    # Optional
    apk_path: "<APK_PATH>",
    upload_apk: true,
    changelogs_folder_path:  "<CHANGELOG_PATH>",
    upload_changelogs: false,
    submit_for_review: false
  )
```

| param | default value | optional | description
|:----------|:-----------:|:-----------:|:-----------:|
client_id | - | false | getting client id from Amazon developer console dashboard
client_secret | - | false | getting client secret from Amazon developer console dashboard
app_id | - | false | getting app id from Amazon developer console dashboard
apk_path | - | true | link where you storing the release apk
upload_apk  | true  | true  | set this to false to not upload an apk. can be used to only upload changelogs
changelogs_folder_path | "" | true | setting the folder path where you have the change logs with different file for each language, if language file not found it will use default.txt
upload_changelogs | false | true | updating the change logs for the upcoming version
submit_for_review | false | true | submit the uploaded APK to the store  

* changelogs folder files name should be:

| Language | File name
|:----------|:-----------:|
English-US | en-US.txt
English-British | en-GB.txt
English-Australia | en-AU.txt
English-India | en-IN.txt
Italian |it-IT.txt
French | fr-FR.txt
Spanish | es-ES.txt
Spanish-Mexican | es-MX.txt
Other | default.txt  

## Testing

For testing the plugin locally you have to get `client_id`, `client_secret`, `app_id` and `apk_path` in fastlane/Fastfile
please check Usage step to see how you can get them.

Then call `bundle exec fastlane test` in your terminal
