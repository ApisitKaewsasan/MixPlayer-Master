package com.example.mix_player.service

import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.AudioItem

class AudioPlayerService(var reference: MixPlayerPlugin, var playerId: String) {


     lateinit var  audioItem: AudioItem

    fun initData(audioItem: AudioItem){
        this.audioItem = audioItem

    }
}