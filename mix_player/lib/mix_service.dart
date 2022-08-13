import 'dart:convert';
import 'dart:io';

import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'models/download_task.dart';
import 'models/extension.dart';
import 'package:collection/collection.dart';

import 'models/mix_item.dart';
import 'utility/file_manager.dart';

class MixService {
  static MixService instance = MixService();


  final _onDownLoadTaskSubject = BehaviorSubject<DownLoadTask>();

  final _onProcuessRenderToBufferSubject = BehaviorSubject<double>();


  mixAudioFile(
      {required MixItem mixItem,
        required double duration,
      required Function(String) onSuccess,
        required Function() onBuild,
         String pathCache='',
      required Function(String) onError}) async {
    // FileManager.createFolder(extensionFile: mixItem.extension)
    //     .then((filemanager) async {
    Directory directory = await getApplicationDocumentsDirectory();

      var fileName = "${pathCache.isNotEmpty?pathCache:directory.path}/${mixItem.fileName}.${mixItem.extension.toLowerCase()}";
      if (File(mixItem.request.first).existsSync()) {

        if (mixItem.request.length>0 && p.extension(mixItem.request.first).split(".")[1] ==
            mixItem.extension.toLowerCase()) {
          onError.call(
              "Default encoder for format ${p.extension(mixItem.request.first.split(".")[1])} (codec ${p.extension(mixItem.request.first.split(".")[1])}) is probably disabled. Please choose an encoder manually.");
        }else if(duration<=0){
          onError.call(
              "Incorrect processing calculation time..");
        } else {

          onBuild.call();
          _onProcuessRenderToBufferSubject.add(1.0);
          List<String> pathArray =
              "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".split(",");
          String mixPath = "";
          String mixValue = '"';
          String mixPathEnd = "";
          String atempo = "aresample=44100";
          int index = 0;
          mixItem.request.forEach((element) {
            String pan = "pan=stereo|c0=c0|c1=c1";
            if (mixItem.panPlayerConfig[index] > 0) {
              pan = "pan=stereo|c0=${(1.0 - (mixItem.panPlayerConfig[index] / 100))}*c0|c1=${mixItem.panPlayerConfig[index] / 100}*c1";
            } else if (mixItem.panPlayerConfig[index] < 0) {
              pan = "pan=stereo|c0=${(mixItem.panPlayerConfig[index]).abs() / 100}*c0|c1=${(1.0 - (mixItem.panPlayerConfig[index]).abs() / 100)}*c1";
            }
            if (mixItem.pitchConfig > 0) {
              atempo = "asetrate=88200,aresample=44100,atempo=${((0.1 * mixItem.pitchConfig) + 0.5)}";
            } else if (mixItem.pitchConfig < 0) {
              atempo = "asetrate=22050,aresample=44100,atempo=${((mixItem.pitchConfig.abs()) * 0.1) + 1.5}";
            }
            mixPath += " -i ${element}";
            mixValue += "[${index}]volume=${((mixItem.volumeConfig[index] / 100) * 4)},${pan},${atempo}[${pathArray[index]}];";
            mixPathEnd += "[${pathArray[index]}]";
            index++;
          });

          FFmpegKit.executeAsync(
              '${mixPath} -filter_complex ${mixValue}${mixPathEnd}amix=inputs=${mixItem.request.length}:duration=longest" ${fileName}',
                  (session) async {

                final returnCode = await session.getReturnCode();

                if (ReturnCode.isSuccess(returnCode)) {
                  _onProcuessRenderToBufferSubject.add(100.0);
                  // SUCCESS
                  print("FFmpegKit -> SUCCESS  outfile -> ${fileName}");
                  onSuccess.call(fileName);
                } else if (ReturnCode.isCancel(returnCode)) {
                  _onProcuessRenderToBufferSubject.add(100.0);
                  // CANCEL
                  // onError.call(
                  //     "transaction failed There might be a file merging error. Please contact the developer.");
                  print("FFmpegKit -> CANCEL ");
                } else {
                  _onProcuessRenderToBufferSubject.add(100.0);
                  // ERROR
                  onError.call(
                      "transaction failed There might be a file merging error. Please contact the developer.");
                  print("FFmpegKit ->CANCEL ");
                }
              }, (log) {
            print("FFmpegKit Log -> ${log.getMessage()}");
          }, (statistics) {
                  _onProcuessRenderToBufferSubject.add((statistics.getTime()/Duration(seconds: duration.toInt()).inMilliseconds)*100);
          });
        }
     }
      else{
        onError.call("request Cannot open file, path ");
      }
   // });
  }

