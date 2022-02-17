import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player_example/viewmodel/player_data.dart';
import 'package:mix_player_example/widget/SeekBar.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'controller/player_controller.dart';

void main() {
  runApp(GetMaterialApp(
    home: Main1(),
  ));
}


class Main1 extends GetView<PlayerController> {

  init(){
    Get.put(PlayerController());
  }

  @override
  Widget build(BuildContext context) {
    init();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mix Player"),
        actions: [
          IconButton(onPressed: ()=>controller.equalizerDialog(), icon: Image.asset(
            "assets/images/png/eq.png",
            width: 20,
            height: 20,
            color: Colors.white,
          ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ObxValue<Rx<PlayerData>>((snapshot) {
                        if(snapshot.value!=null){
                          return   Column(
                            children: snapshot.value.urlSong
                                .asMap()
                                .map((key, value) =>
                                MapEntry(key, midiTrack(key: key,item: value)))
                                .values
                                .toList(),
                          );
                        }else{
                          return Text("awit..");
                        }
                      },
                        controller.audioItemSubject,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                          onPressed: () => controller.exportDialog(),
                          child: Container(
                            width: 200,
                            alignment: Alignment.center,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(40)),
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.download_sharp),
                                SizedBox(
                                  width: 13,
                                ),
                                Text("Export")
                              ],
                            ),
                          )),
                      TextButton(
                          onPressed: () {
                            controller.playerReset();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [Text("Reset")],
                          ))
                    ],
                  ),
                )),
            controlPlayer()
          ],
        ),
      ),
    );
  }

  Widget midiTrack({required int key,required PlayerUrl item}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          RawMaterialButton(
            onPressed: () {
              controller.player.player[key].toggleMute();
              controller.audioItemSubject.refresh();
            },
            elevation: 2.0,
            fillColor: controller.midiTrackButtonStatus(key: key,item: item)?Colors.white:Colors.grey.shade200,
            child: Image.asset(
              item.icon,
              width: 20,
              height: 20,
            ),
            padding: const EdgeInsets.all(15.0),
            shape: const CircleBorder(),
          ),
          Expanded(
              child: SfSlider(
            min: 0.0,
            max: 100.0,
            value: controller.player.player[key].volume,
            interval: 20,
            showTicks: false,
            showLabels: false,
            enableTooltip: false,
            minorTicksPerInterval: 1,
            onChanged: (dynamic value) {
              controller.player.player[key].updateVolume(value);
              controller.audioItemSubject.refresh();
            },
          )),
          IconButton(onPressed: () {
            controller.stereoBalanceDialog(playerAudio: controller.player.player[key]);
          }, icon: const Icon(Icons.more_vert))
        ],
      ),
    );
  }

  Widget controlPlayer() {
    return Container(
      padding: const EdgeInsets.only(right: 25,left: 25,bottom: 50),
      child: Column(
        children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children:  [
                 Text(controller.audioItemSubject.value.songName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                 SizedBox(height: 5,),
                 Text(controller.audioItemSubject.value.artist,style: TextStyle(fontSize: 13),),
               ],
             ),
             IconButton(onPressed: (){}, icon: Image.asset(
               "assets/images/png/heart.png",
               width: 30,
               height: 30,
             ))
           ],
         ),

          ObxValue<Rx<PlaybackEventMessage>>((snapshot){
            return  SeekBar(
              duration: Duration(seconds: snapshot.value.duration.toInt()),
              position: Duration(seconds: snapshot.value.currentTime.toInt()),
              onChangeEnd: (positionEnd){
                controller.seek(position: positionEnd.inSeconds.toDouble());
              },
            );
          }, controller.playbackEvent),
          // StreamBuilder<PlaybackEventMessage>(stream:controller.player.playbackEventStream.stream ,builder: (context,snapshot){
          //     if(snapshot.hasData){
          //
          //       return SeekBar(
          //         duration: Duration(seconds: snapshot.data!.duration.toInt()),
          //         position: Duration(seconds: snapshot.data!.currentTime.toInt()),
          //         onChangeEnd: (positionEnd){
          //           controller.seek(position: positionEnd.inSeconds.toDouble());
          //         },
          //
          //       );
          //     }else{
          //       return SeekBar(
          //         duration: const Duration(),
          //         position: const Duration(),
          //       );
          //     }
          // }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    controller.metronomeDialog();
                  },
                  icon: Image.asset(
                    "assets/images/png/metronome.png",
                    width: 30,
                    height: 30,
                  )),
              Expanded(
                  child:   ObxValue<Rx<PlayerState>>((snapshot){
                    return  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              controller.gobackward(time: 15.0);
                            },
                            icon: const Icon(
                              Icons.skip_previous,
                              size: 40,
                            )),
                        RawMaterialButton(
                          onPressed: () {
                            controller.togglePlay();
                          },
                          elevation: 2.0,
                          fillColor: Colors.white,
                          child:  snapshot.value!=PlayerState.bufferring?Icon(
                            snapshot.value == PlayerState.playing?Icons.pause:snapshot.value == PlayerState.paused || snapshot.value == PlayerState.ready?Icons.play_arrow:Icons.stop,
                            size: 50.0,
                          ):const SizedBox(child: CircularProgressIndicator(),width: 50.0,height: 50.0),
                          padding: const EdgeInsets.all(10.0),
                          shape: const CircleBorder(),
                        ),
                        IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              controller.goforward(time: 15.0);
                            },
                            icon: const Icon(
                              Icons.skip_next,
                              size: 40,
                            )),
                      ],
                    );
                  }, controller.playState)),
              IconButton(
                  onPressed: () {
                    controller.pitchDialog();
                  },
                  icon: Image.asset(
                    "assets/images/png/picth.png",
                    width: 40,
                    height: 40,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
