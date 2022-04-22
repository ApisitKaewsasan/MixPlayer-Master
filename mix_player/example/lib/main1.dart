


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'viewmodel/player_data.dart';

void main() {
  runApp(MaterialApp(
    home: Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  final onDownLoadTaskSubject =  BehaviorSubject<double>();
  late MixPlayer player;
  var mixService = MixService.instance;

  var cdsfc = 0.0;





  init() async {

    player = MixPlayer(
        urlSong: ["/Users/dotsocket/Library/Developer/CoreSimulator/Devices/A8242B0E-6F8D-4550-A809-950F01895462/data/Containers/Data/Application/CD23C778-DA09-46D8-A723-B91FC6A37DCD/Documents/121-521f6020-bfb0-11ec-bcc9-eb858530be26/vocals.mp3","/Users/dotsocket/Library/Developer/CoreSimulator/Devices/A8242B0E-6F8D-4550-A809-950F01895462/data/Containers/Data/Application/CD23C778-DA09-46D8-A723-B91FC6A37DCD/Documents/121-521f6020-bfb0-11ec-bcc9-eb858530be26/vocals.mp3","/Users/dotsocket/Library/Developer/CoreSimulator/Devices/A8242B0E-6F8D-4550-A809-950F01895462/data/Containers/Data/Application/CD23C778-DA09-46D8-A723-B91FC6A37DCD/Documents/121-521f6020-bfb0-11ec-bcc9-eb858530be26/vocals.mp3","/Users/dotsocket/Library/Developer/CoreSimulator/Devices/A8242B0E-6F8D-4550-A809-950F01895462/data/Containers/Data/Application/CD23C778-DA09-46D8-A723-B91FC6A37DCD/Documents/121-521f6020-bfb0-11ec-bcc9-eb858530be26/vocals.mp3","/Users/dotsocket/Library/Developer/CoreSimulator/Devices/A8242B0E-6F8D-4550-A809-950F01895462/data/Containers/Data/Application/CD23C778-DA09-46D8-A723-B91FC6A37DCD/Documents/121-521f6020-bfb0-11ec-bcc9-eb858530be26/vocals.mp3"],
        duration: 0,
        onSuccess_: () {
          // download song from server

          player.togglePlay();
        });


    player.playerStateChangedStream.listen((value) {
      print("playerStateChangedStream ${value}");
    });
    player.playerErrorMessage.listen((value) {
      print("playerErrorMessage ${value}");
    });

  }



  @override
  Widget build(BuildContext context) {
    init();
    return Center(
      child:  Text("ewfced"),
    );
  }
}
