package com.example.mix_player.models

class Download(
    var url: String,
    var localUrl: String = "",
    var downloadState: DownloadState = DownloadState.none,
    var isDownloading: Boolean = false,
    var progress: Double = 0.0
)

class DownloadStatus(
    var requestUrl: List<String>,
    var download: List<Download>,
    var progress: Double = 0.0,
    var requestLoop:Int = 0,
    var isFinish : Boolean = false
)

enum class DownloadState {
     none,
     start,
     pause,
     resume,
     cancel,
     finish,
     error,
     alreadyDownloaded

}