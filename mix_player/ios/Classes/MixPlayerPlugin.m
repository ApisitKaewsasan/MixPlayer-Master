#import "MixPlayerPlugin.h"
#if __has_include(<mix_player/mix_player-Swift.h>)
#import <mix_player/mix_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mix_player-Swift.h"
#endif

@implementation MixPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMixPlayerPlugin registerWithRegistrar:registrar];
}
@end
