
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player/models/request_song.dart';
import 'package:path_provider/path_provider.dart';

import '../viewmodel/player_data.dart';

class MixPlayerController extends GetxController{
  MixPlayer? player;
  // Stream
  var playState = PlayerState.none.obs;
  var playbackEvent = PlaybackEventMessage(currentTime: 0, duration: 0).obs;
  static late Directory pathCache;
  List<PlayerUrl> urlSong = [];

  installDirectoryDocument() async {
    pathCache = await getApplicationDocumentsDirectory();
    urlSong.add(PlayerUrl(url: '${pathCache.path}/mix_audio.wav', icon: '', tag: '',));
    player = MixPlayer(
        urlSong: urlSong.map((e) => RequestSong(url: e.url,tag: e.tag)).toList(),
        onSuccess_: () {
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
        });
  }

  goforward({required double time}) => player!.goforward(time: time);

  gobackward({required double time}) => player!.gobackward(time: time);

  seek({required double position}) => player!.seek(position: position);


  @override
  void onInit() {
    super.onInit();
    installDirectoryDocument();
    // Get.back();
  }

  @override
  void onClose() {
    super.onClose();
    if(player!=null){
      player!.stop();
    }
  }
}