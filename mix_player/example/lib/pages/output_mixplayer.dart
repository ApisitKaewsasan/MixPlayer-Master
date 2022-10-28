
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player_example/controller/mixplayer_controller.dart';

import '../widget/SeekBar.dart';

class OutputMixPlayer extends GetView<MixPlayerController> {
  const OutputMixPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Output Mix"),
      ),
      body: Column(
        children: [
          Expanded(child: SizedBox(height: 30,)),
          controlPlayer()
        ],
      ),
    );
  }
  Widget controlPlayer() {
    return Container(
      padding: const EdgeInsets.only(right: 25, left: 25, bottom: 50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("songName",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),),
                  SizedBox(height: 5,),
                  Text("artist",
                    style: TextStyle(fontSize: 13),),
                ],
              ),
            ],
          ),

          ObxValue<Rx<PlaybackEventMessage>>((snapshot) {
            return SeekBar(
              duration: Duration(seconds: snapshot.value.duration.toInt()),
              position: Duration(seconds: snapshot.value.currentTime.toInt()),
              onChangeEnd: (positionEnd) {
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
                   // controller.metronomeDialog();
                  },
                  icon: Image.asset(
                    "assets/images/png/metronome.png",
                    width: 30,
                    height: 30,
                  )),
              Expanded(
                  child: ObxValue<Rx<PlayerState>>((snapshot) {
                    return Row(
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
                            if(controller.playState.value == PlayerState.ready || controller.playState.value  == PlayerState.playing || controller.playState.value  == PlayerState.paused){
                              controller.player!.togglePlay();
                            }
                          },
                          elevation: 2.0,
                          fillColor: Colors.white,
                          child: snapshot.value != PlayerState.bufferring
                              ? Icon(
                            snapshot.value == PlayerState.playing
                                ? Icons.pause
                                : snapshot.value == PlayerState.paused ||
                                snapshot.value == PlayerState.ready ? Icons
                                .play_arrow : Icons.stop,
                            size: 50.0,
                          )
                              : const SizedBox(
                              child: CircularProgressIndicator(),
                              width: 50.0,
                              height: 50.0),
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
                   // controller.pitchDialog();
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
