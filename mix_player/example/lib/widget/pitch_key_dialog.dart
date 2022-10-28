

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player_example/controller/player_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class PitchKey extends GetView<PlayerController> {

  PitchKey({Key? key}) : super(key: key);

  final pitchSubject  = BehaviorSubject<double>();

  init(){
    pitchSubject.add(controller.player!.pitch);
  }
  @override
  Widget build(BuildContext context) {
    init();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pitch Key",style: GoogleFonts.kanit(fontSize: 18),),
            const SizedBox(height: 30,),
            Column(
              children: [
                StreamBuilder<double>(stream: pitchSubject.stream,builder: (context,snapshot){
                  return snapshot.hasData?SfSlider(
                    min: -6,
                    max: 6,
                    value: snapshot.data,
                    interval: 1,
                    showTicks: true,
                    showLabels: true,
                    enableTooltip: true,
                    showDividers: true,
                    stepSize: 1,
                    onChanged: (dynamic value) {
                      pitchSubject.add(value);

                      controller.player!.setPitch(value);
                    },
                  ):const SizedBox();
                }),
                const SizedBox(height: 30,),
                TextButton(onPressed: (){
                  pitchSubject.add(0);
                  controller.player!.setPitch(0);
                }, child: const Text("Reset"))
              ],
            ),
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error,color: Colors.grey.shade600,),
                const SizedBox(width: 10,),
                Text("Beta Feature",style: GoogleFonts.kanit(color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
