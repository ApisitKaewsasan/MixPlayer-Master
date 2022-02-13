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

  MixPlayer({required List<String> urlSong}) {
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
              isLocalFile: true));
      _subscribeToEvents(index: i,playerAudio: player[i]);
    }
  }

  play() {
    for (var item in player) {
      if (item.playing) {
        item.pause();
      } else {
        item.play();
      }
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

  setPitch(double pitch){
    for (var item in player) {
      item.setPitch(pitch);
    }
  }

  setEqualizer({required int index,required double value}){
    for (var item in player) {
      item.setEqualizer(index: index, value: value);
    }
  }

  equaliserReset(){
    for (var item in player) {
      item.equaliserReset();
    }
  }

 double get pitch  => player.first.pitch;

  _subscribeToEvents({required int index,required PlayerAudio playerAudio}){
    playerAudio.playbackEventStream.listen((event) {
      playbackEventStream.add(PlaybackEventMessage(currentTime: event.currentTime,duration: event.duration,playerId: event.playerId));
    });
  }


}
