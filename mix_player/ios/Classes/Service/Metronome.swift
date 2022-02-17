//
//  Metronome.swift
//  mix_player
//
//  Created by Dotsocket on 2/15/22.
//

import UIKit
import AVFoundation

class Metronome {
    
    var bpm = 130
    var timer : Timer?
    var active = false
    var numOfSound = 0
    var sounds:[String] = ["1"]
    var player: AVAudioPlayer?
    var anotherPlayer: AVAudioPlayer?
    var tapTimer : Timer?
    var tapTime : Double = 0.00
    var tapIntervals : [Double] = []
    var tick  = 0
    var barSize = 4
    var tmp : Int = 0
    //var metronomeDelegate : MetronomeDelegate?
    
    init() {
        setSound()
        setFirstSound()
       
    }
    
    func setSound() {
        guard let url = Bundle.main.url(forResource: sounds[numOfSound], withExtension: "mp3") else {
            return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.volume = 1.0
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setFirstSound() {
        guard let url = Bundle.main.url(forResource: "1", withExtension: "mp3") else {
            return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            anotherPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            anotherPlayer?.volume = 1.0
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSound() {
        player?.stop()
        player?.currentTime = 0
        player?.play()
    }
    
    func playFirstSound()
    {
        anotherPlayer?.stop()
        anotherPlayer?.currentTime = 0
        anotherPlayer?.play()
    }
    
    func update() {
        if(active) {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(withTimeInterval: Double(60)/Double(bpm), repeats: true, block: tick)
        }
        else {
            timer?.invalidate()
            timer = nil
        }
    }
    
//    func tapTimer(_ tempStepper : UIStepper , _ tempoLabel : UILabel) {
//        if(tapTimer != nil) {
//            if(tapIntervals.count>3) {
//                tapIntervals = [tapIntervals[2]]
//            }
//            tapIntervals.append(tapTime)
//            tapTime = 0.0
//            if(tapIntervals.count>1) {
//                var average : Double = 0.0
//                for i in tapIntervals {
//                    average = average + i
//                }
//                average = Double(tapIntervals.count) / average
//                var tempo = average *  60.0
//                if(tempo > 350.0) {
//                    tempo = 350.0
//                }
//                bpm = Int(tempo)
//                tempStepper.value = tempo
//                tempoLabel.text = "\(bpm) bpm"
//                update()
//            }
//        }
//        else {
//            tempoLabel.text = "KEEP TAPPING"
//        }
//        tapTimer?.invalidate()
//        tapTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: count)
//    }
//
    private func count(timer : Timer?) {
        tapTime = tapTime + 0.01
        if(tapTime>4.0)
        {
            tapTime = 0.0
            tapTimer?.invalidate()
            tapTimer = nil
            tapIntervals = []
          //  metronomeDelegate?.tempoLabelChange(value : "\(bpm) bpm")
        }
        
    }
    
    
    private func tick(timer : Timer?)
    {
     //   metronomeDelegate?.barCounterLabelChange(value : String(tick / barSize))
        print("tick \(bpm)  \(tick % barSize)")
        if((tick % barSize) == 0 && barSize != 1)
        {
            playFirstSound()
        }
        else
        {
            playSound()
        }
        tick = tick + 1
    }
    
}
