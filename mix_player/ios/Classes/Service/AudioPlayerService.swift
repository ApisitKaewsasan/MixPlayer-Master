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
    var engines = AVAudioEngine()
    var audioPlayer = AVAudioPlayerNode()
    var notificationsHandler: NotificationsHandler? = nil
    
    var playerId: String
    var audioItem: AudioItem?
    
    var speedControl = AVAudioUnitVarispeed()
    var pitchControl = AVAudioUnitTimePitch()
    var unitSampler =  AVAudioMixerNode()
    let reverb = AVAudioUnitReverb()
    
    var player = AudioPlayer()
    var equaliserService: EqualizerService? = nil
    var duration:CMTime?
    
    var modeLoop  = false

  
    init(reference: SwiftMixPlayerPlugin,playerId : String) {
        self.reference = reference
        self.playerId = playerId
    }
    

    
    func initData(audioItem:AudioItem){
        self.audioItem = audioItem
      
        self.player.delegate = self
        self.configureAudioSession()
        self.registerSessionEvents()
        
        activateAudioSession()
        player.attach(nodes: [speedControl,pitchControl,unitSampler])
        equaliserService = EqualizerService(playerService: self)
        player.volume = Float((0.01*self.audioItem!.volume!))

        
       // player.attach(node: audioPlayer)
      
        notificationsHandler = NotificationsHandler(reference: self)
        
    }
    
    


    func stop() {
        if(player.state != .error){
            player.stop()
        }
    }

    func pause() {
        if(player.state != .error && player.state == .playing){
            player.pause()
        }
    }

  

    func toggleMute() {
        if(player.state != .error){
            if(player.muted){
                player.muted = false
            }else{
                player.muted = true
            }
        }
    }

    func update(rate: Float) {
        if(player.state != .error){
            player.rate = rate
        }
    }
    
    func resume(at:Double) {
        if(player.state != .error){
            player.seek(to: at)
            player.resume()

        }
    }
    
    func setModeLoop(mode:Bool){
        self.modeLoop = mode
    }
    
    func reloadPlay(){
        player.seek(to: 0.0)
        toggle(at: 0.0)
    }
    
  
    func play(at:Double){
        if(player.state != .error){
            if(audioItem!.isLocalFile){
                guard let destinationURL = localFilePath(for: URL(string: audioItem!.url!)!) else { return }
                player.seek(to: at)
                player.play(url: destinationURL)
                
            }else{
                player.seek(to: at)
                player.play(url: URL(string: audioItem!.url!)!)
                
            }
        }
//        guard let destinationURL = localFilePath(for: URL(string: audioItem!.url!)!) else { return }
//        var metronome = EngMetronome(url: destinationURL)
//        metronome.play(bpm: 360)
    }

    func toggle(at:Double) {
            if(player.state != .error){
                if(player.state == .playing){
                    pause()
                }else if(player.state == .paused){
                    resume(at: at)
                }else{
                    play(at: at)
                }
            }
        
    }
    
    func wetDryMix(mix:Float){
        if(player.state != .error){
            reverb.wetDryMix = mix
        }
    }
    
    func skipForward(time:Float){
        if(player.state != .error && player.state != .bufferring){
            let increase = self.player.progress + Double(time)
            if increase < self.player.duration{
                seek(at: Double(increase))
            }
        }
        
    }
    
    func skipBackward(time:Float){
        if(player.state != .error && player.state != .bufferring){
            let increase = self.player.progress - Double(time)
            if increase < 0{
               
                seek(at: 0)
            }else{
               
                seek(at: Double(increase))
            }
        }
    }
    
    func updateVolume(volume:Float){
        if(player.state != .error){
            player.volume = (0.01 * volume)
        }
    }

    func seek(at time: Double) {
        if(player.state != .error){
            player.seek(to: time)
            self.reference.playbackEventMessageStream(playerId: self.playerId, currentTime: time, duration:182)
        }
    }

    
    func setPan(pan:Float){
        if(player.state != .error){
            unitSampler.pan = pan / 100
        }
    }
    
    func setPitch(pitch:Float){
        if(player.state != .error){
            print("efwcec \(pitch)")
            pitchControl.pitch = pitch * 100
        }
    }
    
    func addNode(_ node: AVAudioNode) {
        if(player.state != .error){
            player.attach(node: node)
        }
    }

    func removeNode(_ node: AVAudioNode) {
        if(player.state != .error){
            player.detach(node: node)
        }
    }
    

    func setPlaybackRate(playbackRate: Float) {
        if(player.state != .error){
            speedControl.rate = playbackRate
        }
    }
    
   
    
    private func startDisplayLink() {
        if(player.state != .error){
            displayLink?.invalidate()
            displayLink = nil
            displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(tick))
            displayLink?.preferredFramesPerSecond = 6
            displayLink?.add(to: .current, forMode: .common)
        }
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    
    }

    @objc private func tick() {
        let duration = player.duration
        let progress = player.progress


        let elapsed = Int(progress)
        let remaining = Int(duration - progress)
        //print("ewfcewfc \(timeFrom(seconds: elapsed))     \(timeFrom(seconds: remaining))")
        reference.playbackEventMessageStream(playerId: playerId, currentTime: progress, duration: duration)
    }
    
    
    private func timeFrom(seconds: Int) -> String {
        let correctSeconds = seconds % 60
        let minutes = (seconds / 60) % 60
        let hours = seconds / 3600

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, correctSeconds)
        }
        return String(format: "%02d:%02d", minutes, correctSeconds)
    }

    private func registerSessionEvents() {
        // Note that a real app might need to observer other AVAudioSession notifications as well
        audioSystemResetObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification,
                                                                          object: nil,
                                                                          queue: nil) { [unowned self] _ in
            self.configureAudioSession()
            
        }
    }

    private func configureAudioSession() {
        do {
            print("AudioSession category is AVAudioSessionCategoryPlayback")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.1)
        } catch let error as NSError {
            print("Couldn't setup audio session category to Playback \(error.localizedDescription)")
        }
    }

    private func activateAudioSession() {
        do {
            print("AudioSession is active")
            try AVAudioSession.sharedInstance().setActive(true, options: [])

        } catch let error as NSError {
            print("Couldn't set audio session to active: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        do {
            print("AudioSession is deactivated")
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            print("Couldn't deactivate audio session: \(error.localizedDescription)")
        }
    }
}


