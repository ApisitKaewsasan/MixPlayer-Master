import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:audio_player_platform_interface/models/player_mode.dart';
import 'package:audio_player_platform_interface/models/request/AudioData.dart';
import 'package:media_info/media_info.dart';
import 'package:mix_player/player_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'mix_service.dart';
import 'models/PlaybackEventMessage.dart';
import 'models/audio_item.dart';
import 'models/download_task.dart';
import 'models/player_state.dart';
import 'models/request_song.dart';

class MixPlayer {
  List<PlayerAudio> player = <PlayerAudio>[];
  List<RequestSong> metronomeSound = <RequestSong>[];
  late List<RequestSong>? urlSong;
   double duration = 0;
  bool modeLoop = false;
  bool metronome = false;
  double _metronomeVolumeTemp = 100;

  String metronomeTag = "";

  // static List<double> frequecy = [
  //   32,
  //   64,
  //   128,
  //   250,
  //   500,
  //   10000,
  //   20000,
  //   40000,
  //   80000,
  //   160000
  // ];

  static List<double> frequecy = [60, 230, 910, 3600, 14000];

  List<double> frequecy_value = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  final playbackEventStream = BehaviorSubject<PlaybackEventMessage>();
  final playerStateChangedStream = BehaviorSubject<PlayerState>();
  final playerErrorMessage = BehaviorSubject<String>();

