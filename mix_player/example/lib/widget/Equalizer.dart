

import 'package:flutter/material.dart';
import 'package:mix_player/mix_player.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/FrequencyModel.dart';

class Equalizer extends StatefulWidget {

  final Function(FrequencyModel,int) onChanged;
  final Function()? onReset;

  const Equalizer({Key? key, required this.onChanged,this.onReset}) : super(key: key);

  @override
  _EqualizerState createState() => _EqualizerState();
}

List<FrequencyModel> frequecy_item = List.generate(MixPlayer.frequecy.length, (index) => FrequencyModel(key_frequency: MixPlayer.frequecy[index],controller_value: 0));

final frequency = BehaviorSubject<List<FrequencyModel>>()..add(frequecy_item);

class _EqualizerState extends State<Equalizer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Equalizer",style: TextStyle(fontWeight: FontWeight.bold),),
                TextButton(onPressed: (){
                  frequecy_item = List.generate(MixPlayer.frequecy.length, (index) => FrequencyModel(key_frequency: MixPlayer.frequecy[index],controller_value: 0));
                  frequency.add(frequecy_item);
                  widget.onReset!.call();
                }, child: Text("Reset",style: TextStyle(fontWeight: FontWeight.bold),))
              ],
            ),
            Divider(),
            StreamBuilder<List<FrequencyModel>>(
              stream: frequency.stream,
              builder: (context, snapshot) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.hasData?snapshot.data!
                      .asMap()
                      .map((key, values) => MapEntry(
                    key,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(flex: 1,child: Text("${convertText(values.key_frequency)}")),
                          Expanded(
                            flex: 9,
                            child: SfSlider(
                              min: -50,
                              max: 50,
                              value: values.controller_value,
                              interval: 20,
                              showTicks: true,
                              showLabels: true,
                              enableTooltip: true,
                              showDividers: true,
                              stepSize: 1,
                              onChanged: (dynamic value) {
                                List<FrequencyModel>? temp = snapshot.data;
                                temp![key] = FrequencyModel(key_frequency: values.key_frequency,controller_value: value);
                                frequency.add(temp);
                                widget.onChanged(temp[key],key);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
                      .values
                      .toList():[],

                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  String convertText(double key){

    if(key >= 10000){
      return  "${key/10000}".split(".")[0]+"k";
    }else{
      return key.toString();
    }

  }
}
