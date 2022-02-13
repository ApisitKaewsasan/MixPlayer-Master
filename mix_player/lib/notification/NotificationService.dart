

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mix_player/models/player_state.dart';

class NotificationService{


  static bool enableNotificationService = true;

  final Future<void> Function(String, Map<String, dynamic>) platformChannelInvoke;

  NotificationService(this.platformChannelInvoke) {
    if (enableNotificationService) {
      startHeadlessService();
    }
  }


  Future<void> startHeadlessService() async {
    return _callWithHandle(
      'startHeadlessService',
      _backgroundCallbackDispatcher,
    );
  }

  Future<void> _callWithHandle(String methodName, Function callback) async {
    if (!enableNotificationService) {
      throw 'The notifications feature was disabled.';
    }
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    await platformChannelInvoke(
      methodName,
      <String, dynamic>{
        'handleKey': _getBgHandleKey(callback),
      },
    );
  }

  List<dynamic> _getBgHandleKey(Function callback) {
    final handle = PluginUtilities.getCallbackHandle(callback);
    assert(handle != null, 'Unable to lookup callback.');
    return <dynamic>[handle!.toRawHandle()];
  }

  void _backgroundCallbackDispatcher() {
    const _channel = MethodChannel('mix_audio_player.notification_callback');

    // Setup Flutter state needed for MethodChannels.
    WidgetsFlutterBinding.ensureInitialized();

    // Reference to the onAudioChangeBackgroundEvent callback.
    Function(PlayerState)? onAudioChangeBackgroundEvent;

    // This is where the magic happens and we handle background events from the
    // native portion of the plugin. Here we message the audio notification data
    // which we then pass to the provided callback.
    _channel.setMethodCallHandler((MethodCall call) async {
      final args = call.arguments as Map<String, dynamic>;
      Function(PlayerState) _performCallbackLookup() {
        final handle = CallbackHandle.fromRawHandle(
          args['updateHandleMonitorKey'] as int,
        );

        // PluginUtilities.getCallbackFromHandle performs a lookup based on the
        // handle we retrieved earlier.
        final closure = PluginUtilities.getCallbackFromHandle(handle);

        if (closure == null) {
          throw 'Fatal Error: Callback lookup failed!';
        }
        return closure as Function(PlayerState);
      }

      if (call.method == 'audio.onNotificationBackgroundPlayerStateChanged') {
        onAudioChangeBackgroundEvent ??= _performCallbackLookup();
        final playerState = args['value'] as String;
        if (playerState == 'playing') {
          onAudioChangeBackgroundEvent!(PlayerState.playing);
        } else if (playerState == 'paused') {
          onAudioChangeBackgroundEvent!(PlayerState.paused);
        } else if (playerState == 'completed') {
         // onAudioChangeBackgroundEvent!(PlayerState.completed);
        }
      } else {
        assert(false, "No handler defined for method type: '${call.method}'");
      }
    });
  }





}
