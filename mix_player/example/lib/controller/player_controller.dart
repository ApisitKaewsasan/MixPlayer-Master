

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/audio_item.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:mix_player_example/widget/Equalizer.dart';
import 'package:mix_player_example/viewmodel/player_data.dart';
import 'package:mix_player_example/widget/pitch_key.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class PlayerController extends GetxController{

  late MixPlayer player;

  var dragValue = false;


  setupPlayer(){
    player = MixPlayer(urlSong: audioItem.urlSong.map((e) => e.url).toList());
    Future.delayed(const Duration(milliseconds: 1000), () {
      MixService.instance.downLoadTask(request: audioItem.urlSong.map((e) => e.url).toList());
      downloadDialog();

    });

  }

  play()=>player.play();

  goforward({required double time})=>player.goforward(time: time);

  gobackward({required double time})=>player.gobackward(time: time);

  seek({required double position})=> player.seek(position: position);

  downloadDialog(){
    Get.defaultDialog(
        title: "",
        titlePadding: EdgeInsets.zero,
        barrierDismissible: false,
        content:  Container(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
          child: StreamBuilder<DownLoadTask>(stream:MixService.instance.onDownLoadTask ,builder: (context,snapshot){
            if(snapshot.hasData){
              if(snapshot.data!.isFinish){
                Get.back();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Downloading..."),
                  const SizedBox(height: 20,),
                  LinearProgressIndicator(
                    value: snapshot.data!.progress,
                    backgroundColor: Colors.grey,
                    valueColor:  const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${snapshot.data!.requestLoop}/${snapshot.data!.requestUrl.length}"),
                      Text("${(snapshot.data!.progress*100).toStringAsFixed(1)}%")
                    ],
                  )
                ],
              );
            }else{
              return const SizedBox();
            }

          }),
        )
    );
  }


  equalizerDialog(){
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: Equalizer(onChanged: (item,index){
              player.setEqualizer(index: index, value: item.controller_value);
            },onReset: (){
              player.equaliserReset();
            },),
          );
        });
  }

  pitchDialog(){
    showModalBottomSheet(
        context: Get.context!,
        builder: (context) {
          return SizedBox(
            child: PitchKey(),
          );
        });
  }

  @override
  void onInit() {
    super.onInit();
    setupPlayer();
  }
}