extension AudioPlayerService : AudioPlayerDelegate{

    func audioPlayerDidStartPlaying(player _: AudioPlayer, with _: AudioEntryId) {
        print("audioPlayerDidStartPlaying")

    }

    func audioPlayerDidFinishBuffering(player _: AudioPlayer, with _: AudioEntryId) {
        print("audioPlayerDidFinishBuffering")
       
    }

    func audioPlayerStateChanged(player _: AudioPlayer, with newState: AudioPlayerState, previous _: AudioPlayerState) {
        print("audioPlayerStateChanged \(newState)")
        if(newState == .playing){
           
            notificationsHandler?.setupNotificationMedia(playbackRate: 1)
            startDisplayLink()
        }else if(newState == .stopped || newState == .bufferring || newState == .paused){
            
            notificationsHandler?.UpdateCenterInfo(playbackRate: 0)
            stopDisplayLink()
        }
       
            if(newState == .ready){
                reference.onPlayerStateChanged(playerId: playerId, state: .ready)
            }else if(newState == .error){
                reference.onPlayerStateChanged(playerId: playerId, state: .error)
            }else if(newState == .bufferring){
                reference.onPlayerStateChanged(playerId: playerId, state: .bufferring)
            }else if(newState == .disposed){
                reference.onPlayerStateChanged(playerId: playerId, state: .disposed)
            }else if(newState == .paused){
                reference.onPlayerStateChanged(playerId: playerId, state: .paused)
            }else if(newState == .playing){
                reference.onPlayerStateChanged(playerId: playerId, state: .playing)
            }else if(newState == .running){
                reference.onPlayerStateChanged(playerId: playerId, state: .running)
            }
        
        
    }

    func audioPlayerDidFinishPlaying(player _: AudioPlayer,
                                     entryId _: AudioEntryId,
                                     stopReason _: AudioPlayerStopReason,
                                     progress _: Double,
                                     duration _: Double)
    {
        print("audioPlayerDidFinishPlaying")
        //reload()
        reference.onPlayerStateChanged(playerId: playerId, state: .complete)
        if(self.modeLoop){
            play(at: 0.0)
        }
        
    }

    func audioPlayerUnexpectedError(player _: AudioPlayer, error: AudioPlayerError) {
        print("audioPlayerUnexpectedError")
        reference.onError(playerId: playerId, message: (error.errorDescription! as String))
    }

    func audioPlayerDidCancel(player _: AudioPlayer, queuedItems _: [AudioEntryId]) {
        print("audioPlayerDidCancel")
    }

    func audioPlayerDidReadMetadata(player _: AudioPlayer, metadata: [String: String]) {
        print("audioPlayerDidReadMetadata")

    }

}



