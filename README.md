# amazon-app-store-submission

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `amazon_app_submission`, add it to your project by running:

```bash
fastlane add_plugin amazon_app_submission
```

## About amazon_appstore

Upload the apk to the Amazon Appstore using the [App Submission API](https://developer.amazon.com/docs/app-submission-api/overview.html).
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
    apk_path: "<APK_PATH>"
  )
```

## Testing 

For testing the plugin locally you have to get `client_id`, `client_secret`, `app_id` and `apk_path` in fastlane/Fastfile 
please check Usage step to see how you can get them.

Then call `bundle exec fastlane test` in your terminal
