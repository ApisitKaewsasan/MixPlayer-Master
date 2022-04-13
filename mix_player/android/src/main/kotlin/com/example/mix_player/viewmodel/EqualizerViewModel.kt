package com.example.mix_player.viewmodel

import android.media.audiofx.Equalizer
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.mix_player.data.BandData
import com.example.mix_player.data.EqualizerData

class EqualizerViewModel(private val equalizer: Equalizer){
    private val _equalizerData = MutableLiveData<EqualizerData>()
    init {
        setupEqualizer()
        equalizer.enabled = true
    }
    private fun setupEqualizer() {

        _equalizerData.value = EqualizerData(
            numberOfBands = equalizer.numberOfBands,
            minEQLevel =  equalizer.bandLevelRange[0],
            maxEQLevel = equalizer.bandLevelRange[1],
            bandDataList = (0 until equalizer.numberOfBands).map {
                val band = it.toShort()
                BandData(
                    band = band,
                    centerFreq = equalizer.getCenterFreq(band), // 周波数 単位はミリHz
                    bandLevel = equalizer.getBandLevel(band), // 周波数のlevel
                )
            }
        )
    }
    fun notifyUpdateBandLevel(band: Short, progress: Int) {
        _equalizerData.value?.let {
            equalizer.setBandLevel(band, progress.toShort())

        }
    }

    fun reset(){
        for (i in 0 until  _equalizerData.value!!.bandDataList.size){

            notifyUpdateBandLevel(i.toShort(),0)
        }
    }
}