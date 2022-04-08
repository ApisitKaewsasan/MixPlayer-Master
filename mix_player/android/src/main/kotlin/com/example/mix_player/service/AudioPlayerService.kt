package com.example.mix_player.service

import android.content.Context
import android.media.MediaPlayer
import android.media.PlaybackParams
import android.media.audiofx.Equalizer
import android.os.Build
import android.os.Handler
import androidx.annotation.RequiresApi
import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.AudioItem
import com.example.mix_player.models.AudioPlayerStates
import java.text.DecimalFormat
import java.util.concurrent.TimeUnit
import kotlin.math.abs


@RequiresApi(Build.VERSION_CODES.M)
class AudioPlayerService(
    var reference: MixPlayerPlugin,
    var playerId: String,
    var context: Context
) {


    lateinit var audioItem: AudioItem
    lateinit var audioPlayer: MediaPlayer
    var  leftVolume:Float = 1F
    var  rightVolume:Float = 1F

    var isMute = true
    var handler = Handler()
    var runnable: Runnable? = null
    private var mEqualizer: Equalizer? = null
      var statePlayer :AudioPlayerStates = AudioPlayerStates.ready

    fun initData(audioItem: AudioItem) {
        this.audioItem = audioItem


        setupPlayer()


    }

    private fun setupPlayer() {

        audioPlayer = MediaPlayer()
        audioPlayer.setDataSource(this.audioItem.url)

        audioPlayer.setOnCompletionListener {
            seek(0)
            playerStateChanged(AudioPlayerStates.ready)
        }

    }


    private fun changeSeekBar() {
        if(statePlayer == AudioPlayerStates.playing){
            runnable = Runnable {
                changeSeekBar()
                if(audioPlayer.currentPosition<=audioPlayer.duration){
                    reference.playbackEventMessageStream(playerId,audioPlayer.currentPosition.toLong(),audioPlayer.duration.toLong())
                }

            }
            handler.postDelayed(runnable!!, 1000)
        }

    }


    @RequiresApi(Build.VERSION_CODES.M)
    fun play(at: Double) {
//        val params: PlaybackParams = audioPlayer.playbackParams
//        params.speed = 2F
//        audioPlayer.playbackParams = params
        audioPlayer.prepare()
        playerStateChanged(AudioPlayerStates.playing)
        changeSeekBar()
        audioPlayer.start()
    }



    fun resume(at: Double){
        if(statePlayer ==  AudioPlayerStates.paused) {
            playerStateChanged(AudioPlayerStates.playing)
            changeSeekBar()
           audioPlayer.start()
        }

    }


    fun pause(){
        if(statePlayer ==  AudioPlayerStates.playing) {
            playerStateChanged(AudioPlayerStates.paused)
            audioPlayer.pause()


        }
    }

    fun stop(){
        if(statePlayer ==  AudioPlayerStates.playing) {
            audioPlayer.stop()
        }
    }

    fun skipBackward(time:Double){
        if(statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing) {
            // if(player.state != .error && player.state != .bufferring){
            val increase = (TimeUnit.SECONDS.convert(
                audioPlayer.currentPosition.toLong(),
                TimeUnit.MILLISECONDS
            )) - time.toInt()
            if (increase < 0) {
                seek(0)
            } else {
                seek(TimeUnit.MILLISECONDS.convert(increase, TimeUnit.SECONDS).toInt())
            }
            // }
        }

    }

    fun skipForward(time:Double){

        if(statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing){
            //if(player.state != .error && player.state != .bufferring){
            val increase = (TimeUnit.SECONDS.convert(audioPlayer.currentPosition.toLong(), TimeUnit.MILLISECONDS)) + time.toInt()
            // System.out.println("edfwvre ${TimeUnit.MILLISECONDS.convert(increase,TimeUnit.SECONDS)}")


            if(increase > audioPlayer.duration){
                //seek(audioPlayer.duration)
                System.out.println("เกินเวลา")
            }else if (increase < audioPlayer.duration){
                seek(TimeUnit.MILLISECONDS.convert(increase,TimeUnit.SECONDS).toInt())
            }
            //  }
        }


    }


    fun seek(time: Int) {
        audioPlayer.seekTo(time)
        reference.playbackEventMessageStream(playerId,audioPlayer.currentPosition.toLong(),audioPlayer.duration.toLong())
    }

    fun playerStateChanged(state: AudioPlayerStates){
        statePlayer = state
        reference.onPlayerStateChanged(playerId,state)
    }


    fun updateVolume(volume:Float){
        leftVolume = volume
        rightVolume = volume
       // audioPlayer.volume = volume
        if(isMute){
            audioPlayer.setVolume(leftVolume,rightVolume)
        }
    }

    fun setPan(pan:Float){
        if(pan == 0.0F){
            leftVolume = 1.0F
            rightVolume = 1.0F

        }else if(pan>0.1){
            rightVolume = abs(pan-1.0).toFloat()
            leftVolume =1.0F

        }else{
             rightVolume= 1.0F
            leftVolume = abs(pan+1.0).toFloat()

        }
        if(isMute){
            audioPlayer.setVolume(leftVolume,rightVolume)
        }

    }

    fun toggleMute(){
        if(isMute){
            isMute = false
            audioPlayer.setVolume(0F,0F)
        }else{
            isMute = true
            audioPlayer.setVolume(leftVolume,rightVolume)
        }

    }

    fun setPitch(pith:Float) {
        //    if (audioPlayer.playbackParams.pitch == pith) return
       // audioPlayer.playbackParams = PlaybackParams().setPitch(1.0f)
      //  val params: PlaybackParameters = audioPlayer.playbackParametersx
        var temp = audioPlayer.currentPosition
      //  val params: PlaybackParams = audioPlayer.playbackParams
//        params.speed = 2F
//        audioPlayer.playbackParams = params

        if(pith == 0.0F){

           // audioPlayer.playbackParameters = PlaybackParameters(params.speed, 1.0F)



            val params = PlaybackParams()
            params.pitch = 1.0F
            audioPlayer.playbackParams = params

        }else if(pith>=1.0){

          //  audioPlayer.playbackParameters = PlaybackParameters(params.speed, pith)
            val params = PlaybackParams()
            params.pitch = pith
            audioPlayer.playbackParams = params
        }else{
           var pitch = 1.2

            for (i in 0 until abs(pith).toInt()) {
                pitch -= 0.1
                if(i==abs(pith).toInt()-1){

                    val params = PlaybackParams()
                    params.pitch =DecimalFormat("0.00").format(pitch).toFloat()
                    audioPlayer.playbackParams = params

                }

            }


            // audioPlayer.playbackParams = PlaybackParams().setPitch(0.20F)
          //  audioPlayer.playbackParameters = PlaybackParameters(params.speed, abs(pith+1.0).toFloat())

        }

        if(statePlayer ==  AudioPlayerStates.paused || statePlayer ==  AudioPlayerStates.ready){
            audioPlayer.pause()
        }


        //val params: PlaybackParameters = player.getPlaybackParameters()
//        if (params.pitch === pitch) return
//        audioPlayer.setPlaybackParameters(PlaybackParameters(params.speed, pitch))

      //  audioPlayer.release()


    }


}




