//
//  AudioPlayerService.swift
//  audio_player
//
//  Created by Dotsocket on 1/26/22.
//


import AudioStreaming
import Foundation
import AVFoundation


class AudioPlayerService:NSObject{
    
    private var reference: SwiftMixPlayerPlugin
    private var audioSystemResetObserver: Any?
    private var displayLink: CADisplayLink?
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var changePitchEffect = AVAudioUnitTimePitch()
    var eqUnit = AVAudioUnitEQ()
   
    var timer:Timer!
    
    var playerId: String
    var audioItem: AudioItem?

    var unitSampler =  AVAudioMixerNode()
    let reverb = AVAudioUnitReverb()
    var audioFile:AVAudioFile!
    
    private var needsFileScheduled = true
    
    private var audioSampleRate: Double = 0
    private var audioLengthSeconds: Double = 0

    private var seekFrame: AVAudioFramePosition = 0
    private var currentPosition: AVAudioFramePosition = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        
        return playerTime.sampleTime
    }
    
    var duration:CMTime?
    
    var state = AudioPlayerStates.ready
    
    var modeLoop  = false
    var isMute = true
    var volume:Float = 0.0

  
    init(reference: SwiftMixPlayerPlugin,playerId : String) {
        self.reference = reference
        self.playerId = playerId
        
    }
    

    
    func initData(audioItem:AudioItem){
        self.audioItem = audioItem
       
    
        setupAudioFile()
        setupDisplayLink()
      
    }

    
    func setupAudioFile(){
        do {
            guard let destinationURL = localFilePath(for: URL(string: audioItem!.url!)!) else { return }
            let file = try AVAudioFile(forReading: destinationURL)
          
            let format = file.processingFormat

            audioLengthSamples = file.length
            audioSampleRate = format.sampleRate
            audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            audioFile = file
            configureEqualizer()
            configureEngine(with: format)
            
           } catch let error {
               state = AudioPlayerStates.error
              print("error \(error.localizedDescription)")
           }
    }
    
    private func configureEngine(with format: AVAudioFormat) {
       
      engine.attach(player)
      engine.attach(changePitchEffect)
      engine.attach(unitSampler)
      engine.attach(eqUnit)
        
      engine.connect(player,to: eqUnit,format: format)
      engine.connect(eqUnit,to: unitSampler,format: format)
      engine.connect(unitSampler,to: changePitchEffect,format: format)
      engine.connect(changePitchEffect,to: engine.mainMixerNode,format: format)
        
      engine.prepare()

      do {
        try engine.start()

        scheduleAudioFile()
      } catch {
          state = AudioPlayerStates.error
        print("Error starting the player: \(error.localizedDescription)")
      }
    }
    

    private func configureEqualizer(){
        eqUnit = AVAudioUnitEQ(numberOfBands: self.audioItem!.frequecy!.count)
        
        for i in 0..<self.audioItem!.frequecy!.count {
            eqUnit.bands[i].bypass = false
            eqUnit.bands[i].filterType = .parametric
            eqUnit.bands[i].frequency = Float(self.audioItem!.frequecy![i])
            eqUnit.bands[i].bandwidth = 0.5
            eqUnit.bands[i].gain = 0
        }
    }
    
    private func scheduleAudioFile() {
      guard
        let file = audioFile,
        needsFileScheduled
      else {
        return
      }

      needsFileScheduled = false
      seekFrame = 0

      player.scheduleFile(file, at: nil) {
        self.needsFileScheduled = true
      }
    }


    func stop() {
     player.stop()
    }

    func pause() {
        if(state != AudioPlayerStates.error){
            player.pause()
            reference.onPlayerStateChanged(playerId: playerId, state: .error)
        }
    }

    func toggleMute() {
        
            
        if(state != AudioPlayerStates.error){
            if(isMute){
                volume = player.volume
                isMute = false
                player.volume = 0
            }else{
                isMute = true
                player.volume = volume
            }
        }
    }
    
    func resume(at:Double) {
        if(state != AudioPlayerStates.error){
            player.play()
            reference.onPlayerStateChanged(playerId: playerId, state: .playing)
        }
    }
    
    func setModeLoop(mode:Bool){
        self.modeLoop = mode
    }
    
    func reloadPlay(){
        seek(at: 0.0)
        toggle(at: 0.0)
    }
    
  
  func playOrPause(){
      
     if(state != AudioPlayerStates.error){
        
        if player.isPlaying {
          displayLink?.isPaused = true
         // disconnectVolumeTap()
            reference.onPlayerStateChanged(playerId: playerId, state: .paused)
          player.pause()
        } else {
          displayLink?.isPaused = false
          //connectVolumeTap()
            
          if needsFileScheduled {
            scheduleAudioFile()
          }
            reference.onPlayerStateChanged(playerId: playerId, state: .playing)
                player.play()
          
         }
      }
     
    }
    
    private func connectVolumeTap() {
      let format = engine.mainMixerNode.outputFormat(forBus: 0)

      engine.mainMixerNode.installTap(
        onBus: 0,
        bufferSize: 1024,
        format: format
      ) { buffer, _ in
        guard let channelData = buffer.floatChannelData else {
          return
        }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(
          from: 0,
          to: Int(buffer.frameLength),
          by: buffer.stride)
          .map { channelDataValue[$0] }

        let rms = sqrt(channelDataValueArray.map {
          return $0 * $0
        }
        .reduce(0, +) / Float(buffer.frameLength))

        let avgPower = 20 * log10(rms)
        let meterLevel = self.scaledPower(power: avgPower)

      }
    }

    private func disconnectVolumeTap() {
      engine.mainMixerNode.removeTap(onBus: 0)
    }
    
    // MARK: Audio metering

    private func scaledPower(power: Float) -> Float {
      guard power.isFinite else {
        return 0.0
      }

      let minDb: Float = -80

      if power < minDb {
        return 0.0
      } else if power >= 1.0 {
        return 1.0
      } else {
        return (abs(minDb) - abs(power)) / abs(minDb)
      }
    }
    
  

    func toggle(at:Double) {
        if(player.isPlaying){
            pause()
        }else{
          
            resume(at: at)
         }
    }
    
    func wetDryMix(mix:Float){
//        if(player.state != .error){
//            reverb.wetDryMix = mix
//        }
    }
    
    func skipForward(time:Float){
        let currentTime = Double(currentPosition) / audioSampleRate
        seek(at: Double(time))
        
    }
    
    func skipBackward(time:Float){
        let currentTime = Double(currentPosition) / audioSampleRate
        seek(at: Double(time))
    }
    
    func updateVolume(volume:Float){
        let wasPlaying = isMute
        player.volume = (0.01 * volume)
        
        if !wasPlaying {
            player.pause()
        }
    }

    func seek(at time: Double) {
        guard let audioFile = audioFile else {
          return
        }

        let offset = AVAudioFramePosition(time * audioSampleRate)
        seekFrame = max(offset, 0)
        seekFrame = min(offset, audioLengthSamples)
        currentPosition = seekFrame

        let wasPlaying = player.isPlaying
        player.stop()
        

        if currentPosition < audioLengthSamples {
          updateDisplay()
          needsFileScheduled = false

          let frameCount = AVAudioFrameCount(audioLengthSamples - seekFrame)
       
          player.scheduleSegment(
            audioFile,
            startingFrame: seekFrame < 0 ? 1: seekFrame,
            frameCount: frameCount,
            at: nil
          ) {
            self.needsFileScheduled = true
          }

          if wasPlaying {
            player.play()
          }
        }
    }

    
    func setPan(pan:Float){
        unitSampler.pan = pan / 100
    }
    
    func setPitch(pitch:Float){
        changePitchEffect.pitch = 1200 * pitch
       
    }

    func setPlaybackRate(playbackRate: Float) {
        changePitchEffect.rate = playbackRate
    }
    
    func updateEQ(gain: Float, for index: Int) {
        eqUnit.bands[index].gain = gain
    }

    func resetEQ() {
        eqUnit.bands.forEach { $0.gain = 0 }
    }
    
    private func setupDisplayLink() {
      displayLink = CADisplayLink(
        target: self,
        selector: #selector(updateDisplay))
      displayLink?.add(to: .current, forMode: .default)
      displayLink?.isPaused = true
    }

    @objc private func updateDisplay() {
        let currentTime = Double(currentPosition) / audioSampleRate
        let duration = audioLengthSeconds
        
      currentPosition = currentFrame + seekFrame
      currentPosition = max(currentPosition, 0)
      currentPosition = min(currentPosition, audioLengthSamples)
      reference.playbackEventMessageStream(playerId: playerId, currentTime: currentTime, duration: duration)
            
      if currentPosition >= audioLengthSamples {
         
      
        
          if(modeLoop){
              print("currentTime \(PlayerTime(elapsedTime: currentTime, remainingTime: audioLengthSeconds).elapsedText)   duration \(duration)")
             // playOrPause()
              seek(at: 1)
          }else{
              player.stop()

              seekFrame = 0
              currentPosition = 0
              displayLink?.isPaused = true
              seek(at: 0)
            //  disconnectVolumeTap()
              
              reference.onPlayerStateChanged(playerId: playerId, state: .ready)
          }
         
      }

    }

}

enum TimeConstant {
  static let secsPerMin = 60
  static let secsPerHour = TimeConstant.secsPerMin * 60
}
struct PlayerTime {
  let elapsedText: String
  let remainingText: String

  static let zero: PlayerTime = .init(elapsedTime: 0, remainingTime: 0)

  init(elapsedTime: Double, remainingTime: Double) {
    elapsedText = PlayerTime.formatted(time: elapsedTime)
    remainingText = PlayerTime.formatted(time: remainingTime)
  }

  private static func formatted(time: Double) -> String {
    var seconds = Int(ceil(time))
    var hours = 0
    var mins = 0

    if seconds > TimeConstant.secsPerHour {
      hours = seconds / TimeConstant.secsPerHour
      seconds -= hours * TimeConstant.secsPerHour
    }

    if seconds > TimeConstant.secsPerMin {
      mins = seconds / TimeConstant.secsPerMin
      seconds -= mins * TimeConstant.secsPerMin
    }

    var formattedString = ""
    if hours > 0 {
      formattedString = "\(String(format: "%02d", hours)):"
    }
    formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", seconds))"
    return formattedString
  }
}



