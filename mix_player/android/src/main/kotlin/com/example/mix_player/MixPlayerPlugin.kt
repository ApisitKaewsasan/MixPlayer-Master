package com.example.mix_player

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.example.mix_player.models.*
import com.example.mix_player.service.AudioPlayerService
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.TimeUnit


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
        event["${EVENT_CHANNEL}.downLoadTaskStream"] = BetterEventChannel("${EVENT_CHANNEL}.downLoadTaskStream",registrar)

    }

  @RequiresApi(Build.VERSION_CODES.M)
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
      //  System.out.println("43r43r4354r");

      result.success(0)
    }else if(call.method == "initService"){
        setupEventServer()
        result.success(0)
    }else if(call.method == "play"){
        player.play(request["time"] as Double)

    }else if("pause" == call.method){
        player.pause()
    }else if("stop" == call.method){
        player.stop()
    }else if("resume" == call.method){
        player.resume(request["time"] as Double)
    }else if("skipForward" == call.method){
        player.skipForward(request["time"] as Double)
    }else if("skipBackward" == call.method){
        player.skipBackward(request["time"] as Double)
    }else if("seek" == call.method){
        player.seek(TimeUnit.MILLISECONDS.convert((request["seek"] as Double).toLong(), TimeUnit.SECONDS).toInt())
    }else if(call.method == "setPan"){
        player.setPan((request["pan"] as Double).toFloat()/100)
    }else if("updateVolume" == call.method){
        player.updateVolume((request["volume"] as Double).toFloat()/100)
    }else if("toggleMute" == call.method){
        player.toggleMute()
        // result(player.player.muted)

    }else if("setPitch" == call.method){
        player.setPitch((request["pitch"] as Double).toFloat())
    }else if("setEqualizer" == call.method){
        player.equaliserService.notifyUpdateBandLevel((request["index"] as Int).toShort(),(request["value"] as Double).toInt())
    }else if("equaliserReset" == call.method){
        player.equaliserService.reset()
    }else if(call.method == "downloadTask"){
       // DownaloadServices(this,request["request"] as List<String>,context!!)

    }else if(call.method == "setModeLoop"){

    }else if(call.method == "setPlaybackRate"){
        player.setPlaybackRate(request["rate"] as Double)
    }else {
      result.notImplemented()
    }
  }


  @RequiresApi(Build.VERSION_CODES.M)
  fun getOrCreatePlayer(playerId: String):AudioPlayerService{
     if (players[playerId]!=null){
       return players[playerId]!!
     }
      val newPlayer = AudioPlayerService(this,playerId,this.context!!)
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


    fun onPlayerStateChanged(playerId: String, state: AudioPlayerStates) {
        // _channel.invokeMethod("onPlayerStateChanged", arguments: ["playerState":"\(state)"])
        event["${EVENT_CHANNEL}.playerStateChangedStream.${playerId}"]?.sendEvent(state.toString())

    }

    fun playbackEventMessageStream(playerId: String, currentTime: Long, duration:Long){

        val currentTimeConvert: Long =
            (TimeUnit.SECONDS.convert(currentTime, TimeUnit.MILLISECONDS))
        val durationConvert: Long =
            (TimeUnit.SECONDS.convert(duration, TimeUnit.MILLISECONDS))
        //System.out.println("tick  ${playerId} ${durationConvert}  ${currentTimeConvert}")

        event["${EVENT_CHANNEL}.playbackEventMessageStream.${playerId}"]?.sendEvent( mapOf("playerId" to playerId, "currentTime" to currentTimeConvert.toDouble() , "duration" to durationConvert.toDouble()))
    }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
