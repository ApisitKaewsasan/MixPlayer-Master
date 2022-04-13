package com.example.mix_player.data

data class EqualizerData(
    val numberOfBands: Short,
    val minEQLevel: Short,
    val maxEQLevel: Short,
    val bandDataList: List<BandData>
)

data class BandData(
    val band: Short,
    val centerFreq: Int,
    val bandLevel: Short,
)
