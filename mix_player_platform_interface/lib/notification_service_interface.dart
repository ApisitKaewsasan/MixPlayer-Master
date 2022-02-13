

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_service_notification.dart';

abstract class NotificationService extends PlatformInterface {
  /// Constructs a MixAudioPlatform.
  NotificationService() : super(token: _token);

  static final Object _token = Object();

  static NotificationService _instance = MethodChannelServiceNotification();


  static NotificationService get instance => _instance;

  static set instance(NotificationService instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  Future<void> init(String playerId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Plays the current audio source at the current index and position.
  // Future<void> onNotificationBackgroundPlayerStateChanged() {
  //   throw UnimplementedError("play() has not been implemented.");
  // }



// Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) {
//   throw UnimplementedError('disposePlayer() has not been implemented.');
// }
}
