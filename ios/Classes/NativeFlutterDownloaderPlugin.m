#import "NativeFlutterDownloaderPlugin.h"
#if __has_include(<native_flutter_downloader/native_flutter_downloader-Swift.h>)
#import <native_flutter_downloader/native_flutter_downloader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_flutter_downloader-Swift.h"
#endif

@implementation NativeFlutterDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeFlutterDownloaderPlugin registerWithRegistrar:registrar];
}
@end
