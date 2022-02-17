package com.example.mix_player.models
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class BetterEventChannel(name:String,message: FlutterPlugin.FlutterPluginBinding) :
    EventChannel.StreamHandler {
    var eventChannel: EventChannel = EventChannel(message.binaryMessenger, name)
    lateinit var eventSink:EventChannel.EventSink
    init {
        eventChannel.setStreamHandler(this)
    }

    fun sendEvent(arguments:Any?){
        eventSink.success(arguments)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events!!
        return
    }

    override fun onCancel(arguments: Any?) {
        eventSink.endOfStream()
        return
    }
}