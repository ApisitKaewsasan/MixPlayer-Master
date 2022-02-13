

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'notification_service_interface.dart';

class MethodChannelServiceNotification extends NotificationService{
  static final _mainChannel = MethodChannel('mix_audio_player.notification_callback');

  static bool enableNotificationService = true;
  late final String playerId;

  Map<dynamic, dynamic> _invokeMethod( [
    Map<dynamic, dynamic> arguments = const <dynamic, dynamic>{},
  ]) {
    final enhancedArgs = <dynamic, dynamic>{
      ...arguments,
      'playerId': playerId,
    };
    return enhancedArgs;
  }

  Future<void> platformCallHandler(MethodCall call) async {
    final callArgs = call.arguments as Map<dynamic, dynamic>;
    switch (call.method) {
      case 'onError':
       // _onErrorSubject.add(callArgs['message'] as String);
        break;
      case 'onNotificationBackgroundPlayerStateChanged':
        print("onNotificationBackgroundPlayerStateChanged");
      //  _onProcessingStateSubject.add(callArgs['ProcessingState'] as String);
        break;
    // case 'playbackEventMessageStream':
    //   _playbackEventMessageSubject.add(PlaybackEventMessage.fromJson(callArgs));
    //   break;
    }
  }



  @override
  Future<void> init(String playerId) async {
    playerId = playerId;
    _mainChannel.setMethodCallHandler((call) => platformCallHandler(call));
  }

  // @override
  // Future<void> onNotificationBackgroundPlayerStateChanged() async {
  //   return  _mainChannel.invokeMethod('onNotificationBackgroundPlayerStateChanged',_invokeMethod(<dynamic, dynamic>{}));
  // }
}