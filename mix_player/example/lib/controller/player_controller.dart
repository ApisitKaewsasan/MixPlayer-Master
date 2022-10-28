import 'dart:developer';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:mix_player/models/extension.dart';
import 'package:mix_player/models/mix_item.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player/models/request_song.dart';
import 'package:mix_player/player_audio.dart';
import 'package:mix_player_example/viewmodel/player_data.dart';
import 'package:mix_player_example/widget/equalizer_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../models/FrequencyModel.dart';
import '../widget/export_file_dialog.dart';
import '../widget/metronome_dialog.dart';
import '../widget/pitch_key_dialog.dart';
import '../widget/stereo_balance_dialog.dart';

class PlayerController extends GetxController {
   MixPlayer? player;

  var audioItemSubject =
      PlayerData(urlSong: audioItem.urlSong, artist: audioItem.artist,songName: audioItem.songName).obs;

  var dragValue = false;
  var seekBarValue = 0.0;

  // Stream
  var playState = PlayerState.none.obs;
  var playbackEvent = PlaybackEventMessage(currentTime: 0, duration: 0).obs;

  final onInitFirst = BehaviorSubject<bool>();


  // metronome ---
  RxString speedMetronome = "1.0x".obs;
  RxDouble volumeMetronome = 80.0.obs;
  RxDouble stereoMetronome = 0.0.obs;
  RxBool switchMetronome = false.obs;
   DownLoadTask downLoadTask = DownLoadTask(download: [],progress: 0,isFinish: false,requestLoop: 0,requestUrl: []);

  RxList<FrequencyModel> frequencyItem = List.generate(
      MixPlayer.frequecy.length,
      (index) => FrequencyModel(
          keyFrequency: MixPlayer.frequecy[index], controllerValue: 0)).obs;


   Future<String> getFilePath(uniqueFileName) async {
     String path = '';
     Directory dir = await getApplicationDocumentsDirectory();
     path = '${dir.path}/$uniqueFileName';
     return path;
   }

  setupPlayer() async {
   downloadDialog();



   MixService.instance.downLoadTasks(url:  audioItemSubject.value.urlSong.map((e) => e.url).toList());
    MixService.instance.onDownLoadTask.listen((event) {
      downLoadTask = event;
      if(event.isFinish){
        Get.back();
      }
    });
    MixService.instance.onProcuessRenderToBuffer.listen((event) {
      log("download -> $event");
      if(event == 100){
        Get.back();
      }
    });



  }

  initPlayer(){
     if( player!=null){

     }



     if(downLoadTask.isFinish){
       // List<String> tempLocalFile = [];
       //
       //
       // for(int i = 0;i<audioItemSubject.value.clickFile.length;i++){
       //   tempLocalFile.add(event.download[(event.download.length-1)-i].localUrl!);
       //
       // }
       // for(int i = 0;i<audioItemSubject.value.clickFile.length;i++){
       //   event.download.removeAt((event.download.length-1));
       //   audioItemSubject.value.urlSong.removeAt((audioItemSubject.value.urlSong.length-1));
       // }


       for (int i = 0; i < audioItemSubject.value.urlSong.length; i++) {
         audioItemSubject.value.urlSong[i].download = downLoadTask.download[i];
       }

       player = MixPlayer(
           urlSong: audioItemSubject.value.urlSong.map((e) => RequestSong(url: e.download!.localUrl!,tag: e.tag)).toList(),
           onSuccess_: () {
             // download song from server

             _subscribeToEvents();

             if(downLoadTask.download.where((element) => element.downloadState == DownloadState.finish).toList().isNotEmpty){
              // player!.setModeLoop(false);
               // player!.setSpeed(speedMetronome.value);
               player!.updateVolume(volumeMetronome.value);
              audioItemSubject.refresh();
               // player!.setStereoBalance(stereoMetronome.value);

             }else{
               player!.playerErrorMessage.add("Failed to load file, please try again later");
             }

             speedMetronome.refresh();
           });

       //
       // player!.ini_clickSound(localPath: tempLocalFile.reversed.toList(),onSuccess_: (){
       //   print("iniClickSound onSuccess_");
       // });

       audioItemSubject.refresh();
      // Get.back();
     }
  }



