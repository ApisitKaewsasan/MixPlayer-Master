


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
    // mixService.init().then((value){
    //   mixService.downLoadTask(request: audioItem.urlSong.map((e) => e.url).toList());
    //
    //   //  downloadDialog();
    //
    //   mixService.onDownLoadTask.listen((event) {
    //   //   print("onDownload1 => ${event.progress}");
    //     onDownLoadTaskSubject.add(event.progress);
    //   });
    //
    // });

    MixService.instance.downLoadTasks(url:  audioItem.urlSong.map((e) => e.url).toList());

  }





  @override
  Widget build(BuildContext context) {
    init();
    return Center(
      child:  StreamBuilder<DownLoadTask>(stream: MixService.instance.onDownLoadTask,builder:(context,snapshot){
          if(snapshot.hasData){
           // print('${snapshot.data!.requestLoop}/${snapshot.data!.requestUrl.length} procuess => ${snapshot.data!.progress*100}%');
            return Text("asdsc ${snapshot.data!.progress*100}%");
          }else{
            return Text("asdsc ${cdsfc}");
          }
      }),
    );
  }
}