  sessionRenderCancel()=>FFmpegKit.cancel();




  downLoadTasks({required List<String> url}) async {
    var tempProcuess = List.generate(url.length, (index) => 0.0);
    List<Download> tempDownload = List.generate(
        url.length, (index) => Download(progress: 0.0, url: url[index]));
    var loopSuccess = 0;

    _onDownLoadTaskSubject.add(DownLoadTask(
        requestUrl: url,
        requestLoop: int.parse(
            ((tempProcuess.sum / url.length) / (100 / url.length))
                .ceilToDouble()
                .toStringAsFixed(0)),
        progress: ((tempProcuess.sum / url.length) / 100),
        isFinish: false,
        download: tempDownload));

    for (var i = 0; i < url.length; i++) {
      String savePath = await getFilePath(url[i].split("/").last);
      FileManager.deleteFile(savePath);
      tempDownload[i].localUrl = savePath;
      tempDownload[i].downloadState = DownloadState.downloading;
      Dio dio = Dio();
      dio.download(
        url[i],
        tempDownload[i].localUrl,
        onReceiveProgress: (rcv, total) {
          tempProcuess[i] = (rcv / total) * 100;
          tempDownload[i].progress = tempProcuess[i];
          _onDownLoadTaskSubject.add(DownLoadTask(
              requestUrl: url,
              requestLoop: int.parse(
                  ((tempProcuess.sum / url.length) / (100 / url.length))
                      .ceilToDouble()
                      .toStringAsFixed(0)),
              progress: ((tempProcuess.sum / url.length) / 100),
              isFinish: false,
              download: tempDownload));
          // print(" ${((tempProcuess.sum/url.length)/(100/url.length)).ceilToDouble().toStringAsFixed(0)} / ${url.length} tempProcuess =>${((tempProcuess.sum/url.length)/100)}");
        },
        deleteOnError: true,
      ).then((_) {
        loopSuccess++;
        tempDownload[i].downloadState = DownloadState.finish;
        if (loopSuccess == url.length) {
          _onDownLoadTaskSubject.add(DownLoadTask(
              requestUrl: url,
              requestLoop: int.parse(
                  ((tempProcuess.sum / url.length) / (100 / url.length))
                      .ceilToDouble()
                      .toStringAsFixed(0)),
              progress: ((tempProcuess.sum / url.length) / 100),
              isFinish: true,
              download: tempDownload));
        }
      }, onError: (e) {
        loopSuccess++;
        print("Error ${e}");
        tempDownload[i].downloadState = DownloadState.error;
        tempDownload[i].progress = 100;
        if (loopSuccess == url.length) {
          _onDownLoadTaskSubject.add(DownLoadTask(
              requestUrl: url,
              requestLoop: int.parse(
                  ((tempProcuess.sum / url.length) / (100 / url.length))
                      .ceilToDouble()
                      .toStringAsFixed(0)),
              progress: ((tempProcuess.sum / url.length) / 100),
              isFinish: true,
              download: tempDownload));
        }
      });
    }
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uniqueFileName';
    return path;
  }


  cancelDownloadTask({required List<String> request}) {

  }


  //  close service
  disposeService() {
    _onDownLoadTaskSubject.close();
    _onProcuessRenderToBufferSubject.close();
  }

  /// A stream of [PlaybackEvent]s.
  Stream<DownLoadTask> get onDownLoadTask => _onDownLoadTaskSubject.stream;

  Stream<double> get onProcuessRenderToBuffer =>
      _onProcuessRenderToBufferSubject.stream;
}
