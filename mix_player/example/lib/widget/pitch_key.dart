

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player_example/controller/player_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class PitchKey extends StatelessWidget {
  var pitchSubject  = BehaviorSubject<double>();

  final controller = Get.find<PlayerController>();

  init(){
    pitchSubject.add(controller.player.pitch);
  }
  @override
  Widget build(BuildContext context) {
    init();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Pitch Key",style: GoogleFonts.kanit(),),
          Column(
            children: [
              StreamBuilder<double>(stream: pitchSubject.stream,builder: (context,snapshot){
                return snapshot.hasData?SfSlider(
                  min: -10,
                  max: 10,
                  value: snapshot.data,
                  interval: 5,
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  showDividers: true,
                  stepSize: 1,
                  onChanged: (dynamic value) {
                    pitchSubject.add(value);
                    controller.player.setPitch(value);
                  },
                ):const SizedBox();
              }),
              SizedBox(height: 30,),
              TextButton(onPressed: (){
                pitchSubject.add(0);
                controller.player.setPitch(0);
              }, child: Text("Reset"))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Beta Feature",style: GoogleFonts.kanit()),
            ],
          )
        ],
      ),
    );
  }
}
