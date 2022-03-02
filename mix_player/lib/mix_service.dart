
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
import 'package:collection/collection.dart';

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


  downLoadTasks({required List<String> url}) async {
    var tempProcuess = List.generate(url.length, (index) => 0.0);
    List<Download> tempDownload = List.generate(url.length, (index) => Download(progress: 0.0,url: url[index]));
    var loopSuccess = 0;

    for (var i = 0; i < url.length; i++) {
      String savePath = await getFilePath(url[i].split("/").last);
      deleteFile(savePath);
      tempDownload[i].localUrl = savePath;

      Dio dio = Dio();
      dio.download(
        url[i],
        tempDownload[i].localUrl,
        onReceiveProgress: (rcv, total) {
          tempProcuess[i] = (rcv / total) * 100;
          tempDownload[i].progress = tempProcuess[i];
          tempDownload[i].downloadState = DownloadState.downloading;
          _onDownLoadTaskSubject.add(DownLoadTask(
            requestUrl: url,requestLoop: int.parse(((tempProcuess.sum/url.length)/(100/url.length)).ceilToDouble().toStringAsFixed(0)),progress: ((tempProcuess.sum/url.length)/100),isFinish: false,download: tempDownload
          ));
         // print(" ${((tempProcuess.sum/url.length)/(100/url.length)).ceilToDouble().toStringAsFixed(0)} / ${url.length} tempProcuess =>${((tempProcuess.sum/url.length)/100)}");

        },
        deleteOnError: true,
      ).then((_) {
        loopSuccess++;
        tempDownload[i].downloadState = DownloadState.finish;
        if(loopSuccess==url.length){
          _onDownLoadTaskSubject.add(DownLoadTask(
              requestUrl: url,requestLoop: int.parse(((tempProcuess.sum/url.length)/(100/url.length)).ceilToDouble().toStringAsFixed(0)),progress: ((tempProcuess.sum/url.length)/100),isFinish: true,download: tempDownload
          ));
        }

      },onError: (e){
        print("Error ${e}");
        tempDownload[i].downloadState = DownloadState.error;
        tempDownload[i].progress = 100;
        _onDownLoadTaskSubject.add(DownLoadTask(
            requestUrl: url,requestLoop: int.parse(((tempProcuess.sum/url.length)/(100/url.length)).ceilToDouble().toStringAsFixed(0)),progress: ((tempProcuess.sum/url.length)/100),isFinish: true,download: tempDownload
        ));
      });
    }
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