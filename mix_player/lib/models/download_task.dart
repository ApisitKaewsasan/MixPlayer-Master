
enum DownloadState{
  none,
  start,
  pause,
  resume,
  cancel,
  finish,
  error,
  alreadyDownloaded
}

class DownLoadTask {
  late List<String> requestUrl;
  late List<Download> download;
  late double progress;
  late int requestLoop;
  late bool isFinish;

  DownLoadTask(
      {required this.requestUrl,
        required this.download,
        required this.progress,
        required this.requestLoop,
        required this.isFinish});

  DownLoadTask.fromJson(Map<String, dynamic> json) {
    if(json['requestUrl']!=null){
      requestUrl = List<String>.from(json['requestUrl'] as List);
    }
    if (json['download'] != null) {
      download = <Download>[];
      json['download'].forEach((dynamic v) {
        download.add(new Download.fromJson(v as Map<String, dynamic>));
      });
    }

    progress = json['progress'] as double;
    requestLoop = json['requestLoop'] as int;
    isFinish = json['isFinish'] as bool;
  }


}

class Download {
  String? url;
  String? localUrl;
  double? progress;
  DownloadState? downloadState;

  Download({this.url, this.localUrl, this.progress, this.downloadState});

  Download.fromJson(Map<String, dynamic> json) {
    url = json['url'] as String;
    localUrl = json['localUrl'] as String;
    progress = json['progress'] as double;
    downloadState = getPlayerState(json['downloadState'] as String);
  }

    getPlayerState(String event) {
     if (event == 'alreadyDownloaded') {
      return DownloadState.alreadyDownloaded;
    } else if (event == 'start') {
      return DownloadState.start;
    } else if (event == 'finish') {
      return DownloadState.finish;
    }else if (event == 'error') {
      return DownloadState.error;
    }else if (event == 'resume') {
      return DownloadState.resume;
    }else if (event == 'pause') {
      return DownloadState.pause;
    }else {
      return DownloadState.none;
    }
  }

}



