

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_player.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controller/player_controller.dart';
import '../models/FrequencyModel.dart';

class Equalizer extends StatelessWidget {

  final controller = Get.find<PlayerController>();

   Equalizer({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Equalizer",style: TextStyle(fontWeight: FontWeight.bold),),
                  TextButton(onPressed: (){
                    controller.frequencyItem.value = MixPlayer.frequecy.map((e) => FrequencyModel(keyFrequency: e,controllerValue: 0)).toList();
                    controller.player!.equaliserReset();
                  }, child: const Text("Reset",style: TextStyle(fontWeight: FontWeight.bold),))
                ],
              ),
            ),
            const Divider(),
            ObxValue<RxList<FrequencyModel>>((snapshot){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot
                      .asMap()
                      .map((key, values) => MapEntry(
                    key,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${convertText(values.keyFrequency)}"),
                          SfSlider(
                            min: Platform.isAndroid?-1500:-50,
                            max: Platform.isAndroid?1500:50,
                            value: values.controllerValue,
                            interval: Platform.isAndroid?500:20,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            showDividers: true,
                            stepSize: 1,
                            onChanged: (dynamic value) {
                              snapshot[key] = FrequencyModel(keyFrequency: values.keyFrequency,controllerValue: value);
                              controller.player!.setEqualizer(index: key, value: value);
                            },
                          ),
                          const SizedBox(height: 10,)
                        ],
                      ),
                    ),
                  ))
                      .values
                      .toList(),

                ),
              );
            }, controller.frequencyItem),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Object convertText(double key){

    // if(key >= 10000){
    //   return  "${key/10000}".split(".")[0]+" Hz";
    // }else{
    //   return "${key.toInt()} Hz";
    // }

    return "${key.toInt()} Hz";

  }
}
