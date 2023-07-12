# native_flutter_downloader

[![Pub Version](https://img.shields.io/pub/v/native_flutter_downloader)](https://pub.dev/packages/native_flutter_downloader)

This plugin allows for the downloading of files using the native capabilities of a device. Specifically, on Android, it utilizes the DownloadManager system service to **Download** files directly to the user's **Download** folder. On iOS, it utilizes the URLSession to **Download** files to the App Documents folder.

# Code Example

```dart

   NativeFlutterDownloader.initialize();


  final permission = await NativeFlutterDownloader.requestPermission();
  if (permission == StoragePermissionStatus.granted) {
    await NativeFlutterDownloader.download(
     urlController.text,
     filename 'your_filename',
     savedFilePath: 'your_directory',
    );
   } else {
      debugPrint('Permission denied =(');
   }





    progressStream = NativeFlutterDownloader.progressStream.listen((event) {
      if (event.status == DownloadStatus.successful) {
        setState(() {
          progress = event.progress;
        });
      } else if (event.status == DownloadStatus.running) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          progress = event.progress;
        });
      } else if (event.status == DownloadStatus.failed) {
        debugPrint('event: ${event.statusReason?.message}');
        debugPrint('Download failed');
      } else if (event.status == DownloadStatus.paused) {
        debugPrint('Download paused');
        Future.delayed(
          const Duration(milliseconds: 250),
          () =>
              NativeFlutterDownloader.attachDownloadProgress(event.downloadId),
        );
      } else if (event.status == DownloadStatus.pending) {
        debugPrint('Download pending');
      }
    });

```

## iOS Configuration

By default, downloaded files are not displayed to the user on the Files app, so no special configuration is needed if you don't want to show them. However, if you want to make the downloaded files visible to the user in the Files app, you can add the following lines to your info.plist file:

```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>
```

These lines enable the necessary permissions for the app to share files with the user's device and display them in the Files app.

## Android Configuration

There is no need for special configuration on Android 10+.

If your app supports Android 9 (API 28) or bellow it is mandatory to call `requestPermission()` before `download()` and check the permission status.

**NOTE**: This plugins expects that `compileSdkVersion` is the latest Android SDK, eg.:

```groovy
android {
    compileSdkVersion 34

    [...]
}
```

### Author

[Md Zuhabul Islam](https:/github.com/zuhabul)

### Maintainer

[Hridoy](https://github.com/hr1d0y)

### Publisher

[CrackTech Limited](https://cracktech.org)
