//
//  BetterEventChannel.swift
//  AudioStreaming
//
//  Created by Dotsocket on 2/7/22.
//

import Foundation
import Flutter

class BetterEventChannel: NSObject,FlutterStreamHandler{
   
    
    var _eventChannel : FlutterEventChannel?
    var _eventSink : FlutterEventSink?
    
    init(name:String,message:FlutterBinaryMessenger){
        super.init()
        self._eventChannel = FlutterEventChannel(name: name, binaryMessenger: message)
        self._eventChannel?.setStreamHandler(self)
        self._eventSink = nil
       
    
    }
    
  
    func sendEvent(arguments:Any?){
        if(_eventSink != nil){
            _eventSink!(arguments)
        }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
   
}
