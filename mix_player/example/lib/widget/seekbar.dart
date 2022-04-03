import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player_example/controller/player_controller.dart';
import 'package:rxdart/rxdart.dart';

class SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar(
      {Key? key,
      required this.duration,
      required this.position,
      this.onChangeEnd})
      : super(key: key);

  late SliderThemeData _sliderThemeData;

  final _seekSubject = BehaviorSubject<Duration>();
  final controller = Get.find<PlayerController>();


  init(BuildContext context) {
    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
    if(!controller.dragValue){
      _seekSubject.add(position);
    }

  }

  @override
  Widget build(BuildContext context) {
    init(context);
    return
      StreamBuilder<Duration>(
          stream: _seekSubject.stream,
          builder: (context, snapshot) {

            return snapshot.hasData?Row(
              children: [
                Text(
                  RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("${snapshot.data!}")
                      ?.group(1) ??
                      '${snapshot.data!}',
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SliderTheme(
                        data: _sliderThemeData.copyWith(
                          inactiveTrackColor: Colors.blue.shade200,
                          activeTrackColor: Colors.blueAccent,
                          trackShape: const RectangularSliderTrackShape(),
                          trackHeight: 1.5,
                          thumbColor: Colors.blue,
                          thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                          overlayColor: Colors.blue.withAlpha(32),
                          overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: duration.inMilliseconds.toDouble(),
                          value: snapshot.data!.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            //if(!controller.player!.playerErrorMessage.value){
                              controller.dragValue = true;
                              controller.seekBarValue = value;
                              _seekSubject.add(Duration(milliseconds: value.round()));
                           // }


                          },
                          onChangeEnd: (value) {
                          //  if(onChangeEnd!=null && !controller.player!.playerErrorMessage.value){
                              controller.dragValue = false;
                              onChangeEnd!(Duration(milliseconds: value.round()));
                          //  }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Text(RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                    .firstMatch("${duration-snapshot.data!}")
                    ?.group(1) ??
                    '${duration-snapshot.data!}')
              ],
            ):const SizedBox();
          });
  }

}
