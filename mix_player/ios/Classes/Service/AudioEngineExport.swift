//
//  AudioEngineExport.swift
//  mix_player
//
//  Created by Dotsocket on 2/8/22.
//

import Foundation
import Network



class AudioEngineExport{
    
    var engine = AVAudioEngine()
    var audioPlayer = [AVAudioPlayerNode]()
    var formatAudio =  [AVAudioFormat]()
    var sourceFile = [AVAudioFile]()
    
    // MARK: add effect ------ BASE
    let reverbControl = AVAudioUnitReverb()
    
    // MARK: add effect ------ SEPPD
    let speedControl = AVAudioUnitVarispeed()
    
    // MARK: add effect ------ PITCH
    let pitchControl = AVAudioUnitTimePitch()
    
    // MARK: add effect ------ UnitEQ
    var eqUnit = AVAudioUnitEQ()
    
    var mixernode = AVAudioMixerNode()
    
    var url:[String]?
    var objective = AudioRander()
    
    
    var reverbConfig:Float
    var speedConfig:Float
    var panConfig:Float
    var pitchConfig:Float
    var frequencyConfig:[Int]
    var gainConfig:[Int]
    var panPlayerConfig:[Float]
    
    
 
   
    init(url:[String],reverbConfig:Float,speedConfig:Float,panConfig:Float,pitchConfig:Float,frequencyConfig:[Int],gainConfig:[Int],panPlayerConfig:[Float]){
        self.url = url
        self.reverbConfig = reverbConfig
        self.speedConfig = speedConfig
        self.panConfig = panConfig
        self.pitchConfig = pitchConfig * 100
        self.frequencyConfig = frequencyConfig
        self.gainConfig = gainConfig
        self.panPlayerConfig = panPlayerConfig
        self.eqUnit = AVAudioUnitEQ(numberOfBands: gainConfig.count)
        configEngineAudio()
    }
    
    
    
    func configEngineAudio(){
        clearCachesAudio(fileName: "mix_export_audio")
        do{
            for var i in 0..<self.url!.count {
                // append new AVAudio
                audioPlayer.append(AVAudioPlayerNode())
                formatAudio.append(AVAudioFormat())
                sourceFile.append(AVAudioFile())
                engine.attach(audioPlayer[i])
                
                // add AVAudioFile
                guard let destinationURL = localFilePath(for: URL(fileURLWithPath: self.url![i])) else { return }
                sourceFile[i] = try AVAudioFile(forReading: destinationURL)
                audioPlayer[i].scheduleFile(sourceFile[i], at: nil)
                formatAudio[i] = sourceFile[i].processingFormat
            }
        } catch {
            fatalError("error: 💩💩💩💩 - \(error)")
        }
        
    
       
            engine.attach(pitchControl)
            engine.attach(mixernode)
            engine.attach(speedControl)
            engine.attach(reverbControl)
            engine.attach(eqUnit)
            
            for var i in 0..<self.url!.count {
                engine.connect(audioPlayer[i], to: mixernode, format: nil)
            }
            
       
            engine.connect(mixernode, to: speedControl, format: nil)
            engine.connect(speedControl, to: pitchControl, format: nil)
            engine.connect(pitchControl, to: reverbControl, format: nil)
            engine.connect(reverbControl, to: eqUnit, format: nil)
            engine.connect(eqUnit, to: engine.mainMixerNode, format: nil)
        
        
        
          //   config effect
            if(gainConfig.count>0){
                for i in 0..<gainConfig.count {
                      eqUnit.bands[i].bypass = false
                      eqUnit.bands[i].filterType = .parametric
                      eqUnit.bands[i].frequency = Float(frequencyConfig[i])
                      eqUnit.bands[i].bandwidth = 0.5
                      eqUnit.bands[i].gain = Float(gainConfig[i])
                  }
            }
       
        if(panPlayerConfig.count>0){
            for i in 0..<panPlayerConfig.count {
              self.audioPlayer[i].pan = panPlayerConfig[i]
           }
        }
//
      
            self.reverbControl.wetDryMix = self.reverbConfig
            self.speedControl.rate = self.speedConfig
            self.mixernode.pan = self.panConfig
            self.pitchControl.pitch = self.pitchConfig
            
            
        do{
            try engine.start()
             objective.configureAudioEngine(engine,playerNode: audioPlayer.first, fileUrl:sourceFile.first)
             objective.clearTmpDirectory()
        }catch let error{
            fatalError("error: 💩💩💩💩 - \(error)")
        }
    }
    
    func exportAudio(extensionFile:String)->String{
        var Path = ""
        for var i in 0..<self.url!.count {
            audioPlayer[i].play()
        }
        engine.pause()
       
        Path = objective.renderAudioAndWrite(toFileExtension: extensionFile, callback: { totalBytesWritten, totalBytesExpectedToWrite in
            self.delegate?.procuessRenderToBuffer(procuess: round((Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))*100))
        })
        engine.stop()
        
//
        return Path
    }
    
    
    weak var delegate: AudioEngineExportDelegate?
}

protocol AudioEngineExportDelegate: AnyObject {
    func procuessRenderToBuffer(procuess: Double)
}
