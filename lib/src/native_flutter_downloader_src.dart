import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'storage_permission_status.dart';

part 'download_progress_src.dart';

class NativeFlutterDownloader {
  static const MethodChannel _channel = MethodChannel(
    'org.cracktech.native_flutter_downloader',
  );

  static StreamController<bool> _permissionStatusStream = StreamController();
  static final StreamController<DownloadProgress> _progressStream =
      StreamController.broadcast();

  static Stream<DownloadProgress> get progressStream => _progressStream.stream;

  /// Initializes the plugin and open the stream to listen to download progress
  static Future<void> initialize() async {
    _channel.setMethodCallHandler((call) {
      if (call.method == 'notifyProgress') {
        final map = call.arguments as Map;
        _progressStream.add(
          DownloadProgress._fromMap(<String, dynamic>{...map}),
        );
        if (Platform.isIOS && map.containsKey('reason')) {
          debugPrint('native_flutter_downloader: ${map['reason']}');
        }
      }
      if (call.method == 'onRequestPermissionResult') {
        final result = call.arguments as bool;
        _permissionStatusStream.add(result);
        _permissionStatusStream.close();
        _permissionStatusStream = StreamController();
      }
      return Future.value(null);
    });
  }

  /// Requests storage permission on Android
  ///
  /// If you app supports Android 9 or lower, the call to request storage permission
  /// is mandatory. Aways returns [StoragePermissionStatus.granted] on Android 10 or higher and on iOS.
  static Future<StoragePermissionStatus> requestPermission() async {
    if (Platform.isIOS) return StoragePermissionStatus.granted;
    try {
      final status = await _channel.invokeMethod<bool>(
        'checkStoragePermission',
      );
      if (status == true) return StoragePermissionStatus.granted;
    } catch (e) {
      debugPrint(e.toString());
      return StoragePermissionStatus.unknown;
    }

    try {
      bool? permissionStatus;
      await _channel.invokeMethod<bool>('requestStoragePermission');
      await for (bool event in _permissionStatusStream.stream) {
        permissionStatus = event;
      }
      if (permissionStatus == null) return StoragePermissionStatus.unknown;
      if (permissionStatus) {
        return StoragePermissionStatus.granted;
      } else {
        return StoragePermissionStatus.denied;
      }
    } catch (e) {
      debugPrint(e.toString());
      return StoragePermissionStatus.unknown;
    }
  }

  /// Create and starts a downlaod task on a local URLSession on iOS or
  /// on the system download manager on Android
  ///
  /// Returns the id of the download task
  ///
  /// If a fileName is not provided, the file name will be extracted from the url and
  /// if the name extracted from the url contains forbidden characters, this characters
  /// will be replaced by a dash (-). The list of forbidden characters are:
  /// ```bash
  /// # % & { } \ < > * ? / $ ! ' " : @ + ` | =
  /// ```
  /// (which covers all characters that are not allowed in most file systems)
  static Future<int> download(
    String url, {
    Map<String, String>? headers,
    String? fileName,
    String? savedFilePath,
  }) async {
    return await _channel.invokeMethod('download', <String, dynamic>{
      'url': url,
      'headers': headers,
      'fileName': fileName,
      'savedFilePath': savedFilePath
    });
  }

  /// Attach the download progress stream to an untracked download task.
  ///
  /// This method is only available on Android and should be called if you want to
  /// track the progress of a download task that has received a status different from [DownloadStatus.running] or [DownloadStatus.pending]
  /// to poll for a new status. If called when the download task is in a status that is **not** considered as a "finished" download,
  /// this may cause unexpected behavior such as multiple progress updates for the same download task.
  ///
  /// Android's download manager will not send any progress updates for a download task
  /// automatically and you have to poll for a new status to get the progress. This package
  /// do the polling for you, but you have to attach the download task to the stream if
  /// you want to get the progress updates after any status update that is considered as a "finished" download
  /// such as [DownloadStatus.paused] or [DownloadStatus.failed].
  ///
  /// If called on iOS, this method will do nothing.
  static Future<void> attachDownloadProgress(int downloadId) async {
    if (Platform.isIOS) return;
    return await _channel
        .invokeMethod('attachDownloadTracker', <String, dynamic>{
      'downloadId': downloadId,
    });
  }

  /// Cancels a list of ongoing downloads and return the number of canceled tasks
  static Future<int> cancel(List<int> downloadIds) async {
    if (Platform.isAndroid) {
      final convertedIds = Int64List.fromList(downloadIds);
      return await _channel.invokeMethod('cancel', {
        'downloadIds': convertedIds,
      });
    } else if (Platform.isIOS) {
      return await _channel.invokeMethod('cancel', {
        'downloadIds': downloadIds,
      });
    }
    throw UnimplementedError();
  }
}
