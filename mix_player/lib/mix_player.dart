import 'dart:async';

import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:audio_player_platform_interface/models/player_mode.dart';
import 'package:audio_player_platform_interface/models/request/AudioData.dart';
import 'package:mix_player/player_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'models/PlaybackEventMessage.dart';
import 'models/audio_item.dart';
import 'models/player_state.dart';

class MixPlayer {
  List<PlayerAudio> player = <PlayerAudio>[];
  late List<String>? urlSong;
  late double? duration;
  bool modeLoop = false;

  static List<double> frequecy = [
    32,
    64,
    128,
    250,
    500,
    10000,
    20000,
    40000,
    80000,
    160000
  ];
  List<double> frequecy_value = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  final playbackEventStream = BehaviorSubject<PlaybackEventMessage>();
  final playerStateChangedStream = BehaviorSubject<PlayerState>();

  MixPlayer({required List<String> urlSong,double? duration,Function? onSuccess}) {
    this.urlSong = urlSong;
    this.duration = duration;
    playerStateChangedStream.add(PlayerState.ready);
    for (int i = 0; i < urlSong.length; i++) {
      player.add(PlayerAudio());
      player[i].setAudioItem(
          audioItem: AudioItem(
              enable_equalizer: true,
              title: "ApisitKaewsasan",
              albumTitle: "refvrecf",
              artist: "wefcerscf",
              albumimageUrl:
                  "https://images.iphonemod.net/wp-content/uploads/2022/01/Apple-Music-got-2nd-place-in-music-streaming-market-cover.jpg",
              url: urlSong[i],
              isLocalFile: true,frequecy: frequecy,duration: duration!), onSuccess: (){
        if(i == (urlSong.length-1)){
          onSuccess!();
          playbackEventStream.add(PlaybackEventMessage(currentTime: 0,duration: this.duration!));
        }
      });
      _subscribeToEvents(index: i,playerAudio: player[i]);

    }
  }

  togglePlay({double at = 0.0}) {
    for (int i=0;i<player.length;i++) {
      if (player[i].playState == PlayerState.playing) {
        player[i].pause();
        print("pause ${at}");
      }else if(player[i].playState == PlayerState.paused ){
        print("resume ${at}");
        player[i].resume(at: at);
      } else {
        player[i].play(at: 0.0);
      }
    }
  }

  reloadPlay(){
    for (int i=0;i<player.length;i++) {
      player[i].reloadPlay();

    }
  }

  stop() {
    for (var item in player) {
      item.stop();
    }
  }

  setStereoBalance(double pan) {
    for (var item in player) {
      item.setStereoBalance(pan);
    }

  }

  setModeLoop(bool mode){
    modeLoop = mode;
    for (var item in player) {
      item.setModeLoop(mode);
    }

  }

  updateVolume(double volume) {
    for (var item in player) {
      item.updateVolume(volume);
    }
  }


  goforward({required double time}){
    for (var item in player) {
      item.goforward(time);
    }
  }

  gobackward({required double time}){
    for (var item in player) {
      item.gobackward(time);
    }
  }

  seek({required double position}){
    for (var item in player) {
      item.seek(position: position);
    }
  }

  setSpeed(double speed){
    for (var item in player) {
      item.setSpeed(speed);
    }
  }

  setPitch(double pitch){
    for (var item in player) {
      item.setPitch(pitch);
    }
  }

  setEqualizer({required int index,required double value}){
    for (var item in player) {
      this.frequecy_value[index] = value;
      item.setEqualizer(index: index, value: value);
    }
  }


  equaliserReset(){
    frequecy_value = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (var item in player) {
      item.equaliserReset();
    }
  }

  playerReset(){
    equaliserReset();
    setPitch(0.0);
    updateVolume(100.0);
    setStereoBalance(0);
  }

  double get pitch  => player.first.pitch;
  double get speed => player.first.speed;
  double get pan => player.first.pan;

  _subscribeToEvents({required int index,required PlayerAudio playerAudio}){
    playerAudio.onPlayerStateChangedStream.listen((event) {
      if(event == PlayerState.complete){
        playerStateChangedStream.add(PlayerState.ready);
        playbackEventStream.add(PlaybackEventMessage(currentTime: 0,duration: this.duration!));

      }else{
        playerStateChangedStream.add(event);
      }

    });
    playerAudio.playbackEventStream.listen((event) {
      playbackEventStream.add(PlaybackEventMessage(currentTime: event.currentTime,duration: event.duration > 0.0?event.duration:this.duration!));
    });

  }


}