  audioExport(FileExtension extension) async {

    if (player!.player.first.playing) {
      togglePlay();
    }
    List<String> urlExport = [];
    List<double> panPlayerConfig = [];
    List<double> volumeConfig = [];
    for (int i = 0; i < audioItemSubject.value.urlSong.length; i++) {
     // if (!player!.player[i].isMuse) {
        urlExport.add(audioItemSubject.value.urlSong[i].download!.localUrl!);
        panPlayerConfig.add(player!.player[i].pan);
        volumeConfig.add(player!.player[i].isMuse?0.0:player!.player[i].volume);
     // }
    }


    MixService.instance.mixAudioFile(mixItem: MixItem(request: urlExport,reverbConfig:  0.0,speedConfig: player!.speed,panConfig: player!.pan,
        panPlayerConfig:panPlayerConfig,volumeConfig: volumeConfig,frequencyConfig: player!.frequecy_value,gainConfig: player!.frequecy_value,pitchConfig: player!.pitch,extension: extension.name,
        fileName: "mix_audio"),
    onSuccess: (outputPath){

    },onBuild: (){
          procuessRenderDialog();
        },onError: (message){
          Get.back();
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.defaultDialog(title: "",contentPadding: const EdgeInsets.only(bottom: 20,left: 20,right: 20),titlePadding: EdgeInsets.zero,textCancel: "Close",content: Center(
              child: Column(
                children: [
                  Text("AudioProcuess Error...!",style: GoogleFonts.kanit(color: Colors.black,fontSize: 16)),
                  const SizedBox(height: 15,),
                  Text(message,style: GoogleFonts.kanit(color: Colors.black.withOpacity(0.8),fontSize: 14)),
                ],
              ),
            ),onCancel: ()=> Get.back(),titleStyle: GoogleFonts.kanit(color: Colors.black,fontSize: 16));

          });

    }, duration: 1);


    // var file = await MixService.instance.audioExport(
    //     request: urlExport,
    //     extension: extension,
    //     reverbConfig: 0.0,
    //     speedConfig: player!.speed,
    //     panConfig: player!.pan,
    //     pitchConfig: player!.pitch,
    //     frequencyConfig: MixPlayer.frequecy,
    //     gainConfig: player!.frequecy_value,
    //     panPlayerConfig: panPlayerConfig,volumeConfig: volumeConfig);
    // print("export : ${file}");
  }

  togglePlay(){
    player!.togglePlay(at: playbackEvent.value.currentTime);
  }

  setStereoBalance(double pan) {

    if (switchMetronome.value) {
      stereoMetronome.value = pan;
     // player!.setStereoBalance(pan);
    }
  }

  setSpeed(double speed) {
  //  speedMetronome.value = speed;
    if (switchMetronome.value) {
      player!.setSpeed(speed);
    }
  }

  setVolumeMetronome(double volume) {
    volumeMetronome.value = volume;
    if (switchMetronome.value) {
      player!.updateVolume(volume);
    }
  }

  setSwitchMetronome({required bool status}) {
 //   player!.setMetronome(status,speedMetronome.value);
    switchMetronome(status);
    player!.updateMetronome(status);
    if (status) {
      player!.setStereoBalance(stereoMetronome.value);
      player!.updateVolume(volumeMetronome.value);

      speedMetronome.refresh();

    } else {
      player!.setStereoBalance(0);
      player!.setSpeed(1.0);
      // player.updateVolume()
    }


  }

  goforward({required double time}) => player!.goforward(time: time);

  gobackward({required double time}) => player!.gobackward(time: time);

  seek({required double position}) => player!.seek(position: position);

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


               //   print("downloadDialog  ${snapshot.data!.requestLoop} / ${snapshot.data!.requestUrl.length} => ${snapshot.data!.progress}");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Downloading..."),
                      const SizedBox(
                        height: 20,
                      ),
                      LinearProgressIndicator(
                        value: snapshot.hasData?snapshot.data!.progress:0.0,
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
                              "${snapshot.hasData?snapshot.data!.requestLoop:0}/${snapshot.hasData?snapshot.data!.requestUrl.length:audioItemSubject.value.urlSong.length}"),
                          Text(
                              "${(snapshot.hasData?snapshot.data!.progress*100:0.0 * 100).toStringAsFixed(1)}%")
                        ],
                      ),
                      const SizedBox(
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
                            child: const Text("CancelDownload")),
                      )
                    ],
                  );
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
                      Text("${snapshot.data!.toStringAsFixed(0)}%"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: (){
                            MixService.instance.sessionRenderCancel();
                            Get.back();

                          }, child: const Text("Cancel"))
                        ],
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ));
  }

  _subscribeToEvents() {
    player!.playerStateChangedStream.listen((value) {
      playState.value = value;
    });
    player!.playbackEventStream.listen((value) {
      playbackEvent.value = value;
    });
    player!.playerErrorMessage.listen((value) {
      if(value.isNotEmpty){
        Get.defaultDialog(title: "system error",content: Center(
          child: Column(
            children: [
               Text(value,textAlign: TextAlign.center),
              const SizedBox(height: 15,),
              TextButton(
                onPressed: () { Get.back();  },
                child: const Text("Close"),
              )
            ],
          ),
        ),titlePadding: const EdgeInsets.only(left: 20,right: 20,top: 20),contentPadding: const EdgeInsets.only(top: 20,right: 20,left: 20));
      }
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
    Get.defaultDialog(title: "Export File Type",titlePadding: const EdgeInsets.only(top: 20),content: Center(
      child: ExportFile(onclick: (fileExtension ) {
        Get.back();

        audioExport(fileExtension);

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
    frequencyItem = List.generate(
        MixPlayer.frequecy.length,
        (index) => FrequencyModel(
            keyFrequency: MixPlayer.frequecy[index], controllerValue: 0)).obs;


    player!.playerReset();
    audioItemSubject.refresh();
  }

  metronomeDialog() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return  SizedBox(
            child: Metronome(),
          );
        });
  }

  bool midiTrackButtonStatus({required int key, required PlayerUrl item}) {
    if(player!=null && player!.player.isNotEmpty){
      if (item.download != null &&
          item.download!.downloadState == DownloadState.error || item.download!.downloadState == DownloadState.none ||
          player!.player[key].isMuse) {

        return false;
      } else if (item.download != null &&
          item.download!.downloadState == DownloadState.finish ||
          player!.player[key].isMuse == false) {
        return true;
      } else {
        return false;
      }
    }else {
      return false;
    }

  }



  @override
  void onInit() {
    super.onInit();
    //player = MixPlayer(urlSong: audioItem.urlSong.map((e) => e.url).toList());
    onInitFirst.value = true;
    onInitFirst.listen((p0) {


    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setupPlayer();

    });
    speedMetronome.listen((p0) {
     // player!.setTagMetronome(p0);
      if(switchMetronome.value){
        if(p0 == "0.5x"){
          setSpeed(0.5);
        }else if(p0 == "1.0x"){
          setSpeed(1.0);
        }else{
          setSpeed(2.0);
        }
      }

    });
    volumeMetronome.listen((p0) {
      if (switchMetronome.value) {
        player!.updateVolumeMetronome(p0);
      }
    });
    stereoMetronome.listen((p0) {
      if (switchMetronome.value) {
        player!.setStereoBalanceMetronome(p0);
      }
    });

  }
}
