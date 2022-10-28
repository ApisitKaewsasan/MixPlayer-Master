


import Flutter
import UIKit
import MediaPlayer
import AudioStreaming
import SwiftTryCatch

let CHANNEL_NAME = "mix_audio_player.methods"
let EVENT_CHANNEL = "mix_audio_player"

public class SwiftMixPlayerPlugin: NSObject, FlutterPlugin {

    var _players = [String:AudioPlayerService]()
    var _registrar : FlutterPluginRegistrar
    var _channel: FlutterMethodChannel
    var _event: [String:BetterEventChannel] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
      let instance = SwiftMixPlayerPlugin(registrar: registrar, channel: channel)
      registrar.addMethodCallDelegate(instance, channel: channel)
      
  }
    
    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        _registrar = registrar
        _channel = channel
        super.init()
    }
    
    func setupEventPlayer(playerId:String){
        _event["\(EVENT_CHANNEL).playbackEventMessageStream.\(playerId)"] = BetterEventChannel(name: "\(EVENT_CHANNEL).playbackEventMessageStream.\(playerId)", message: _registrar.messenger())
        _event["\(EVENT_CHANNEL).playerStateChangedStream.\(playerId)"] = BetterEventChannel(name: "\(EVENT_CHANNEL).playerStateChangedStream.\(playerId)", message: _registrar.messenger())
    }
    
    func setupEventServer(){
        _event["\(EVENT_CHANNEL).procuessRenderToBuffer"] = BetterEventChannel(name: "\(EVENT_CHANNEL).procuessRenderToBuffer", message: _registrar.messenger())
        _event["\(EVENT_CHANNEL).downLoadTaskStream"] = BetterEventChannel(name: "\(EVENT_CHANNEL).downLoadTaskStream", message: _registrar.messenger())
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      

      guard let request = call.arguments as? [String:Any] else{
          result(FlutterError(code: "error", message: "ailed to parse call.arguments from Flutter.", details: nil))
         
           return
       }
       guard let playerId = request["playerId"] as? String else{
           result(FlutterError(code: "error", message: "Call missing mandatory parameter playerId", details: nil))
        
            return
        }
      
      var player = self.getOrCreatePlayer(playerId: playerId)
      
       if("init" == call.method){
           setupEventPlayer(playerId: playerId)
           DispatchQueue(label: "sync").sync {
               player.initData(audioItem: AudioItem(playerId: request["playerId"] as! String, title: request["title"] as! String, albumTitle: request["albumTitle"] as! String, artist: request["artist"] as! String, albumimageUrl: request["albumimageUrl"] as! String, skipInterval: request["skipInterval"] as! Double, url: request["url"] as! String, volume: request["volume"] as! Double,enable_equalizer: request["enable_equalizer"] as! Bool,frequecy: request["frequecy"] as! [Int],isLocalFile: request["isLocalFile"] as! Bool))
               
           }
           result(0)
      }else if("initService" == call.method){
          setupEventServer()
      }else if("play" == call.method){
          player.playOrPause()
      }else if("reloadPlay" == call.method){
          player.reloadPlay()
      }else if("setModeLoop" == call.method){
          player.setModeLoop(mode: request["mode"] as! Bool)
      }else if("pause" == call.method){
          player.playOrPause()
      }else if("stop" == call.method){
          player.stop()
      }else if("resume" == call.method){
          player.playOrPause()
      }else if("skipForward" == call.method){
          player.skipForward(time: request["time"] as! Float)
      }else if("skipBackward" == call.method){
          player.skipBackward(time: request["time"] as! Float)
      }else if("updateVolume" == call.method){
          player.updateVolume(volume: Float(request["volume"] as! Double))
      }else if("setPan" == call.method){
          player.setPan(pan: Float(request["pan"] as! Double))
      }else if("setPlaybackRate" == call.method){
          player.setPlaybackRate(playbackRate: Float(request["rate"] as! Double))
      }else if("seek" == call.method){
          player.seek(at: request["seek"] as! Double)
      }else if("toggleMute" == call.method){
          player.toggleMute()
         // result(player.player.muted)
         
      }else if("setPitch" == call.method){
          player.setPitch(pitch: Float(request["pitch"] as! Double))
      }else if("setEqualizer" == call.method){
          player.updateEQ(gain: Float(request["value"] as! Double), for:  request["index"] as! Int)
      }else if("equaliserReset" == call.method){
          player.resetEQ()
      }else if("disposePlayer" == call.method){
          disposePlayer()
      }else if("audioExport" == call.method){
        // clearCachesDirectory()
          var engine = AudioEngineExport(url: request["request"] as! [String],reverbConfig: Float(request["reverbConfig"] as! Double),speedConfig: Float(request["speedConfig"] as! Double),panConfig: Float(request["panConfig"] as! Double),pitchConfig: Float(request["pitchConfig"] as! Double), frequencyConfig: request["frequencyConfig"] as! [Int],gainConfig: request["gainConfig"] as! [Int],panPlayerConfig: request["panPlayerConfig"] as! [Float])
          engine.delegate = self
          guard let sourceUrl = engine.exportAudio(extensionFile: request["extension"] as! String) as? String else {
              return
          }
        //playera.play(url: URL(fileURLWithPath:sourceUrl))
        result(sourceUrl)
      }else if("wetDryMix" == call.method){
          player.wetDryMix(mix: Float(request["mix"] as! Double))
      }else{
          result(FlutterMethodNotImplemented);
      }
      
    //result("iOS " + UIDevice.current.systemVersion)
  }
    

    func getOrCreatePlayer(playerId: String) -> AudioPlayerService {
        if let player = _players[playerId] {
            return player
        }
        let newPlayer = AudioPlayerService(
            reference: self,
            playerId: playerId
        )
        _players[playerId] = newPlayer
        return newPlayer
    }
    
 

    
    func disposePlayer(){
        for (index, element) in _players {
            element.stop()
        }
        // _players.removeAll()
    }
    
    // Start EventChannel Stream
    
   
    func playbackEventMessageStream(playerId: String, currentTime: Double, duration:Double) {
       _event["\(EVENT_CHANNEL).playbackEventMessageStream.\(playerId)"]?.sendEvent(arguments: ["playerId": playerId, "currentTime": currentTime,"duration":duration])
    }
    
    func onError(playerId: String,message:String) {
        _channel.invokeMethod("onError", arguments: ["playerId": playerId, "message": message])
    }
    
    func onDownLoadTaskStream(download:DownloadStatus) {
       // _channel.invokeMethod("onDownLoadTaskStream", arguments: ["taskJson":download.convertObjectToJson()])
        _event["\(EVENT_CHANNEL).downLoadTaskStream"]?.sendEvent(arguments: download.convertObjectToJson())
    }
    
    func onPlayerStateChanged(playerId: String, state: AudioPlayerStates) {
       // _channel.invokeMethod("onPlayerStateChanged", arguments: ["playerState":"\(state)"])
        _event["\(EVENT_CHANNEL).playerStateChangedStream.\(playerId)"]?.sendEvent(arguments: "\(state)")
     
    }

    func onProcuessRenderToBuffer(procuess: Double) {
      //  _channel.invokeMethod("onProcuessRenderToBuffer", arguments: ["procuess": procuess])
      
        _event["\(EVENT_CHANNEL).procuessRenderToBuffer"]?.sendEvent(arguments: procuess)
        
    }
    
    // EventChannel Stream End
 
}

extension SwiftMixPlayerPlugin : AudioEngineExportDelegate{
    func procuessRenderToBuffer(procuess: Double){
        onProcuessRenderToBuffer(procuess: procuess)
    }
}
