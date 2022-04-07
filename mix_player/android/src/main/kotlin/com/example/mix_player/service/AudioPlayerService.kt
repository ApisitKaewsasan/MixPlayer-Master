package com.example.mix_player.service

import android.content.Context
import android.media.*
import android.os.Build
import android.os.Handler
import androidx.annotation.RequiresApi
import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.AudioItem
import com.example.mix_player.models.AudioPlayerStates
import java.io.IOException
import java.nio.ByteBuffer
import java.text.DecimalFormat
import java.util.concurrent.TimeUnit
import kotlin.math.abs


@RequiresApi(Build.VERSION_CODES.M)
class AudioPlayerService(
    var reference: MixPlayerPlugin,
    var playerId: String,
    var context: Context
) : Runnable {


    lateinit var audioItem: AudioItem
    var  leftVolume:Float = 1F
    var  rightVolume:Float = 1F

    var isMute = true

    private var mCodec: MediaCodec? = null
    private var mExtractor: MediaExtractor? = null
    private var mAudioTrack: AudioTrack? = null
    private var mBufferSize = 0
    private var mRelativePlaybackSpeed = 1f
    private var mSrcRate = 44100
    private var mPlaybackStart = 0

    var statePlayer :AudioPlayerStates = AudioPlayerStates.ready
    var duration : Long = 0

    var handler = Handler()
    var runnable: Runnable? = null

    private fun getDuration(file:String): Long {
        val mediaMetadataRetriever = MediaMetadataRetriever()
        mediaMetadataRetriever.setDataSource(file)
        val durationStr =
            mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
        return TimeUnit.MILLISECONDS.toSeconds(durationStr!!.toLong())
    }

    var currentPosition : Long = 0
        get() {
            return  (((mPlaybackStart + mAudioTrack!!.playbackHeadPosition) *
                    (1000.0 / mSrcRate)).toLong())
        }




    fun initData(audioItem: AudioItem) {
        this.audioItem = audioItem


        duration = getDuration(audioItem.url)

    }








    @RequiresApi(Build.VERSION_CODES.M)
    fun play(at: Double) {
//        val params: PlaybackParams = audioPlayer.playbackParams
//        params.speed = 2F
//        audioPlayer.playbackParams = params

//        changeSeekBar()
//        audioPlayer.prepare()
//        audioPlayer.start()

        if(statePlayer ==  AudioPlayerStates.ready) {
            playerStateChanged(AudioPlayerStates.playing)
            changeSeekBar()
            prepare()
            Thread(this).start()
        }


    }


    fun changeSeekBar(){
        runnable = Runnable {
            changeSeekBar()
            if(TimeUnit.MILLISECONDS.toSeconds(currentPosition)<=duration){
                if(statePlayer == AudioPlayerStates.playing){
                    reference.playbackEventMessageStream(playerId,currentPosition,duration)
                }
                // System.out.println("currentPosition-> ${TimeUnit.MILLISECONDS.toSeconds(currentPosition)}   duration-> ${duration}")
                if(TimeUnit.MILLISECONDS.toSeconds(currentPosition)==duration){
                    playerStateChanged(AudioPlayerStates.ready)
                    reference.playbackEventMessageStream(playerId,0,duration)
                    handler.removeCallbacks(runnable!!)
                    //        mAudioTrack!!.stop()
                    mCodec!!.stop()
                    mCodec!!.release()
                    mExtractor!!.release()
                }
            }

        }

        handler.postDelayed(runnable!!, 1000)
    }

    fun resume(at: Double){
        if(statePlayer ==  AudioPlayerStates.paused) {
            mAudioTrack!!.play()
            // changeSeekBar()
            playerStateChanged(AudioPlayerStates.playing)

            // Thread(this).start()

        }

    }

    fun stop() {
        if(statePlayer ==  AudioPlayerStates.playing) {
            statePlayer = AudioPlayerStates.stopped
        }
    }


    fun pause(){
        if(statePlayer ==  AudioPlayerStates.playing) {
            playerStateChanged(AudioPlayerStates.paused)
            mAudioTrack!!.pause()
            // handler.removeCallbacks(runnable!!)

            // mAudioTrack!!.pause()
        }
    }


    fun skipBackward(time:Double){
        if(statePlayer == AudioPlayerStates.paused || statePlayer == AudioPlayerStates.playing) {
            // if(player.state != .error && player.state != .bufferring){
            val increase = (TimeUnit.SECONDS.convert(
                currentPosition,
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
            val increase = (TimeUnit.SECONDS.convert(currentPosition, TimeUnit.MILLISECONDS)) + time.toInt()
            // System.out.println("edfwvre ${TimeUnit.MILLISECONDS.convert(increase,TimeUnit.SECONDS)}")


            if(increase > duration){
                //seek(audioPlayer.duration)
                System.out.println("เกินเวลา")
            }else if (increase < duration){
                System.out.println("increase -> ${increase}  current -> ${(TimeUnit.SECONDS.convert(currentPosition, TimeUnit.MILLISECONDS)) }")
                seek(TimeUnit.MILLISECONDS.convert(increase,TimeUnit.SECONDS).toInt())
            }
        }


    }


    fun seek(time: Int) {

        mExtractor!!.seekTo((time * 1000).toLong(), MediaExtractor.SEEK_TO_CLOSEST_SYNC)

        reference.playbackEventMessageStream(playerId,currentPosition,duration)
    }

    fun playerStateChanged(state: AudioPlayerStates){
        statePlayer = state
        reference.onPlayerStateChanged(playerId,state)
    }


    fun updateVolume(volume:Float){
        leftVolume = volume
        rightVolume = volume
        // audioPlayer.volume = volume
        if(isMute && mAudioTrack!=null){
            //   audioPlayer.setVolume(leftVolume,rightVolume)
            mAudioTrack!!.setStereoVolume(leftVolume,rightVolume)
        }
    }

    fun setPan(pan:Float){
        if(mAudioTrack!=null){


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
                // audioPlayer.setVolume(leftVolume,rightVolume)
                mAudioTrack!!.setStereoVolume(leftVolume,rightVolume)
            }
        }

    }

    fun toggleMute(){
        if(isMute){
            isMute = false
            //  audioPlayer.setVolume(0F,0F)
            mAudioTrack!!.setStereoVolume(0F,0F)
        }else{
            isMute = true
            mAudioTrack!!.setStereoVolume(leftVolume,rightVolume)
        }

    }

    fun setPitch(pith:Float) {
        //    if (audioPlayer.playbackParams.pitch == pith) return
        // audioPlayer.playbackParams = PlaybackParams().setPitch(1.0f)
        //  val params: PlaybackParameters = audioPlayer.playbackParametersx
        //    var temp = audioPlayer.currentPosition
        //  val params: PlaybackParams = audioPlayer.playbackParams
//        params.speed = 2F
//        audioPlayer.playbackParams = params
        if(pith == 0.0F){

            // audioPlayer.playbackParameters = PlaybackParameters(params.speed, 1.0F)

//            audioPlayer.playbackParams.pitch = 1.0F
//            audioPlayer.playbackParams.speed = 1F


            mAudioTrack!!.playbackParams = PlaybackParams().setPitch( 1.0F)

        }else if(pith>=1.0){

            //  audioPlayer.playbackParameters = PlaybackParameters(params.speed, pith)
            mAudioTrack!!.playbackParams.pitch = pith
            mAudioTrack!!.playbackParams = PlaybackParams().setPitch(pith)
            //  audioPlayer.playbackParams = PlaybackParams().setPitch(pith)

        }else{
            var pitch = 1.2

            for (i in 0 until abs(pith).toInt()) {
                pitch -= 0.1
                if(i==abs(pith).toInt()-1){
                    //  audioPlayer.playbackParams.pitch = DecimalFormat("0.00").format(pitch).toFloat()
                    mAudioTrack!!.playbackParams = PlaybackParams().setPitch(DecimalFormat("0.00").format(pitch).toFloat())

                }

            }


            // audioPlayer.playbackParams = PlaybackParams().setPitch(0.20F)
            //  audioPlayer.playbackParameters = PlaybackParameters(params.speed, abs(pith+1.0).toFloat())

        }

        if(statePlayer ==  AudioPlayerStates.paused || statePlayer ==  AudioPlayerStates.ready){
            // audioPlayer.pause()
        }


        //val params: PlaybackParameters = player.getPlaybackParameters()
//        if (params.pitch === pitch) return
//        audioPlayer.setPlaybackParameters(PlaybackParameters(params.speed, pitch))

        //  audioPlayer.release()


    }






    private fun prepare() {
        // Setup a MediaExtractor to get information about the stream
        // and to get samples out of the stream


        mExtractor = MediaExtractor()
        try {
            mExtractor!!.setDataSource(audioItem.url)
        } catch (e: IOException) {
            e.printStackTrace()
        }
        if (mExtractor!!.trackCount > 0) {
            // Get mime type of the first track
            val format = mExtractor!!.getTrackFormat(0)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime!!.startsWith("audio")) {
                mCodec = MediaCodec.createDecoderByType(mime)
                mCodec!!.configure(
                    format,
                    null,  // We don't have a surface in audio decoding
                    null,  // No crypto
                    0
                ) // 0 for decoding

                // Select the first track for decoding
                mExtractor!!.selectTrack(0)

                mCodec!!.start() // Fire up the codec
                // Create an AudioTrack. Don't make the buffer size too small:
                mBufferSize = 8 * AudioTrack.getMinBufferSize(
                    44100,
                    AudioFormat.CHANNEL_OUT_STEREO,
                    AudioFormat.ENCODING_PCM_16BIT
                )
                mAudioTrack = AudioTrack(
                    AudioManager.STREAM_MUSIC,
                    44100,
                    AudioFormat.CHANNEL_OUT_STEREO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    mBufferSize,
                    AudioTrack.MODE_STREAM
                )
                // Don't forget to start playing

                mAudioTrack!!.play()
                //    playerStateChanged(AudioPlayerStates.ready)



            }
        }
    }


    override fun run() {

        val inputBuffers = mCodec!!.inputBuffers
        var outBuffers = mCodec!!.outputBuffers
        var activeOutBuffer: ByteBuffer? = null // The active output buffer
        var activeIndex = 0 // Index of the active buffer
        var availableOutBytes = 0
        var writeableBytes = 0
        // writeBuffer stores the samples until they can be written out to the AudioTrack
        val writeBuffer = ByteArray(mBufferSize)
        var writeOffset = 0
        val info = MediaCodec.BufferInfo()
        var EOS = false
        while (statePlayer == AudioPlayerStates.playing || statePlayer == AudioPlayerStates.paused) {
            // Get PCM data from the stream
            if(statePlayer == AudioPlayerStates.paused){ continue }

            if (!EOS) {
                // Dequeue an input buffer
                val inIndex = mCodec!!.dequeueInputBuffer(TIMEOUT_US)
                if (inIndex >= 0) {
                    val buffer = inputBuffers[inIndex]
                    // Fill the buffer with stream data
                    val sampleSize = mExtractor!!.readSampleData(buffer, 0)
                    // Pass the stream data to the codec for decoding: queueInputBuffer

                    if (sampleSize < 0) {
                        // We have reached the end of the stream
                        mCodec!!.queueInputBuffer(
                            inIndex,
                            0,
                            0,
                            0,
                            MediaCodec.BUFFER_FLAG_END_OF_STREAM
                        )
                        EOS = true
                    } else {
                        mCodec!!.queueInputBuffer(
                            inIndex,
                            0,
                            sampleSize,
                            mExtractor!!.sampleTime,
                            0
                        )
                        mExtractor!!.advance()
                    }
                }
            }
            if (availableOutBytes == 0) {
                // we don't have any samples available: Dequeue a new output buffer.
                activeIndex = mCodec!!.dequeueOutputBuffer(info, TIMEOUT_US)
                when (activeIndex) {
                    MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED -> outBuffers = mCodec!!.outputBuffers
                    MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        // Update the playback rate
                        val outFormat = mCodec!!.outputFormat
                        mSrcRate = outFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                        mAudioTrack!!.playbackRate = (mSrcRate * mRelativePlaybackSpeed).toInt()
                    }
                    MediaCodec.INFO_TRY_AGAIN_LATER -> {}
                    else -> {
                        // set the activeOutBuffer
                        activeOutBuffer = outBuffers[activeIndex]
                        availableOutBytes = info.size
                        assert(info.offset == 0)
                    }
                }
            }
            if (activeOutBuffer != null && availableOutBytes > 0) {
                writeableBytes = Math.min(availableOutBytes, mBufferSize - writeOffset)
                // Copy as many samples to writeBuffer as possible
                activeOutBuffer[writeBuffer, writeOffset, writeableBytes]
                availableOutBytes -= writeableBytes
                writeOffset += writeableBytes
            }
            if (writeOffset == mBufferSize) {
                // The buffer is full. Submit it to the AudioTrack
                mAudioTrack!!.write(writeBuffer, 0, mBufferSize)
                writeOffset = 0
            }
            if (activeOutBuffer != null && availableOutBytes == 0) {
                // IMPORTANT: Clear the active buffer!
                activeOutBuffer.clear()
                if (activeIndex >= 0) {
                    // Give the buffer back to the codec
                    mCodec!!.releaseOutputBuffer(activeIndex, false)
                }
            }
            if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                // Get out of here

                break
            }
        }
        //Clean up

        // playerStateChanged(AudioPlayerStates.ready)

    }



    companion object {
        private const val TIMEOUT_US: Long = 1000
    }



}





