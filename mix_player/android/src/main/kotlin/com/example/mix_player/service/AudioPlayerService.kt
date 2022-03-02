package com.example.mix_player.service

import android.content.Context
import android.media.MediaPlayer
import android.media.PlaybackParams
import android.os.Build
import androidx.annotation.RequiresApi
import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.AudioItem

@RequiresApi(Build.VERSION_CODES.M)
class AudioPlayerService(
    var reference: MixPlayerPlugin,
    var playerId: String,
    var context: Context
) {


    lateinit var audioItem: AudioItem
    lateinit var audioPlayer: MediaPlayer
    lateinit var thread: Thread
    val playbackParams = PlaybackParams()


    fun initData(audioItem: AudioItem) {
        this.audioItem = audioItem
        System.out.println("init ${playerId}")

         audioPlayer = MediaPlayer()
        audioPlayer.setDataSource(audioItem.url)
    }


    @RequiresApi(Build.VERSION_CODES.M)
    fun play(at: Double) {


        audioPlayer.prepare()
       audioPlayer.start()
        audioPlayer.seekTo(at.toInt())





    }


}