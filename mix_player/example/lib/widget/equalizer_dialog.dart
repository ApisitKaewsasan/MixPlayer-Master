

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controller/player_controller.dart';
import '../models/FrequencyModel.dart';

class Equalizer extends StatelessWidget {

  final controller = Get.find<PlayerController>();



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 20),
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
                  Text("Equalizer",style: TextStyle(fontWeight: FontWeight.bold),),
                  TextButton(onPressed: (){
                    controller.frequecy_item.value = MixPlayer.frequecy.map((e) => FrequencyModel(key_frequency: e,controller_value: 0)).toList();
                    controller.player!.equaliserReset();
                  }, child: Text("Reset",style: TextStyle(fontWeight: FontWeight.bold),))
                ],
              ),
            ),
            Divider(),
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
                          Text("${convertText(values.key_frequency)}"),
                          SfSlider(
                            min: Platform.isAndroid?-1500:-50,
                            max: Platform.isAndroid?1500:50,
                            value: values.controller_value,
                            interval: Platform.isAndroid?500:20,
                            showTicks: true,
                            showLabels: true,
                            enableTooltip: true,
                            showDividers: true,
                            stepSize: 1,
                            onChanged: (dynamic value) {
                              snapshot[key] = FrequencyModel(key_frequency: values.key_frequency,controller_value: value);
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
            }, controller.frequecy_item),
            Divider(),
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
