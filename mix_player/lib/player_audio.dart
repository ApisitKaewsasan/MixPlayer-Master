

import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:audio_player_platform_interface/models/player_mode.dart';
import 'package:audio_player_platform_interface/models/request/AudioData.dart';
import 'package:audio_player_platform_interface/models/respone/playback_event_message.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'models/audio_item.dart';
import 'models/player_state.dart';

class PlayerAudio{
  static final players = <String, PlayerAudio>{};

  late MixAudioPlayerPlatform _platform;
  static const _uuid = Uuid();

  //
  late final String url;
  late final String playerId;
  late double volume;
  late PlayerMode mode;
  double pan = 0.0;
  double pitch = 0;
  double speed = 1.0;
  double reverb = 0;
  bool _initialized = false;
  late AudioItem? audioItem;


  // get
  bool playing = false;
  bool isMuse = false;
  PlayerState playState = PlayerState.none;
  PlaybackEventMessage playbackEventMessage = PlaybackEventMessage(playerId: _uuid.toString(),duration: 0.0,currentTime: 0.0);

  // post
  final _eventSubject = BehaviorSubject<PlaybackEventMessage>();
  final _errorSubject = BehaviorSubject<String>();
  final _playerStateChangedSubject = BehaviorSubject<PlayerState>();

  PlayerAudio({String? playerIds}) : playerId = playerIds ?? _uuid.v4() {
    players[playerId] = this;
  }

  setAudioItem({required AudioItem audioItem,required Function onSuccess,}) {
    _initialized = true;
    this.audioItem = audioItem;
    volume = audioItem.volume!;
    url = audioItem.url;
    _setPlatform(onSuccess);
  }

  setFrequecy({required List<int> frequecy}){
    frequecy = frequecy;
  }

  _setPlatform(Function onSuccess) async {

    _platform = await MixAudioPlatform.instance.init(AudioData(

        playerId: playerId,
        url: audioItem!.url,
        volume: volume,
        title: audioItem!.title,
        albumimageUrl: audioItem!.albumimageUrl,
        artist: audioItem!.artist,
        albumTitle: audioItem!.albumTitle,
        skipInterval: audioItem!.skipInterval!, frequecy: audioItem!.frequecy!, enable_equalizer: audioItem!.enable_equalizer!,isLocalFile: audioItem!.isLocalFile));
    _subscribeToEvents(_platform);

    onSuccess();
  }

  // get
  play({double at = 0.0}){
    if (checkInstallPlatform()) {
      _platform.play(at);
    }
  }

  resume({double at = 0.0}){
    if (checkInstallPlatform()) {
      _platform.resume(at);
    }
  }
  // post
  pause(){
    if (checkInstallPlatform()) {
      _platform.pause();
    }
  }

  setModeLoop(bool mode){
    if (checkInstallPlatform()) {
      _platform.setModeLoop(mode);
    }
  }

  stop(){
    if (checkInstallPlatform()) {
      _platform.stop();
    }
  }

  gobackward(double time){
    if (checkInstallPlatform()) {
      _platform.skipBackward(time);
    }
  }

  goforward(double time){
    if (checkInstallPlatform()) {
      _platform.skipForward(time);
    }
  }

  updateVolume(double volume) {
    if (checkInstallPlatform()) {
      this.volume = volume;
      _platform.updateVolume(volume);

    }
  }

  seek({required double position}){
    if (checkInstallPlatform()) {
      _platform.seek(position);

    }
  }
  reloadPlay(){
    if (checkInstallPlatform()) {
      _platform.reloadPlay();
    }
  }

  setStereoBalance(double pan) {
    if (checkInstallPlatform()) {
      this.pan = pan;
      _platform.setPan(pan);
    }
  }

  setEqualizer({required int index,required double value}){
    if (checkInstallPlatform()) {
      _platform.setEqualizer(index,value);
    }
  }

  wetDryMix({required double mix}){
    if (checkInstallPlatform()) {
      this.reverb = mix;
      _platform.wetDryMix(mix);
    }
  }

  equaliserReset(){
    if (checkInstallPlatform()) {
      _platform.equaliserReset();
    }
  }

  setPitch(double pitch){
    if (checkInstallPlatform()) {
      this.pitch = pitch;
      _platform.setPitch(pitch);
    }
  }

  toggleMute() async {
    if (checkInstallPlatform()) {
      isMuse = !isMuse;
       (await _platform.toggleMute())!;
    }
  }

  setSpeed(double speed){
    if (checkInstallPlatform()) {
      this.speed = speed;
      _platform.setPlaybackRate(speed);
    }
  }

  resetPlayer() {
    if (checkInstallPlatform()) {
      setPitch(0.0);
      // equaliserReset();
      setStereoBalance(0.0);
      updateVolume(100);
    }
  }

  //  close player
  disposePlayer() {
    if (checkInstallPlatform()) {
      _initialized = false;
      _platform.disposePlayer();
      _eventSubject.close();
      _errorSubject.close();
      _playerStateChangedSubject.close();
    }
  }

  _subscribeToEvents(MixAudioPlayerPlatform platform) {
    platform.playbackEventMessageStream.listen((event) {
      playbackEventMessage = event;
      _eventSubject.add(PlaybackEventMessage(playerId: event.playerId,duration: event.duration,currentTime: event.currentTime));


    });
    platform.onErrorPlayerStream.listen((event) {
      _errorSubject.add(event);
    });

    platform.onPlayerStateChangedStream.listen((event) {
      playing = PlayerStateGet.getPlayerState(event) == PlayerState.playing
          ? true
          : false;
      playState = PlayerStateGet.getPlayerState(event);

      _playerStateChangedSubject.add(PlayerStateGet.getPlayerState(event));
    });
  }

  bool checkInstallPlatform(){
    if (!_initialized) {
      _errorSubject.add("AudioItem Not Install");
    }

    return _initialized;
  }

  /// A stream of [PlaybackEvent]s.
  Stream<PlaybackEventMessage> get playbackEventStream => _eventSubject.stream;

  Stream<String> get onErrorPlayerStream => _errorSubject.stream;

  Stream<PlayerState> get onPlayerStateChangedStream =>
      _playerStateChangedSubject.stream;


}