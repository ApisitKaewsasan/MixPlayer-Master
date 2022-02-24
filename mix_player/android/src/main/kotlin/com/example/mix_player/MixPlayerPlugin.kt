package com.example.mix_player

import android.R.attr.identifier
import android.content.Context
import androidx.annotation.NonNull
import com.example.mix_player.models.*
import com.example.mix_player.service.AudioPlayerService
import com.example.mix_player.service.DownaloadServices
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** MixPlayerPlugin */
var CHANNEL_NAME = "mix_audio_player.methods"
var EVENT_CHANNEL = "mix_audio_player"
class MixPlayerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  var players = HashMap<String, AudioPlayerService>()
  var event = HashMap<String, BetterEventChannel>()
  lateinit var registrar : FlutterPlugin.FlutterPluginBinding
    private var context: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    registrar = flutterPluginBinding
      context = flutterPluginBinding.applicationContext

  }

 private fun setupEventPlayer(playerId:String){

    event["${EVENT_CHANNEL}.playbackEventMessageStream.${playerId}"] = BetterEventChannel("${EVENT_CHANNEL}.playbackEventMessageStream.${playerId}",registrar)
    event["${EVENT_CHANNEL}.playerStateChangedStream.${playerId}"] = BetterEventChannel("${EVENT_CHANNEL}.playerStateChangedStream.${playerId}",registrar)
  }

    private fun setupEventServer(){
        event["${EVENT_CHANNEL}.procuessRenderToBuffer"] = BetterEventChannel("${EVENT_CHANNEL}.procuessRenderToBuffer",registrar)
        event["${EVENT_CHANNEL}.downLoadTaskStream"] = BetterEventChannel("${EVENT_CHANNEL}.downLoadTaskStream",registrar)

    }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    var request = if (call.arguments!=null) call.arguments<HashMap<String, Any>>() else {
      result.error("error","ailed to parse call.arguments from Flutter.",null)
      return
    }

    var playerId = if (request["playerId"]!=null) request["playerId"] as String else {
      result.error("error","Call missing mandatory parameter playerId.",null)
      return
    }

    var player = this.getOrCreatePlayer(playerId)

    //AudioItem(playerId: request["playerId"] as! String, title: request["title"] as! String, albumTitle: request["albumTitle"] as! String, artist: request["artist"] as! String, albumimageUrl: request["albumimageUrl"] as! String, skipInterval: request["skipInterval"] as! Double, url: request["url"] as! String, volume: request["volume"] as! Double,enable_equalizer: request["enable_equalizer"] as! Bool,frequecy: request["frequecy"] as! [Int],isLocalFile: request["isLocalFile"] as! Bool)
    if (call.method == "init") {
        setupEventPlayer(playerId)
      player.initData(AudioItem(
        playerId,request["title"] as String,request["albumTitle"] as String,request["artist"] as String,
        request["albumimageUrl"] as String,request["skipInterval"] as Double,request["url"] as String,
        request["volume"] as Double,request["enable_equalizer"] as Boolean,request["frequecy"] as List<Int>,
        request["isLocalFile"] as Boolean
      ))
      result.success(0)
    }else if(call.method == "initService"){
        setupEventServer()
        result.success(0)
    }else if(call.method == "setPan"){

    }else if(call.method == "downloadTask"){
        DownaloadServices(this,request["request"] as List<String>,context!!)

    }else if(call.method == "setModeLoop"){

    }else if(call.method == "updateVolume"){

    } else if(call.method == "setPlaybackRate"){

    } else {
      result.notImplemented()
    }
  }




  fun getOrCreatePlayer(playerId: String):AudioPlayerService{
     if (players[playerId]!=null){
       return players[playerId]!!
     }
      val newPlayer = AudioPlayerService(this,playerId)
       players[playerId] = newPlayer
      return newPlayer
  }

  fun onDownLoadTaskStream(download: DownloadStatus) {
    // _channel.invokeMethod("onDownLoadTaskStream", arguments: ["taskJson":download.convertObjectToJson()])
      var item = DownloadStatus(download.requestUrl,download.download,download.progress,download.requestLoop,download.isFinish)
      val gson = Gson()


      event["${EVENT_CHANNEL}.downLoadTaskStream"]?.sendEvent(gson.toJson(download))


    //  channel.invokeMethod("onDownLoadTaskStream",gson.toJson(download))
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
