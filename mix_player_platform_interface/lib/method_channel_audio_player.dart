
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'audio_player_platform_interface.dart';
import 'models/request/AudioData.dart';
import 'models/respone/playback_event_message.dart';

/// An implementation of [JustAudioPlatform] that uses method channels.
const METHODCHANNEL_NAME = 'mix_audio_player.methods';
class MethodChannelMixAudio extends MixAudioPlatform {

  static final _mainChannel = MethodChannel(METHODCHANNEL_NAME);

  @override
   init(AudioData request) async {
    await _mainChannel.invokeMethod<void>('init',request.toMap());
    return MethodChannelAudioPlayer(id: request.playerId);
  }

  @override
  Future<MixAudioPlayerPlatform> initService(String playerId) async {
    await _mainChannel.invokeMethod<void>('initService',{'playerId':playerId});
    return MethodChannelAudioPlayer();
  }



  // Map<dynamic, dynamic> _invokeMethod( [
  //   Map<dynamic, dynamic> arguments = const <dynamic, dynamic>{},
  // ]) {
  //   final enhancedArgs = <dynamic, dynamic>{
  //     ...arguments,
  //     'playerId': arguments['id'],
  //   };
  //   return enhancedArgs;
  // }
  //

  // @override
  // Future<DisposePlayerResponse> disposePlayer(
  //     DisposePlayerRequest request) async {
  //   return DisposePlayerResponse.fromMap(
  //       (await _mainChannel.invokeMethod<Map<dynamic, dynamic>>(
  //           'disposePlayer', request.toMap()))!);
  // }
}

/// An implementation of [AudioPlayerPlatform] that uses method channels.
class MethodChannelAudioPlayer extends MixAudioPlayerPlatform {
  late final MethodChannel _channel;

  final _onErrorSubject = BehaviorSubject<String>();

  MethodChannelAudioPlayer({String id = "0"})
      : _channel = MethodChannel(METHODCHANNEL_NAME),
        super(id){
    _channel.setMethodCallHandler((call) => platformCallHandler(call));

  }


  Map<dynamic, dynamic> _invokeMethod( [
    Map<dynamic, dynamic> arguments = const <dynamic, dynamic>{},
  ]) {
    final enhancedArgs = <dynamic, dynamic>{
      ...arguments,
      'playerId': id,
    };
    return enhancedArgs;
  }

   Future<void> platformCallHandler(MethodCall call) async {
    final callArgs = call.arguments as Map<dynamic, dynamic>;

    switch (call.method) {
      case 'onError':
        _onErrorSubject.add(callArgs['message'] as String);
        break;
      // case 'onDownLoadTaskStream':
      //    _onDownLoadTaskSubject.add(callArgs['taskJson'] as String);
      //   break;
    }
  }



  @override
  Future<void> play(double at) async {
    return  _channel.invokeMethod('play',_invokeMethod(<dynamic, dynamic>{'time':at}));
  }

  Future<void> reloadPlay() {
    return  _channel.invokeMethod('reloadPlay',_invokeMethod(<dynamic, dynamic>{}));
  }

  Future<void> setModeLoop(bool mode) {
    return  _channel.invokeMethod('setModeLoop',_invokeMethod(<dynamic, dynamic>{'mode':mode}));
  }

  Future<void> resume(double at) {
    return  _channel.invokeMethod('resume',_invokeMethod(<dynamic, dynamic>{'time':at}));
  }

  Future<void> setPlaybackRate(double rate) {
    return  _channel.invokeMethod('setPlaybackRate',_invokeMethod(<dynamic, dynamic>{'rate':rate}));
  }

  @override
  Future<void> pause() {
    return  _channel.invokeMethod('pause',_invokeMethod(<dynamic, dynamic>{}));
  }
  @override
  Future<void> stop() {
    return  _channel.invokeMethod('stop',_invokeMethod(<dynamic, dynamic>{}));
  }
  @override
  Future<void> skipBackward(double time) {
    return  _channel.invokeMethod('skipBackward',_invokeMethod(<dynamic, dynamic>{'time':time}));
  }
  @override
  Future<void> skipForward(double time) {
    return  _channel.invokeMethod('skipForward',_invokeMethod(<dynamic, dynamic>{'time':time}));
  }
  @override
  Future<void> updateVolume(double volume) {
    return  _channel.invokeMethod('updateVolume',_invokeMethod(<dynamic, dynamic>{'volume':volume}));
  }
  @override
  Future<void> setPan(double pan) {
    return  _channel.invokeMethod('setPan',_invokeMethod(<dynamic, dynamic>{'pan':pan}));
  }

