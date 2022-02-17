//
//  EngMetronome.swift
//  mix_player
//
//  Created by Dotsocket on 2/15/22.
//

import Foundation
import AVFoundation

struct GlobalConstants {
    static let kBipDurationSeconds: Float32 = 0.020
    static let kTempoChangeResponsivenessSeconds: Float32 = 0.250
}

 protocol EngMetronomeMetronomeDelegate: class {
    func metronomeTicking(_ metronome: Metronome, bar: Int32, beat: Int32)
}

class EngMetronome : NSObject {
    var audioPlayerNode:AVAudioPlayerNode
    var audioFile:AVAudioFile
    var audioEngine:AVAudioEngine

    init (fileURL: URL) {

        audioFile = try! AVAudioFile(forReading: fileURL)

        audioPlayerNode = AVAudioPlayerNode()

        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)

        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        try! audioEngine.start()
    }

    func generateBuffer(forBpm bpm: Int) -> AVAudioPCMBuffer {
        audioFile.framePosition = 0
        let periodLength = AVAudioFrameCount(audioFile.processingFormat.sampleRate * 60 / Double(bpm))
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: periodLength)
        try! audioFile.read(into: buffer!)
        buffer?.frameLength = periodLength
        return buffer!
    }

    func play(bpm: Int) {

        let buffer = generateBuffer(forBpm: bpm)

        self.audioPlayerNode.play()

        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
    }

    func stop() {
        audioPlayerNode.stop()
    }
    }
