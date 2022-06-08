# amazon-app-store-submission

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `amazon-app-store-submission`, add it to your project by running:

```bash
fastlane add_plugin amazon-app-store-submission
```

## About amazon_appstore

Upload the apk to the Amazon Appstore using the [App Submission API](https://developer.amazon.com/docs/app-submission-api/overview.html).
* App Submission API Reference is [App Submission RESTFUL API](https://developer.amazon.com/docs/app-submission-api/appsub-api-ref.html).

## Usage

Following the [guide](https://developer.amazon.com/docs/app-submission-api/auth.html), you will need to generate `client_id` and `client_secret` to access the console in advance.

Call `amazon_app_submission` in your Fastfile.

```ruby
  amazon_app_submission(
    client_id: "<CLIENT_ID>",
    client_secret: "<CLIENT_SECRET>",
    app_id: "<APP_ID>",
    apk_path: "<APK_PATH>"
  )
```
