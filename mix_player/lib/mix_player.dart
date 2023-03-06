import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:mix_player/player_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'models/PlaybackEventMessage.dart';
import 'models/audio_item.dart';
import 'models/player_state.dart';
import 'models/request_song.dart';

class MixPlayer {
  List<PlayerAudio> player = <PlayerAudio>[];
  List<RequestSong> metronomeSound = <RequestSong>[];
  late List<RequestSong>? urlSong;
  double duration = 0;
  bool modeLoop = false;
  bool metronome = false;
  double metronomeVolumeTemp = 100;
  bool isSeek = false;
  String metronomeTag = "";

  static List<double> frequecy = [60, 230, 910, 3600, 14000];

  List<double> frequecy_value = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  final playbackEventStream = BehaviorSubject<PlaybackEventMessage>();
  final playerStateChangedStream = BehaviorSubject<PlayerState>();
  final playerErrorMessage = BehaviorSubject<String>();

  static Future<double> getFileDuration(String mediaPath) async {

    final mediaInfoSession = await FFprobeKit.getMediaInformation(mediaPath);
    try {
      final mediaInfo = mediaInfoSession.getMediaInformation()!;
      final duration = double.parse(mediaInfo.getDuration()!);
      return duration;
    } catch (e) {
      return 0;
    }
  }

  checkMismatchFile(List<RequestSong> song) async {
    var time = 0.0;
    for (int i = 0; i < urlSong!.length; i++) {
      var value = await getFileDuration(urlSong![i].url);
      if (time == 0) {
        time = value;
      } else if (time != value) {
        playerErrorMessage
            .add("All files have time discrepancies, please try again later.");
        break;
      }
    }
  }

  MixPlayer({required List<RequestSong> urlSong, Function()? onSuccess_}) {
    playerStateChangedStream.add(PlayerState.bufferring);

    this.urlSong = urlSong;
    this.metronomeSound = urlSong
        .asMap()
        .map((key, value) => MapEntry(key, value))
        .values
        .toList();
    this.duration = duration;
   // checkMismatchFile(urlSong);
    for (int i = 0; i < urlSong.length; i++) {
      player.add(PlayerAudio());

      player[i].setAudioItem(
          audioItem: AudioItem(
              enable_equalizer: true,
              title: "",
              albumTitle: "",
              artist: "",
              albumimageUrl: "",
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
      //element.updateVolume(100);
    });
  }

  setModeLoop(bool status){
    modeLoop = status;
    for (int i = 0; i < player.length; i++) {
      player[i].setModeLoop(status);
    }
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
      item.setStereoBalance(pan);
    }
  }

  setStereoBalance(double pan) {
    for (var item in player) {
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
      metronomeVolumeTemp = volume;
      player.forEach((element) {
        item.updateVolume(volume);
      });
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
      item.setSpeed(speed);
    }
  }

  setPitch(double pitch) {
    for (var item in player) {
      item.setPitch(pitch);
    }
  }

  setEqualizer({required int index, required double value}) {
    for (var item in player) {
      this.frequecy_value[index] = value;
      item.setEqualizer(index: index, value: value);
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
      if (element.isMuse) {
        element.toggleMute();
      }
    });
  }

  disposePlayer() {
    player.forEach((element) {
      if(player!=null){
        element.disposePlayer();
      }

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
        playerStateChangedStream.add(event);
        // if (event != PlayerState.error &&
        //     event != PlayerState.bufferring &&
        //     event != PlayerState.playing) {
        //   playerStateChangedStream.add(event);
        // } else if (player
        //     .where((element) => element.playState == PlayerState.error)
        //     .toList()
        //     .length ==
        //     player.length &&
        //     event == PlayerState.error) {
        //   playerStateChangedStream.add(event);
        // } else if (player
        //     .where((element) =>
        // element.playState == PlayerState.bufferring)
        //     .toList()
        //     .length ==
        //     player.length &&
        //     event == PlayerState.bufferring) {
        //   playerStateChangedStream.add(event);
        // } else if (player
        //     .where(
        //         (element) => element.playState == PlayerState.playing)
        //     .toList()
        //     .length ==
        //     player.length &&
        //     event == PlayerState.playing) {
        //   playerStateChangedStream.add(event);
        // }
      }
    });

    playerAudio.playbackEventStream.listen((event) {
      if (event.duration > 0) {
        playbackEventStream.add(PlaybackEventMessage(
            currentTime: event.currentTime,
            duration: event.duration > 0.0 ? event.duration : this.duration));
      }

      // for (int i = 0; i < player.length; i++) {
      //   if (i == 0) {
      //     print("*************************");
      //   }
      //   if (player.first.playbackEventMessage.currentTime !=
      //       player[i].playbackEventMessage.currentTime) {
      //     print(
      //         "ok player ${i + 1}  => ${player[i].playbackEventMessage
      //             .currentTime}");
      //   } else {
      //     print(
      //         "no player ${i + 1} => ${player[i].playbackEventMessage
      //             .currentTime}");
      //   }
      //
      //   if ((i + 1) == player.length) {
      //     print("*************************");
      //   }
      // }
    });
  }
}