  MixPlayer({required List<RequestSong> urlSong,
    Function()? onSuccess_}) {
    playerStateChangedStream.add(PlayerState.bufferring);

    this.urlSong = urlSong;
    this.metronomeSound = urlSong
        .asMap()
        .map((key, value) => MapEntry(key, value))
        .values
        .toList();
    this.duration = duration;


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
              isLocalFile: true,
              frequecy: frequecy,
              speed: urlSong[i].speed,
              pan: urlSong[i].pan,
              pitch: urlSong[i].pitch,
              duration: urlSong[i].duration),
          onSuccess: () {
            if (i == (urlSong.length - 1)) {
              if (onSuccess_ != null) onSuccess_.call();

              // player[0].setPitch(0);
            }
          });
      _subscribeToEvents(index: i, playerAudio: player[i]);
    }
    playerStateChangedStream.add(PlayerState.ready);

  }

 // setTagMetronome(String tag) => metronomeTag = tag;

  // updateMetronome(bool metronome) {
  //   this.metronome = metronome;
  //   player.forEach((element) {
  //     if (!metronome && element.url.songExtension == SongExtension.Click) {
  //       print("index 1 => ${element.url.tag}  ${element.url.songExtension}");
  //       element.updateVolume(0);
  //     } else if (metronome &&
  //         element.url.songExtension == SongExtension.Click) {
  //       print("index 2 => ${element.url.tag}  ${element.url.songExtension}");
  //       if (element.url.tag == metronomeTag) {
  //         element.updateVolume(_metronomeVolumeTemp);
  //       } else {
  //         element.updateVolume(0);
  //       }
  //     }
  //   });
  // }

  updateMetronome(bool metronome) {
    this.metronome = metronome;
    player.forEach((element) {
      if (!metronome && element.url.songExtension == SongExtension.Click) {
        print("index 1 => ${element.url.tag}  ${element.url.songExtension}");
        element.updateVolume(0);
      } else if (metronome &&
          element.url.songExtension == SongExtension.Click) {
        print("index 2 => ${element.url.tag}  ${element.url.songExtension}");
        if (element.url.tag == metronomeTag) {

        } else {
          element.updateVolume(0);
        }
      }
    });
  }

  togglePlay({double at = 0.0}) {
    for (int i = 0; i < player.length; i++) {
      if (player[i].playState == PlayerState.playing) {
        player[i].playState = PlayerState.paused;
        player[i].pause();
      } else if (player[i].playState == PlayerState.paused) {
        player[i].playState = PlayerState.playing;
        player[i].resume(at: player.first.playbackEventMessage.currentTime);
      } else {
        player[i].playState = PlayerState.playing;
        player[i].play(at: 0.0);
      }
    }
    updateMetronome(metronome);
  }


  reloadPlay() {
    for (int i = 0; i < player.length; i++) {
      player[i].reloadPlay();
    }
  }

  stop() {
    for (var item in player) {
      item.stop();
    }
  }

  setStereoBalanceMetronome(double pan) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Click) {
        item.setStereoBalance(pan);
      }
    }
  }

  setStereoBalance(double pan) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Song) {

      }
      item.setStereoBalance(pan);
    }
  }

  // setModeLoop(bool mode) {
  //   modeLoop = mode;
  //   for (var item in player) {
  //     item.setModeLoop(mode);
  //   }
  // }

  updateVolume(double volume) {
    for (var item in player) {
      // if (item.url.songExtension == SongExtension.Song) {
      //
      // }
      item.updateVolume(volume);
    }
  }

  updateVolumeMetronome(double volume) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Click) {
        _metronomeVolumeTemp = volume;
        player.forEach((element) {
          if (metronome && element.url.songExtension == SongExtension.Click) {
            if (element.url.tag == metronomeTag) {
              item.updateVolume(volume);
            }
          }
        });
      }
    }
  }

  goforward({required double time}) {
    for (var item in player) {
      item.goforward(time);
    }
  }

  gobackward({required double time}) {
    for (var item in player) {
      item.gobackward(time);
    }
  }

  seek({required double position}) {
    for (var item in player) {
      item.seek(position: position);
    }
  }

  setSpeed(double speed) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Song) {
        item.setSpeed(speed);
      }
    }
  }

  setPitch(double pitch) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Song) {
        item.setPitch(pitch);
      }
    }
  }

  setEqualizer({required int index, required double value}) {
    for (var item in player) {
      if (item.url.songExtension == SongExtension.Song) {
        this.frequecy_value[index] = value;
        item.setEqualizer(index: index, value: value);
      }
    }
  }

  equaliserReset() {
    frequecy_value = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (var item in player) {
      item.equaliserReset();
    }
  }

  playerReset() {
    equaliserReset();
    setPitch(0.0);
    updateVolume(80.0);
    setStereoBalance(0);
    player.forEach((element) {
      if (element.url.songExtension == SongExtension.Song) {
        if (element.isMuse) {
          element.toggleMute();
        }
      }
    });
  }

  disposePlayer() {
    player.forEach((element) {
      element.disposePlayer();
    });
  }

  PlayerState get playState => player.first.playState;

  bool get playing => player.first.playing;

  double get pitch => player.first.pitch;

  double get speed => player.first.speed;

  double get pan => player.first.pan;

  _subscribeToEvents({required int index, required PlayerAudio playerAudio}) {
    playerAudio.onErrorPlayerStream.listen((event) {
      print("onErrorPlayerStream ${event}");
    });
    playerAudio.onPlayerStateChangedStream.listen((event) {
      if (event == PlayerState.complete) {
        if (player
            .where(
                (element) => element.playState == PlayerState.complete)
            .toList()
            .length ==
            player.length &&
            event == PlayerState.complete) {
          playerStateChangedStream.add(PlayerState.ready);
          playbackEventStream.add(
              PlaybackEventMessage(currentTime: 0, duration: this.duration));
        }
      } else {
        if (event != PlayerState.error &&
            event != PlayerState.bufferring &&
            event != PlayerState.playing) {
          playerStateChangedStream.add(event);
        } else if (player
            .where((element) => element.playState == PlayerState.error)
            .toList()
            .length ==
            player.length &&
            event == PlayerState.error) {
          playerStateChangedStream.add(event);
        } else if (player
            .where((element) =>
        element.playState == PlayerState.bufferring)
            .toList()
            .length ==
            player.length &&
            event == PlayerState.bufferring) {
          playerStateChangedStream.add(event);
        } else if (player
            .where(
                (element) => element.playState == PlayerState.playing)
            .toList()
            .length ==
            player.length &&
            event == PlayerState.playing) {
          playerStateChangedStream.add(event);
        }
      }
    });

    playerAudio.playbackEventStream.listen((event) {
      playbackEventStream.add(PlaybackEventMessage(
          currentTime: event.currentTime,
          duration: event.duration > 0.0 ? event.duration : this.duration));
      for (int i = 0; i < player.length; i++) {
        if (i == 0) {
          print("*************************");
        }
        if (player.first.playbackEventMessage.currentTime !=
            player[i].playbackEventMessage.currentTime) {
          print(
              "ok player ${i + 1}  => ${player[i].playbackEventMessage
                  .currentTime}");
        } else {
          print(
              "no player ${i + 1} => ${player[i].playbackEventMessage
                  .currentTime}");
        }

        if ((i + 1) == player.length) {
          print("*************************");
        }
      }
    });
  }
}
