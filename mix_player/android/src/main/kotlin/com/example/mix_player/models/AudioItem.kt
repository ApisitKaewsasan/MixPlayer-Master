package com.example.mix_player.models

class AudioItem(
    var playerId: String,
    var title: String,
    var albumTitle: String,
    var artist: String,
    var albumimageUrl: String,
    var skipInterval: Double = 0.0,
    var url: String,
    var volume: Double = 0.0,
    var enable_equalizer: Boolean = false,
    var frequecy: List<Int>,
    var isLocalFile: Boolean = false
)