
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controller/player_controller.dart';

class Metronome extends StatelessWidget {

  final controller = Get.find<PlayerController>();
  @override
  Widget build(BuildContext context) {
    return Obx((){
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(width: 100,),
                  Expanded(child: Text("Smart Metronome",style: GoogleFonts.kanit(fontSize: 18),)),
                  FlutterSwitch(
                    width: 60.0,
                    height: 35.0,
                    toggleSize: 27.0,
                    value: controller.switchMetronome.value,
                    borderRadius: 30.0,
                    padding: 4.0,
                    showOnOff: false,
                    onToggle: (val) => controller.setSwitchMetronome(status: val),
                  )
                ],
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  Expanded(flex: 2,child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Volume",style: GoogleFonts.kanit()),
                      SfSlider(
                        min: 0,
                        max: 100,
                        value: controller.volumeMetronome.value,
                        interval:20,
                        showTicks: false,
                        showLabels: false,
                        enableTooltip: true,
                        showDividers: true,
                        stepSize: 1,
                        onChanged: (dynamic value) {

                          controller.volumeMetronome.value = value;
                        },

                      )
                    ],
                  )),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("L & R",style: GoogleFonts.kanit()),
                      SfSlider(
                        min: -100,
                        max: 100,
                        value: controller.stereoMetronome.value,
                        interval:50,
                        showTicks: false,
                        showLabels: false,
                        enableTooltip: true,
                        showDividers: true,
                        stepSize: 0.1,
                        onChanged: (dynamic value) {
                          controller.stereoMetronome.value = value;
                        },
                      )
                    ],
                  ))
                ],
              ),
              SizedBox(height: 30,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subdivision",style: GoogleFonts.kanit()),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      subdivisionButton(text: "0.5x",onclick: (){
                      //  controller.player!.setMetronome(controller.switchMetronome.value, 0);
                       // controller.player!.setClickSoundSpeed(0.5);
                        controller.speedMetronome.value = "0.5x";
                      }, active: controller.speedMetronome.value == "0.5x"?true:false),
                      SizedBox(width: 20,),
                      subdivisionButton(text: "1x",onclick: (){
                     //   controller.player!.setMetronome(controller.switchMetronome.value, 1);
                       // controller.player!.setClickSoundSpeed(1.0);
                        controller.speedMetronome.value = "1.0x";
                      }, active: controller.speedMetronome.value == "1.0x"?true:false),
                      SizedBox(width: 20,),
                      subdivisionButton(text: "2x",onclick: (){
                      //  controller.player!.setMetronome(controller.switchMetronome.value, 2);
                      //  controller.player!.setClickSoundSpeed(2.0);
                        controller.speedMetronome.value = "2.0x";
                      }, active: controller.speedMetronome.value  == "2.0x"?true:false)
                    ],
                  )
                ],
              ),
              SizedBox(height: 20,),
              Divider(),
              // SizedBox(height: 20,),
              // Align(child: Text("Allegro",style: GoogleFonts.kanit(fontSize: 16)),alignment: Alignment.centerLeft),
              // Row(
              //   children: [
              //     Text("-",style: GoogleFonts.kanit(fontSize: 24)),
              //     Expanded(child: SfSlider(
              //       min: 0,
              //       max: 100,
              //       value: 80,
              //       interval:20,
              //       showTicks: false,
              //       showLabels: false,
              //       enableTooltip: true,
              //       showDividers: true,
              //       stepSize: 1,
              //       onChanged: (dynamic value) {
              //
              //       },
              //     )),
              //     Text("+",style: GoogleFonts.kanit(fontSize: 24)),
              //   ],
              // ),
              SizedBox(height: 20,),
              TextButton(onPressed: (){
                controller.stereoMetronome.value = 0;
                controller.volumeMetronome.value = 100.0;
                controller.speedMetronome.value = "1.0x";
              }, child: Text("Reset",style: GoogleFonts.kanit())),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error,color: Colors.grey.shade600,),
                  SizedBox(width: 10,),
                  Text("Beta Feature",style: GoogleFonts.kanit(color: Colors.grey.shade600)),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Widget subdivisionButton({required bool active,required Function onclick,required String text}){
    return Expanded(child: TextButton(
        child: Text(
            text.toUpperCase(),
            style: GoogleFonts.kanit(fontSize: 15,color: active?Colors.white:Colors.blue)
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            backgroundColor:  MaterialStateProperty.all<Color>(active?Colors.blue:Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: BorderSide(color: active?Colors.white:Colors.blue,width: 1.5)
                )
            )
        ),
        onPressed: () => onclick.call()
    ));
  }
}
