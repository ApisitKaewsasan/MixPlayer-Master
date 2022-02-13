//
//  EqualizerService.swift
//  audio_player
//
//  Created by Dotsocket on 1/27/22.
//

import Foundation
import AVFoundation

class EqualizerService{
    
    private let playerService: AudioPlayerService
    private let eqUnit: AVAudioUnitEQ

   

    private(set) var isActivated: Bool = false

    init(playerService: AudioPlayerService) {
        self.playerService = playerService
        
        

        eqUnit = AVAudioUnitEQ(numberOfBands: self.playerService.audioItem!.frequecy!.count)
        
        for i in 0..<playerService.audioItem!.frequecy!.count {
            eqUnit.bands[i].bypass = false
            eqUnit.bands[i].filterType = .parametric
            eqUnit.bands[i].frequency = Float(self.playerService.audioItem!.frequecy![i])
            eqUnit.bands[i].bandwidth = 0.5
            eqUnit.bands[i].gain = 0
        }
        
        if(playerService.audioItem!.enable_equalizer!){
            activate()
        }
    }

    func update(gain: Float, for index: Int) {
        eqUnit.bands[index].gain = gain
    }

    func reset() {
        eqUnit.bands.forEach { $0.gain = 0 }
    }

    func activate() {
        isActivated = true
        playerService.addNode(eqUnit)
    }

    func deactive() {
        isActivated = false
        playerService.removeNode(eqUnit)
    }
}
