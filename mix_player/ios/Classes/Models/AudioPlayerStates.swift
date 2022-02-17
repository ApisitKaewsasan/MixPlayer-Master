//
//  AudioPlayerStates.swift
//  mix_player
//
//  Created by Dotsocket on 2/17/22.
//

import Foundation


public enum AudioPlayerStates: Equatable {
    case ready
    case running
    case playing
    case bufferring
    case paused
    case complete
    case stopped
    case error
    case disposed
}
