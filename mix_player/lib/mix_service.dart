
import 'dart:convert';
import 'dart:io';

import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'models/download_task.dart';
import 'models/extension.dart';

class MixService{

  static MixService instance = MixService();

  late MixAudioPlayerPlatform _platform;

  static const _uuid = Uuid();

  final _onDownLoadTaskSubject =  BehaviorSubject<DownLoadTask>();

  final _onProcuessRenderToBufferSubject = BehaviorSubject<double>();




  Future init()async{
    _platform =  await MixAudioPlatform.instance.initService(_uuid.toString());
    _subscribeToEvents(_platform);
  }

  static  Map<dynamic, dynamic> invokeMethod( [
    Map<dynamic, dynamic> arguments = const <dynamic, dynamic>{},
  ]) {
    final enhancedArgs = <dynamic, dynamic>{
      ...arguments,
      'playerId': "0",
    };
    return enhancedArgs;
  }


  downLoadTasks({required String url}) async {
    String savePath = await getFilePath(url.split("/").last);
    deleteFile(savePath);
    Dio dio = Dio();

    dio.download(
      url,
      savePath,
      onReceiveProgress: (rcv, total) {
        print(
            '${((rcv / total) * 100)}% received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

      },
      deleteOnError: true,
    ).then((_) {
      print("savePath => ${savePath}");
    });
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uniqueFileName';
    return path;
  }



  Future<File>  _localFile(String pathfilename) async => File(pathfilename);

  Future<int?> deleteFile(String filename) async {
    try {
      final file = await _localFile(filename);

      await file.delete();
    } catch (e) {
      return 0;
    }
  }



  downLoadTask({required List<String> request}){

    _platform.downloadTask(request);
  }

  cancelDownloadTask({required List<String> request}){
  _platform.cancelDownloadTask(request);
  }


  audioExport({required List<String> request,required FileExtension extension,required double reverbConfig,required double speedConfig,required double panConfig,required double pitchConfig,
    required List<double> frequencyConfig,required List<double> gainConfig,required List<double> panPlayerConfig})=>
      _platform.audioExport(request,EnumToString.convertToString(extension).toLowerCase(),reverbConfig,speedConfig,panConfig,pitchConfig,frequencyConfig,gainConfig,panPlayerConfig);

  _subscribeToEvents(MixAudioPlayerPlatform platform) {

    _platform.onDownLoadTaskStream.listen((event) {
      _onDownLoadTaskSubject.add(DownLoadTask.fromJson(jsonDecode(event) as Map<String, dynamic>));
    });

    _platform.onProcuessRenderToBufferStream.listen((event) {
      _onProcuessRenderToBufferSubject.add(event);
    });
  }

  //  close service
  disposeService() {
      _onDownLoadTaskSubject.close();
      _onProcuessRenderToBufferSubject.close();
  }


  /// A stream of [PlaybackEvent]s.
  Stream<DownLoadTask> get onDownLoadTask =>  _onDownLoadTaskSubject.stream;

  Stream<double> get onProcuessRenderToBuffer => _onProcuessRenderToBufferSubject.stream;


}