  @override
  Future<void> seek(double time) {
    return  _channel.invokeMethod('seek',_invokeMethod(<dynamic, dynamic>{'seek':time}));
  }

  @override
  Future<bool?> toggleMute() async {
    return  await _channel.invokeMethod('toggleMute',_invokeMethod(<dynamic, dynamic>{}));
  }

  @override
  Future<void> onRefresh() {
    return  _channel.invokeMethod('onRefresh',_invokeMethod(<dynamic, dynamic>{}));
  }

  @override
  Future<void> setPitch(double pitch) {
    return  _channel.invokeMethod('setPitch',_invokeMethod(<dynamic, dynamic>{'pitch':pitch}));
  }

  @override
  Future<void> setEqualizer(int index,double value) {
    return _channel.invokeMethod('setEqualizer',_invokeMethod(<dynamic, dynamic>{'index':index,'value':value}));
  }

  @override
  Future<void> wetDryMix(double mix) {
    return  _channel.invokeMethod('wetDryMix',_invokeMethod(<dynamic, dynamic>{'mix':mix}));
  }

  @override
  Future<void> equaliserReset() {
    return  _channel.invokeMethod('equaliserReset',_invokeMethod(<dynamic, dynamic>{}));
  }

  @override
  Future<void> disposePlayer() {
    return _channel.invokeMethod('disposePlayer',_invokeMethod(<dynamic, dynamic>{}));
  }

  @override
  Future<String?> audioExport(List<String> request,String extension,double reverbConfig,double speedConfig,double panConfig,double pitchConfig,
      List<double> frequencyConfig,List<double> gainConfig,List<double> panPlayerConfig,List<double> volumeConfig) async{
    final String? path = await _channel.invokeMethod('audioExport', _invokeMethod(<String, dynamic>{
      'request': request.toList(),
      'extension':extension,
      'reverbConfig':reverbConfig,
      'speedConfig':speedConfig,
       'panConfig':panConfig,
      'pitchConfig':pitchConfig,
      'frequencyConfig':frequencyConfig,
      'gainConfig':gainConfig.toList(),
      'panPlayerConfig':panPlayerConfig.toList(),
      'volumeConfig':volumeConfig.toList()
    }));
    return path;
  }

  Future<void> cancelDownloadTask(List<String> request) {
    return _channel.invokeMethod('cancelDownloadTask', _invokeMethod(<String, dynamic>{
      'request': request.toList(),
     }));
    }

  @override
  Future<void> downloadTask(List<String> request) async{
     return _channel.invokeMethod('downloadTask', _invokeMethod(<String, dynamic>{
      'request': request.toList(),
    }));
  }

  /// Stream of changes on player state.

  @override
  Stream<String> get onDownLoadTaskStream =>
      EventChannel('mix_audio_player.downLoadTaskStream')
          .receiveBroadcastStream()
          .cast<String>()
          .map((map) => map);

  @override
  Stream<double> get onProcuessRenderToBufferStream  =>
    EventChannel('mix_audio_player.procuessRenderToBuffer')
        .receiveBroadcastStream()
        .cast<double>()
        .map((map) => map);

  @override
  Stream<String> get onErrorPlayerStream => _onErrorSubject.stream;

  @override
  Stream<String> get onPlayerStateChangedStream =>
      EventChannel('mix_audio_player.playerStateChangedStream.${id}')
      .receiveBroadcastStream()
      .cast<String>()
      .map((map) => map);


  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => //_playbackEventMessageSubject.stream;
      EventChannel('mix_audio_player.playbackEventMessageStream.${id}')
          .receiveBroadcastStream()
          .cast<Map<dynamic, dynamic>>()
          .map((map) => PlaybackEventMessage.fromJson(map));

 // _channel.invokeMethod('playbackEventMessageStream',_invokeMethod(<dynamic, dynamic>{}));

}
