
import 'dart:convert';

import 'package:audio_player_platform_interface/audio_player_platform_interface.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:rxdart/rxdart.dart';

import 'models/download_task.dart';
import 'models/extension.dart';

class MixService{

  static MixService instance = MixService();

  late MixAudioPlayerPlatform _platform;

  final _onDownLoadTaskSubject =  BehaviorSubject<DownLoadTask>();

  final _onProcuessRenderToBufferSubject = BehaviorSubject<double>();


  MixService(){
    _platform = MixAudioPlatform.instance.service();
    _subscribeToEvents(_platform);
  }

  downLoadTask({required List<String> request}){

    _platform.downloadTask(request);
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