

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player/player_audio.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controller/player_controller.dart';

class StereoBalance extends StatelessWidget {



   StereoBalance({Key? key, required this.playerAudio}) : super(key: key);

   final RxDouble panSubject  = 0.0.obs;

  final controller = Get.find<PlayerController>();
   final PlayerAudio playerAudio;

  init(){
    panSubject.value = playerAudio.pan;
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
            Text("Stereo Balance",style: GoogleFonts.kanit(fontSize: 18),),
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.blue, // Button color
                    child: InkWell(
                      splashColor: Colors.blueAccent, // Splash color
                      onTap: () {},
                      child: const SizedBox(width: 56, height: 56, child: Icon(Icons.headset_mic_outlined,color: Colors.white,)),
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // Button color
                    child: InkWell(
                      splashColor: Colors.blueAccent, // Splash color
                      onTap: () {},
                      child: const SizedBox(width: 56, height: 56, child: Icon(Icons.download_sharp,color: Colors.white,)),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30,),
            Obx((){
              return Column(
                children: [

                  Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("L & R",style: GoogleFonts.kanit()),
                            Text("${panSubject.value.round()}",style: GoogleFonts.kanit())
                          ],
                        ),
                      ),
                      SfSlider(
                        min: -100,
                        max: 100,
                        value: panSubject.value,
                        interval:20,
                        showTicks: true,
                        showLabels: false,
                        enableTooltip: true,
                        showDividers: true,
                        stepSize: 1,
                        onChanged: (dynamic value) {
                          panSubject.value = value;
                          playerAudio.setStereoBalance(value);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("L",style: GoogleFonts.kanit(color: Colors.grey.shade600)),
                            Text("R",style: GoogleFonts.kanit(color: Colors.grey.shade600))
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  TextButton(onPressed: (){
                    panSubject.value = 0;
                    playerAudio.setStereoBalance(0);
                  }, child: const Text("Reset"))
                ],
              );
            }),
            //
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("Beta Feature",style: GoogleFonts.kanit()),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
