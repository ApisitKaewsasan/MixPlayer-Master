//
//  AudioItem.swift
//  audio_player
//
//  Created by Dotsocket on 1/26/22.
//

import Foundation

class AudioItem{
    var playerId: String?
    var title: String?
    var albumTitle: String?
    var artist: String?
    var albumimageUrl: String?
    var skipInterval: Double?
    var url:String?
    var volume:Double?
    var enable_equalizer:Bool?
    var frequecy:[Int]?
    var isLocalFile:Bool = false

    init(playerId: String?,title: String?,albumTitle: String?,artist: String?,albumimageUrl: String?,skipInterval: Double?,url:String?,volume:Double?,enable_equalizer:Bool,frequecy:[Int],isLocalFile:Bool){

        self.playerId = playerId
        self.title = title
        self.albumTitle = albumTitle
        self.artist = artist
        self.albumimageUrl = albumimageUrl
        self.skipInterval = skipInterval
        self.url = url
        self.volume = volume
        self.enable_equalizer = enable_equalizer
        self.frequecy = frequecy
        self.isLocalFile = isLocalFile

      }

}
