import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'models/download_task.dart';
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
        String pathCache = '',
        required Function(String) onError}) async {
    // FileManager.createFolder(extensionFile: mixItem.extension)
    //     .then((filemanager) async {
    Directory directory = await getApplicationDocumentsDirectory();



    var fileName =
        "${pathCache.isNotEmpty ? pathCache : directory.path}/${mixItem.fileName}.${mixItem.extension.toLowerCase()}";
    if (File(mixItem.request.first).existsSync()) {
      File(fileName).delete();
      if (mixItem.request.length > 0 &&
          p.extension(mixItem.request.first).split(".")[1] ==
              mixItem.extension.toLowerCase()) {
        onError.call(
            "Default encoder for format ${p.extension(mixItem.request.first.split(".")[1])} (codec ${p.extension(mixItem.request.first.split(".")[1])}) is probably disabled. Please choose an encoder manually.");
      } else if (duration <= 0) {
        onError.call("Incorrect processing calculation time..");
      } else {
        onBuild.call();
        _onProcuessRenderToBufferSubject.add(1.0);
        List<String> pathArray =
        "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".split(",");
        String mixPath = "";
        String mixValue = '"';
        String mixPathEnd = "";
        String pitch = "aresample=44100";
        String speed = "atempo=1.0";
        int index = 0;
        mixItem.request.forEach((element) {
          String pan = "pan=stereo|c0=c0|c1=c1";
          if (mixItem.panPlayerConfig[index] > 0) {
            pan =
            "pan=stereo|c0=${(1.0 - (mixItem.panPlayerConfig[index] /20))}*c0|c1=${mixItem.panPlayerConfig[index] / 100}*c1";
          } else if (mixItem.panPlayerConfig[index] < 0) {
            pan =
            "pan=stereo|c0=${(mixItem.panPlayerConfig[index]).abs() /20}*c0|c1=${(1.0 - (mixItem.panPlayerConfig[index]).abs() / 100)}*c1";
          }
          // if (mixItem.pitchConfig > 0) {
          //   print("efwer ${mixItem.pitchConfig}");

          // } else if (mixItem.pitchConfig < 0) {
          //   print("efwer ${mixItem.pitchConfig}");
          //   pitch =
          //   "asetrate=${44100 *
          //       mixItem.pitchConfig.abs()},aresample=44100,atempo=2.0";
          // }

          var pitchConfig = getPitch(value: mixItem.pitchConfig);
          if (mixItem.pitchConfig == 0) {
            speed = "atempo=${mixItem.speedConfig}";
            pitch = "asetrate=${pitchConfig['asetrate']},aresample=48000";
          } else if (mixItem.pitchConfig != 0 && mixItem.speedConfig == 1) {
            pitch =
            "asetrate=${pitchConfig['asetrate']},aresample=44100,atempo=${pitchConfig['atempo']}";
          } else if (mixItem.pitchConfig != 0 && mixItem.speedConfig != 1) {
            if(mixItem.speedConfig<0){
              pitch =
              "asetrate=${pitchConfig['asetrate']},aresample=48000,atempo=${mixItem.speedConfig}";
            }else{
              pitch =
              "asetrate=${pitchConfig['asetrate']},aresample=44100,atempo=${mixItem.speedConfig}";
            }
          }
          mixPath += " -i ${element}";
          mixValue +=
          "[${index}]volume=${mixItem.volumeConfig[index]/50},${pan},${pitch},${speed}[${pathArray[index]}];";
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
          _onProcuessRenderToBufferSubject.add((statistics.getTime() /
              Duration(seconds: duration.toInt()).inMilliseconds) *
              100);
        });
      }
    } else {
      onError.call("request Cannot open file, path ");
    }
    // });
  }

  sessionRenderCancel() => FFmpegKit.cancel();

  Map getPitch({double value = 0.0}) {
    var defaults = {
      "asetrate": 44100 * 1.0,
      "atempo": 1.0,
    };
    if (value == 0.0) {
      return defaults;
    } else if (value >= 6 && value < 7) {
      return {
        "asetrate": 44100 * 1.6,
        "atempo": 0.625,
      };
    } else if (value >= 5 && value < 6) {
      return {
        "asetrate": 44100 * 1.5,
        "atempo": 0.67,
      };
    } else if (value >= 4 && value < 5) {
      return {
        "asetrate": 44100 * 1.4,
        "atempo": 0.72,
      };
    } else if (value >= 3 && value < 4) {
      return {
        "asetrate": 44100 * 1.3,
        "atempo": 0.77,
      };
    } else if (value >= 2 && value < 3) {
      return {
        "asetrate": 44100 * 1.2,
        "atempo": 0.83,
      };
    } else if (value >= 1 && value < 2) {
      return {
        "asetrate": 44100 * 1.1,
        "atempo": 0.91,
      };
    } else if (value >= -1 && value < 0) {
      return {
        "asetrate": 44100 * 0.9,
        "atempo": 1.1,
      };
    } else if (value >= -2 && value < -1) {
      return {
        "asetrate": 44100 * 0.95,
        "atempo": 1.1,
      };
    } else if (value >= -3 && value < -2) {
      return {
        "asetrate": 44100 * 0.8,
        "atempo": 1.25,
      };
    } else if (value >= -4 && value < -3) {
      return {
        "asetrate": 44100 * 0.85,
        "atempo": 1.18,
      };
    } else if (value >= -5 && value < -4) {
      return {
        "asetrate": 44100 * 0.7,
        "atempo": 1.43,
      };
    } else if (value >= -6 && value < -5) {
      return {
        "asetrate": 44100 * 0.75,
        "atempo": 1.66,
      };
    }
    return defaults;
  }

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

  cancelDownloadTask({required List<String> request}) {}

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

