import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/audio_item.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:mix_player/models/extension.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player/player_audio.dart';
import 'package:mix_player_example/viewmodel/player_data.dart';
import 'package:mix_player_example/widget/equalizer_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/FrequencyModel.dart';
import '../widget/export_file_dialog.dart';
import '../widget/metronome_dialog.dart';
import '../widget/pitch_key_dialog.dart';
import '../widget/stereo_balance_dialog.dart';

class PlayerController extends GetxController {
  late MixPlayer player;

  var audioItemSubject =
      PlayerData(urlSong: audioItem.urlSong, artist: audioItem.artist,songName: audioItem.songName).obs;

  var dragValue = false;
  var seekBarValue = 0.0;

  // Stream
  var playState = PlayerState.none.obs;
  var playbackEvent = PlaybackEventMessage(currentTime: 0, duration: 0).obs;

  // metronome ---
  RxDouble speedMetronome = 1.0.obs;
  RxDouble volumeMetronome = 100.0.obs;
  RxDouble stereoMetronome = 0.0.obs;
  RxBool switchMetronome = false.obs;

  RxList<FrequencyModel> frequecy_item = List.generate(
      MixPlayer.frequecy.length,
      (index) => FrequencyModel(
          key_frequency: MixPlayer.frequecy[index], controller_value: 0)).obs;

  setupPlayer() {
    // setup player
    player = MixPlayer(
        urlSong: audioItem.urlSong.map((e) => e.url).toList(),
        duration: audioItem.duration,
        onSuccess: () {
          // download song from server
          player.setModeLoop(false);
          player.setSpeed(speedMetronome.value);
          player.updateVolume(volumeMetronome.value);
          player.setStereoBalance(stereoMetronome.value);
          _subscribeToEvents();

          MixService.instance.downLoadTask(
              request: audioItem.urlSong.map((e) => e.url).toList());
          downloadDialog();
          MixService.instance.onDownLoadTask.listen((event) {
            if (event.isFinish) {
              for (int i = 0; i < event.download.length; i++) {
                audioItem.urlSong[i].download = event.download[i];
              }
              audioItemSubject.value = audioItem;
              Get.back();
            }
          });
          MixService.instance.onProcuessRenderToBuffer.listen((event) {
            print("download -> ${event}");
            if(event == 100){
              Get.back();
            }
          });

        });

  }

  audioExport(FileExtension extension) async {
    if (player.player.first.playing) {
      togglePlay();
    }
    List<String> urlExport = [];
    List<double> panPlayerConfig = [];
    for (int i = 0; i < audioItemSubject.value.urlSong.length; i++) {
      if (player.player[i].isMuse) {
        urlExport.add(audioItemSubject.value.urlSong[i].url);
        panPlayerConfig.add(player.player[i].pan);
      }
    }

    var file = await MixService.instance.audioExport(
        request: urlExport,
        extension: extension,
        reverbConfig: 0.0,
        speedConfig: player.speed,
        panConfig: player.pan,
        pitchConfig: player.pitch,
        frequencyConfig: MixPlayer.frequecy,
        gainConfig: player.frequecy_value,
        panPlayerConfig: panPlayerConfig);
    print("export : ${file}");
  }

  togglePlay() => player.togglePlay(at: playbackEvent.value.currentTime);

  setStereoBalance(double pan) {
    stereoMetronome.value = pan;
    if (switchMetronome.value) {
      player.setStereoBalance(pan);
    }
  }

  setSpeed(double speed) {
    speedMetronome.value = speed;
    if (switchMetronome.value) {
      player.setSpeed(speed);
    }
  }

  setVolumeMetronome(double volume) {
    volumeMetronome.value = volume;
    if (switchMetronome.value) {
      player.updateVolume(volume);
    }
  }

  setSwitchMetronome({required bool status}) {
    if (status) {
      player.setStereoBalance(stereoMetronome.value);
      player.setSpeed(speedMetronome.value);
      player.updateVolume(volumeMetronome.value);
    } else {
      player.setStereoBalance(0);
      player.setSpeed(1.0);
      // player.updateVolume()
    }
  }

  goforward({required double time}) => player.goforward(time: time);

  gobackward({required double time}) => player.gobackward(time: time);

  seek({required double position}) => player.seek(position: position);

  downloadDialog() {
    Get.defaultDialog(
        title: "",
        titlePadding: EdgeInsets.zero,
        barrierDismissible: false,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: StreamBuilder<DownLoadTask>(
              stream: MixService.instance.onDownLoadTask,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Downloading..."),
                      const SizedBox(
                        height: 20,
                      ),
                      LinearProgressIndicator(
                        value: snapshot.data!.progress,
                        backgroundColor: Colors.grey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${snapshot.data!.requestLoop}/${snapshot.data!.requestUrl.length}"),
                          Text(
                              "${(snapshot.data!.progress * 100).toStringAsFixed(1)}%")
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              MixService.instance.cancelDownloadTask(
                                  request: audioItem.urlSong
                                      .map((e) => e.url)
                                      .toList());
                              Get.back();
                            },
                            child: Text("CancelDownload")),
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ));
  }

  procuessRenderDialog() {
    Get.defaultDialog(
        title: "",
        titlePadding: EdgeInsets.zero,
        barrierDismissible: false,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: StreamBuilder<double>(
              stream: MixService.instance.onProcuessRenderToBuffer,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Procuess..."),
                      const SizedBox(
                        height: 20,
                      ),
                      LinearProgressIndicator(
                        value: snapshot.data!.toDouble()/100,
                        backgroundColor: Colors.grey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text("${snapshot.data!.toStringAsFixed(0)}%")
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ));
  }

  _subscribeToEvents() {
    player.playerStateChangedStream.listen((value) {
      playState.value = value;
    });
    player.playbackEventStream.listen((value) {
      playbackEvent.value = value;
    });
  }

  equalizerDialog() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: Equalizer(),
          );
        });
  }

  exportDialog() {
    Get.defaultDialog(title: "Export File Type",titlePadding: EdgeInsets.only(top: 20),content: Center(
      child: ExportFile(onclick: (FileExtension ) {
        Get.back();
         audioExport(FileExtension);
         procuessRenderDialog();
      },),
    ),titleStyle: GoogleFonts.kanit(color: Colors.black,fontSize: 18));
  }

  stereoBalanceDialog({required PlayerAudio playerAudio}) {
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: StereoBalance(playerAudio: playerAudio),
          );
        });
  }

  pitchDialog() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: PitchKey(),
          );
        });
  }

  playerReset() {
    frequecy_item = List.generate(
        MixPlayer.frequecy.length,
        (index) => FrequencyModel(
            key_frequency: MixPlayer.frequecy[index], controller_value: 0)).obs;
    player.playerReset();
  }

  metronomeDialog() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: Metronome(),
          );
        });
  }

  bool midiTrackButtonStatus({required int key, required PlayerUrl item}) {
    if (item.download != null &&
            item.download!.downloadState == DownloadState.error ||
        player.player[key].isMuse == false) {
      return false;
    } else if (item.download != null &&
            item.download!.downloadState == DownloadState.finish ||
        player.player[key].isMuse) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    setupPlayer();
  }
}
