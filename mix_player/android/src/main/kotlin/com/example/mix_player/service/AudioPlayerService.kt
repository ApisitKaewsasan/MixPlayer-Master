package com.example.mix_player.service

import android.content.Context
import android.media.MediaPlayer
import android.media.PlaybackParams
import android.media.VolumeShaper
import android.media.audiofx.Equalizer
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.AudioItem
import com.example.mix_player.models.AudioPlayerStates
import com.example.mix_player.viewmodel.EqualizerViewModel
import java.io.IOException
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
    var audioPlayer: MediaPlayer? = null
    var leftVolume: Float = 1F
    var rightVolume: Float = 1F

    var isMute = true
    var handler = Handler()
    var runnable: Runnable? = null
    private var mEqualizer: Equalizer? = null
    var statePlayer: AudioPlayerStates = AudioPlayerStates.ready
    lateinit var equaliserService: EqualizerViewModel

    fun initData(audioItem: AudioItem) {
        this.audioItem = audioItem

        setupPlayer()
          equaliserService = EqualizerViewModel(Equalizer(0,audioPlayer!!.audioSessionId))
        //  setupEqualizer()
    }

    private fun setupPlayer() {
        audioPlayer = MediaPlayer()
        try {


            audioPlayer!!.setDataSource(this.audioItem.url)
            audioPlayer!!.prepare()
            audioPlayer!!.setOnPreparedListener {
                //


                updateVolume(audioItem.volume.toFloat())
                setPan(audioItem.pan.toFloat() / 100)
//                setPitch(audioItem.pitch.toFloat())
               // audioPlayer!!.pause()

            }

            audioPlayer!!.setOnCompletionListener {
                seek(0)
                playerStateChanged(AudioPlayerStates.ready)
          }
        } catch (e: IOException) {
            e.printStackTrace()
            System.out.println("error xxx ${e.message}")
        }

    }


    fun setupEqualizer() {
        mEqualizer = Equalizer(0, audioPlayer!!.audioSessionId)
        val numberOfBands = mEqualizer!!.numberOfBands
        var minEQLevel = mEqualizer!!.bandLevelRange[0]
        var maxEQLevel = mEqualizer!!.bandLevelRange[1]
        // mEqualizer!!.setBandLevel(bands, (5+minEQLevel).toShort())

        for (i in 0 until numberOfBands) {
            System.out.println("centerFreq -> ${mEqualizer!!.getCenterFreq(i.toShort()) / 1000}")
        }

    }

    private fun changeSeekBar() {
        if (audioPlayer != null) {
            if (statePlayer == AudioPlayerStates.playing) {
                runnable = Runnable {
                    changeSeekBar()
                    if (audioPlayer != null && audioPlayer!!.currentPosition <= audioPlayer!!.duration) {
                        reference.playbackEventMessageStream(
                            playerId,
                            audioPlayer!!.currentPosition.toLong(),
                            audioPlayer!!.duration.toLong()
                        )
                    }
                }
                handler.postDelayed(runnable!!, 1000)
            }
        }

    }


    @RequiresApi(Build.VERSION_CODES.M)
    fun play(at: Double) {
        playerStateChanged(AudioPlayerStates.playing)
        changeSeekBar()
       // audioPlayer!!.start()
        audioPlayer!!.playbackParams = PlaybackParams().setSpeed(audioItem.speed.toFloat())
        setPitch(audioItem.pitch.toFloat())
        audioPlayer!!.seekTo(0)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            fadeInOrOutAudio(audioPlayer!!, 1000, false)
        }
    }

    fun resume(at: Double) {
        if (statePlayer == AudioPlayerStates.paused) {
            playerStateChanged(AudioPlayerStates.playing)
            changeSeekBar()
            audioPlayer!!.start()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                fadeInOrOutAudio(audioPlayer!!, 1000, false)
            }
        }
    }


    fun pause() {
        if (statePlayer == AudioPlayerStates.playing) {
            playerStateChanged(AudioPlayerStates.paused)
            audioPlayer!!.pause()
        }
    }


    @RequiresApi(Build.VERSION_CODES.O)
    fun fadeOutConfig(duration: Long): VolumeShaper.Configuration {
        val times = floatArrayOf(0f, 1f)
        val volumes = floatArrayOf(1f, 0f)
        return VolumeShaper.Configuration.Builder()
            .setDuration(duration)
            .setCurve(times, volumes)
            .setInterpolatorType(VolumeShaper.Configuration.INTERPOLATOR_TYPE_CUBIC)
            .build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun fadeInConfig(duration: Long): VolumeShaper.Configuration {
        val times = floatArrayOf(
            0f,
            1f
        )
        val volumes = floatArrayOf(0f, 1f)
        return VolumeShaper.Configuration.Builder()
            .setDuration(duration)
            .setCurve(times, volumes)
            .setInterpolatorType(VolumeShaper.Configuration.INTERPOLATOR_TYPE_CUBIC)
            .build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun fadeInOrOutAudio(mediaPlayer: MediaPlayer, duration: Long, out: Boolean) {
        val config = if (out) fadeOutConfig(duration) else fadeInConfig(duration)
        val volumeShaper = mediaPlayer.createVolumeShaper(config)
        volumeShaper.apply(VolumeShaper.Operation.PLAY)
    }


    fun stop() {
        if (statePlayer == AudioPlayerStates.playing) {
            audioPlayer!!.stop()
            runnable?.let { handler.removeCallbacks(it) };
        }
    }

    fun setPlaybackRate(rate: Double) {
        System.out.println("setPlaybackRate xxx 1 ${rate}")
        if (statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing) {
            System.out.println("setPlaybackRate xxx 2 ${rate}")
            audioPlayer!!.playbackParams = PlaybackParams().setSpeed(rate.toFloat())
        }
    }

    fun skipBackward(time: Double) {
        if (statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing) {
            // if(player.state != .error && player.state != .bufferring){
            val increase = (TimeUnit.SECONDS.convert(
                audioPlayer!!.currentPosition.toLong(),
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

    fun skipForward(time: Double) {
        if (statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing) {
            val increase = (TimeUnit.SECONDS.convert(
                audioPlayer!!.currentPosition.toLong(),
                TimeUnit.MILLISECONDS
            )) + time.toInt()
            if (increase > audioPlayer!!.duration) {
            } else if (increase < audioPlayer!!.duration) {
                seek(TimeUnit.MILLISECONDS.convert(increase, TimeUnit.SECONDS).toInt())
            }
        }
    }

    fun seek(time: Int) {
        audioPlayer!!.seekTo(time)
        reference.playbackEventMessageStream(
            playerId,
            audioPlayer!!.currentPosition.toLong(),
            audioPlayer!!.duration.toLong()
        )
    }

    fun playerStateChanged(state: AudioPlayerStates) {
        statePlayer = state
        reference.onPlayerStateChanged(playerId, state)
    }

    fun onDestroy() {
        System.out.println("onDestroy ${playerId}")
        // playerStateChanged(AudioPlayerStates.stopped)
        if (statePlayer == AudioPlayerStates.playing) {
            audioPlayer!!.stop()
            audioPlayer!!.release()
        }

        audioPlayer = null
        runnable?.let { handler.removeCallbacks(it) }


    }


    fun updateVolume(volume: Float) {
        leftVolume = volume
        rightVolume = volume
        if (isMute) {
            audioPlayer!!.setVolume(leftVolume, rightVolume)
        }
    }

    fun setPan(pan: Float) {
        if (pan == 0.0F) {
            leftVolume = 1.0F
            rightVolume = 1.0F

        } else if (pan > 0.1) {
            rightVolume = abs(pan - 1.0).toFloat()
            leftVolume = 1.0F
        } else {
            rightVolume = 1.0F
            leftVolume = abs(pan + 1.0).toFloat()
        }
        if (isMute) {
            audioPlayer!!.setVolume(leftVolume, rightVolume)
        }

    }

    fun toggleMute() {
        if (isMute) {
            isMute = false
            audioPlayer!!.setVolume(0F, 0F)
        } else {
            isMute = true
            audioPlayer!!.setVolume(leftVolume, rightVolume)
        }

    }

    fun setPitch(pith: Float) {
        if (pith == 0.0F) {
            val params = PlaybackParams()
            params.pitch = 1.0F
            audioPlayer!!.playbackParams = params
        } else if (pith >= 0.1) {
            val params = PlaybackParams()
            params.pitch = (pith+1)
            audioPlayer!!.playbackParams = params
        } else {
            val params = PlaybackParams()
            params.pitch = DecimalFormat("0.00").format( 1-abs(pith)).toFloat()
            audioPlayer!!.playbackParams = params
        }

        if (statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.ready) {
            audioPlayer!!.pause()
        }
    }
}




