import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_audio_player.dart';
import 'models/request/AudioData.dart';
import 'models/request/play_request.dart';
import 'models/respone/playback_event_message.dart';


abstract class MixAudioPlatform extends PlatformInterface {
  /// Constructs a MixAudioPlatform.
  MixAudioPlatform() : super(token: _token);

  static final Object _token = Object();

  static MixAudioPlatform _instance = MethodChannelMixAudio();


  static MixAudioPlatform get instance => _instance;

  static set instance(MixAudioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  Future<MixAudioPlayerPlatform> init(AudioData request) {
    throw UnimplementedError('init() has not been implemented.');
  }

  MixAudioPlayerPlatform service() {
    throw UnimplementedError('init() has not been implemented.');
  }


  // Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) {
  //   throw UnimplementedError('disposePlayer() has not been implemented.');
  // }
}


abstract class MixAudioPlayerPlatform {
  final String id;

  MixAudioPlayerPlatform(this.id);



  /// Plays the current audio source at the current index and position.
  Future<void> play() {
    throw UnimplementedError("play() has not been implemented.");
  }


  Future<void> setPlaybackRate(double rate) {
    throw UnimplementedError("pause() has not been implemented.");
  }

  Future<void> pause() {
    throw UnimplementedError("pause() has not been implemented.");
  }

  Future<void> stop() {
    throw UnimplementedError("stop() has not been implemented.");
  }

  Future<void> skipBackward(double time) {
    throw UnimplementedError("gobackward() has not been implemented.");
  }

  Future<void> skipForward(double time) {
    throw UnimplementedError("goforward() has not been implemented.");
  }
  Future<void> updateVolume(double time) {
    throw UnimplementedError("updateVolume() has not been implemented.");
  }
  Future<void> setPan(double time) {
    throw UnimplementedError("setPan() has not been implemented.");
  }

  Future<void> seek(double time) {
    throw UnimplementedError("seek() has not been implemented.");
  }


  Future<bool?> toggleMute() {
    throw UnimplementedError("toggleMute() has not been implemented.");
  }



  Future<void> onErrorPlayer() {
    throw UnimplementedError("onErrorPlayer() has not been implemented.");
  }

  Future<void> onRefresh() {
    throw UnimplementedError("onRefresh() has not been implemented.");
  }


  Future<void> disposePlayer() {
    throw UnimplementedError("stop() has not been implemented.");
  }

  Future<void> setPitch(double pitch) {
    throw UnimplementedError("setPitch() has not been implemented.");
  }

  Future<void> setEqualizer(int index,double value) {
    throw UnimplementedError("setEqualizer() has not been implemented.");
  }

  Future<void> wetDryMix(double value) {
    throw UnimplementedError("wetDryMix() has not been implemented.");
  }

  Future<void> equaliserReset() {
    throw UnimplementedError("equaliserReset() has not been implemented.");
  }


  Future<void> downloadTask(List<String> request) {
    throw UnimplementedError("downloadTask() has not been implemented.");
  }

  Future<String?> audioExport(List<String> request,String extension,double reverbConfig,double speedConfig,double panConfig,double pitchConfig,
      List<double> frequencyConfig,List<double> gainConfig,List<double> panPlayerConfig) {
    throw UnimplementedError("audioExport() has not been implemented.");
  }

  /// Stream of changes on player state.
  ///


  Stream<double> get onProcuessRenderToBufferStream {
    throw UnimplementedError(
        'onProcuessRenderToBufferStream has not been implemented.');
  }

  Stream<String> get onDownLoadTaskStream {
    throw UnimplementedError(
        'onDownLoadTaskStream has not been implemented.');
  }

  Stream<String> get onPlayerStateChangedStream {
    throw UnimplementedError(
        'onPlayerStateChangedStream has not been implemented.');
  }





  Stream<String> get onErrorPlayerStream {
    throw UnimplementedError(
        'onErrorPlayerStream has not been implemented.');
  }


  /// A broadcast stream of playback events.
  Stream<PlaybackEventMessage> get playbackEventMessageStream {
    throw UnimplementedError(
        'playbackEventMessageStream has not been implemented.');
  }

}