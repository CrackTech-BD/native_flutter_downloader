# native_flutter_downloader

[![Pub Version](https://img.shields.io/pub/v/native_flutter_downloader)](https://pub.dev/packages/native_flutter_downloader)

This plugin allows for the downloading of files using the native capabilities of a device. Specifically, on Android, it utilizes the DownloadManager system service to **Download** files directly to the user's **Download** folder. On iOS, it utilizes the URLSession to **Download** files to the App Documents folder.

## iOS Configuration

By default, downloaded files are not displayed to the user on the Files app, so no special configuration is needed if you don't want to show them. However, if you want to make the downloaded files visible to the user in the Files app, you can add the following lines to your info.plist file:

xml
Copy code
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>

These lines enable the necessary permissions for the app to share files with the user's device and display them in the Files app.

## Android Configuration

There is no need for special configuration on Android 10+.

If your app supports Android 9 (API 28) or bellow it is mandatory to call `requestPermission()` before `download()` and check the permission status.<br><br>

**NOTE**: This plugins expects that `compileSdkVersion` is the latest Android SDK, eg.:

```groovy
android {
    compileSdkVersion 33

    [...]
}
```

# native_flutter_downloader
