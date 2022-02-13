import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
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
                      Column(
                        children: audioItem.urlSong
                            .asMap()
                            .map((key, value) =>
                            MapEntry(key, midiTrack(item: value)))
                            .values
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                          onPressed: () {},
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
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [const Text("Reset")],
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

  Widget midiTrack({required PlayerUrl item}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          RawMaterialButton(
            onPressed: () {},
            elevation: 2.0,
            fillColor: Colors.white,
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
            value: 100,
            interval: 20,
            showTicks: false,
            showLabels: false,
            enableTooltip: false,
            minorTicksPerInterval: 1,
            onChanged: (dynamic value) {},
          )),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
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
               children: [
                 const Text("Track Name",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                 const SizedBox(height: 5,),
                 const Text("Artist Name -- Alburm Name",style: const TextStyle(fontSize: 13),),
               ],
             ),
             IconButton(onPressed: (){}, icon: Image.asset(
               "assets/images/png/heart.png",
               width: 30,
               height: 30,
             ))
           ],
         ),

          StreamBuilder<PlaybackEventMessage>(stream:controller.player.playbackEventStream.stream ,builder: (context,snapshot){
              if(snapshot.hasData){
                return SeekBar(
                  duration: Duration(seconds: snapshot.data!.duration.toInt()),
                  position: Duration(seconds: snapshot.data!.currentTime.toInt()),
                  onChangeEnd: (positionEnd){
                    controller.seek(position: positionEnd.inSeconds.toDouble());
                  },

                );
              }else{
                return SeekBar(
                  duration: const Duration(),
                  position: const Duration(),
                );
              }
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/png/metronome.png",
                    width: 30,
                    height: 30,
                  )),
              Expanded(
                  child: Row(
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
                          controller.play();
                        },
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 50.0,
                        ),
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
                  )),
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
