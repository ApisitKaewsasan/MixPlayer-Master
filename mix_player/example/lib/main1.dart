


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


  }



  @override
  Widget build(BuildContext context) {
    init();
    return Center(
      child:  Text("ewfced"),
    );
  }
}
