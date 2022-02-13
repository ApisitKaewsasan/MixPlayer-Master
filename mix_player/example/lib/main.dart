// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'package:flutter/services.dart';
// import 'package:mix_player/mix_player.dart';
// import 'package:mix_player/mix_service.dart';
// import 'package:mix_player/models/audio_item.dart';
// import 'package:mix_player/models/extension.dart';
// import 'package:mix_player/models/player_state.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';
//
// import 'Equalizer.dart';
// import 'main1.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final MixPlayer audioPlayer = MixPlayer();
//
//   late double volume = 100;
//   late double wetDryMix = 0;
//   late double pan = 0;
//   late double pitch = 0;
//
//   String message = 'none';
//   String currenttime = '00:00';
//   PlayerState playerState = PlayerState.none;
//
//
//
//
//
//   @override
//   void initState() {
//     super.initState();
//
// //
//
//     // MixService.instance.downLoadTask(request: [
//     //   "https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview115//v4//bd//84//31//bd843169-11f8-adc6-7da1-0e744dc889f2//mzaf_9976382207184264032.plus.aac.p.m4a",
//     //   "https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview125//v4//ce//32//81//ce32816e-b9e8-e9a8-94bf-40e4f99e3596//mzaf_2990346819158497013.plus.aac.p.m4a",
//     //   "https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview125//v4//bf//dc//a7//bfdca705-3502-a2ba-d4a6-31a34995f79f//mzaf_1275653087888885460.plus.aac.p.m4a",
//     //   "https://audio-ssl.itunes.apple.com//itunes-assets//Music6//v4//6a//81//f9//6a81f917-7bf5-1d40-6469-6eb40f774513//mzaf_3839953628687486964.plus.aac.p.m4a",
//     //   "https://audio-ssl.itunes.apple.com//itunes-assets//Music3//v4//ca//ca//1a//caca1a77-7a61-43b7-9907-a31871de0bc7//mzaf_3360273604681908658.plus.aac.p.m4a"
//     // ]);
//     // MixService.instance.onDownLoadTask.listen((event) {
//     //   print("process - >${event.requestLoop} /  ${event.requestUrl.length}  | ${event.progress}");
//     //   if(event.isFinish){
//     //     event.download.forEach((element) {
//     //       print("urlLocal -> ${element.localUrl}");
//     //     });
//     //
//     //   }
//     // });
//
//     setPlayerAudio(localUrl: "https://dev-api.muse-master.com/api/v1/files/songtest/vocals.mp3");
//   }
//
//   setPlayerAudio({required String localUrl}){
//     audioPlayer.setAudioItem(
//         audioItem: AudioItem(
//             enable_equalizer: true,
//             title: "ApisitKaewsasan",
//             albumTitle: "refvrecf",
//             artist: "wefcerscf",
//             albumimageUrl:
//             "https://images.iphonemod.net/wp-content/uploads/2022/01/Apple-Music-got-2nd-place-in-music-streaming-market-cover.jpg",
//             url: localUrl,isLocalFile: false));
//
// //     audioPlayer.playbackEventStream.listen((event) {
// //       setState(() {
// //         currenttime = "${event.currentTime} : ${event.duration % 60}";
// //       });
// //     });
// //     audioPlayer.onErrorPlayerStream.listen((event) {
// //       setState(() {
// //         message = event.toString();
// //       });
// //     });
// //
// //     audioPlayer.onPlayerStateChangedStream.listen((event) {
// //       setState(() {
// //         playerState = event;
// //       });
// //     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Builder(
//           builder: (context) => Scaffold(
//             appBar: AppBar(
//               title: const Text('Plugin example app'),
//               actions: [
//                 IconButton(
//                     onPressed: () {
//                       equalizer(context);
//                     },
//                     icon: Icon(Icons.equalizer)),
//                 IconButton(
//                     onPressed: () {
//                       MixService.instance.downLoadTask(request: [
//                         "https://dev-api.muse-master.com/api/v1/files/songtest/vocals.mp3",
//                       ]);
//                       MixService.instance.onDownLoadTask.listen((event) async{
//                         print("process - >${event.requestLoop} /  ${event.requestUrl.length}  | ${event.progress}");
//                         if(event.isFinish){
//                           event.download.forEach((element) {
//                             print("urlLocal -> ${element.localUrl}");
//                           });
//
//                         //  print("Export -> ${await MixService.instance.audioExport(request: event.requestUrl,extension: FileExtension.WAV,pitchConfig: audioPlayer.pitch,speedConfig: audioPlayer.speed,panConfig: audioPlayer.pan,reverbConfig: audioPlayer.reverb,frequencyConfig: MixPlayer.frequecy,gainConfig: audioPlayer.frequecy_value,panPlayerConfig: [-1.0])}");
//                         }
//                       });
//
//                       MixService.instance.onProcuessRenderToBuffer.listen((event) {
//                         print("process Render- >${event}");
//                       });
//
//                     },
//                     icon: Icon(Icons.import_export))
//               ],
//             ),
//             body: Center(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                       //  audioPlayer.play();
//                       },
//                       child: Text("Play / pause"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                       //  audioPlayer.pause();
//                       },
//                       child: Text("pause"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                      //   audioPlayer.stop();
//                       },
//                       child: Text("stop"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                      //   audioPlayer.goforward(15);
//                       },
//                       child: Text("+15"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                        // audioPlayer.goforward(-15);
//                       },
//                       child: Text("-15"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: TextButton(
//                               onPressed: () {
//                               //  audioPlayer.setPlaybackRate(0.5);
//                               },
//                               child: Text("0.5x"),
//                             )),
//                         Expanded(
//                             child: TextButton(
//                               onPressed: () {
//                              //   audioPlayer.setPlaybackRate(1);
//                               },
//                               child: Text("1x"),
//                             )),
//                         Expanded(
//                             child: TextButton(
//                               onPressed: () {
//                                // audioPlayer.setPlaybackRate(2);
//                               },
//                               child: Text("2x"),
//                             ))
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                        // audioPlayer.toggleMute();
//                       },
//                       child: Text("toggleMute"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                       //  audioPlayer.resetPlayer();
//                         setState(() {
//                           pan = 0.0;
//                           volume = 100;
//                           pitch = 0.0;
//                         });
//                       },
//                       child: Text("resetPlayer"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       onPressed: () {
//                      //   audioPlayer.disposePlayer();
//
//                       },
//                       child: Text("disposePlayer"),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("volume"),
//                     SfSlider(
//                       min: 0.0,
//                       max: 100.0,
//                       value: volume,
//                       interval: 20,
//                       showTicks: true,
//                       showLabels: true,
//                       enableTooltip: true,
//                       minorTicksPerInterval: 1,
//                       onChanged: (dynamic value) {
//                         setState(() {
//                           volume = value;
//                          // audioPlayer.updateVolume(value);
//                         });
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("pitch"),
//                     SfSlider(
//                       min: -10,
//                       max: 10,
//                       value: pitch,
//                       interval: 5,
//                       showTicks: true,
//                       showLabels: true,
//                       enableTooltip: true,
//                       showDividers: true,
//                       stepSize: 1,
//                       onChanged: (dynamic value) {
//                         setState(() {
//                           pitch = value;
//                          // audioPlayer.setPitch(value);
//                         });
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("wetDryMix"),
//                     SfSlider(
//                       min: -1000,
//                       max: 1000,
//                       value: wetDryMix,
//                       interval: 200,
//                       showTicks: true,
//                       showLabels: true,
//                       enableTooltip: true,
//                       showDividers: true,
//                       stepSize: 1,
//                       onChanged: (dynamic value) {
//                         setState(() {
//                           wetDryMix = value;
//                         //  audioPlayer.wetDryMix(mix: value);
//                         });
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("pan"),
//                     SfSlider(
//                       min: -1,
//                       max: 1,
//                       value: pan,
//                       interval: 1,
//                       showTicks: true,
//                       showLabels: true,
//                       enableTooltip: true,
//                       showDividers: true,
//                       stepSize: 0.1,
//                       onChanged: (dynamic value) {
//                         setState(() {
//                           pan = value;
//                         //  audioPlayer.setPan(value);
//                         });
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("Message -> ${message}"),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("Currenttime -> ${currenttime}"),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text("PlayerState -> ${playerState}"),
//                     SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
//
//   void equalizer(BuildContext context) {
//     showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return SizedBox(
//             child: Equalizer(onChanged: (item,index){
//             //  audioPlayer.setEqualizer(index: index, value: item.controller_value);
//             },onReset: (){
//              // audioPlayer.equaliserReset();
//             },),
//           );
//         });
//   }
// }
