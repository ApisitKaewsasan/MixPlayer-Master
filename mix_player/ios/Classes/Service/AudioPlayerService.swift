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
    var audioPlayer = [AVAudioPlayerNode]()
    var notificationsHandler: NotificationsHandler? = nil
    
    var playerId: String
    var audioItem: AudioItem?
    
    var speedControl = AVAudioUnitVarispeed()
    var pitchControl = AVAudioUnitTimePitch()
    var unitSampler =  AVAudioMixerNode()
    let reverb = AVAudioUnitReverb()
    
    var player = AudioPlayer()
    var equaliserService: EqualizerService? = nil

    

  
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

        
        
      
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
            let audioAsset = AVURLAsset.init(url: URL(string: audioItem.url!)!, options: nil)
                let duration = audioAsset.duration
            self.reference.playbackEventMessageStream(playerId: self.playerId, currentTime: 0.0, duration: CMTimeGetSeconds(duration))
           
        }
     
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
        if(player.muted){
            player.muted = false
        }else{
            player.muted = true
        }
    }

    func update(rate: Float) {
        player.rate = rate
    }
    
    func resume() {
        if(player.state != .error){
            player.resume()
        }
    }
    
    func reload(){
        DispatchQueue(label: "sync").sync {
            play()
        }
        DispatchQueue(label: "sync").sync {
            pause()
        }
       
    }
    
  
    func play(){
        if(audioItem!.isLocalFile){
            guard let destinationURL = localFilePath(for: URL(string: audioItem!.url!)!) else { return }
            player.play(url: destinationURL)
        }else{
            player.play(url: URL(string: audioItem!.url!)!)
        }
    }

    func toggle() {
   
        if(player.state != .error){
            if(player.state == .playing){
                pause()
            }else if(player.state == .paused){
                resume()
            }else{
                play()
            }
        }
      
    }
    
    func wetDryMix(mix:Float){
        reverb.wetDryMix = mix
    }
    
    func skipForward(time:Float){
        let increase = self.player.progress + Double(time)
        if increase < self.player.duration{
            seek(at: Double(increase))
        }
        
    }
    
    func skipBackward(time:Float){
        let increase = self.player.progress - Double(time)
        seek(at: Double(increase))
    }
    
    func updateVolume(volume:Float){
        player.volume = (0.01 * volume)
    }

    func seek(at time: Double) {
        player.seek(to: time)
    }

    
    func setPan(pan:Float){
        unitSampler.pan = pan
    }
    
    func setPitch(pitch:Float){
        pitchControl.pitch = pitch * 100
    }
    
    func addNode(_ node: AVAudioNode) {
        player.attach(node: node)
    }

    func removeNode(_ node: AVAudioNode) {
       player.detach(node: node)
    }
    
 
    
    
    func setPlaybackRate(playbackRate: Float) {
        speedControl.rate = playbackRate
    }
    
   
    
    private func startDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(tick))
        displayLink?.preferredFramesPerSecond = 6
        displayLink?.add(to: .current, forMode: .common)
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
        reference.onPlayerStateChanged(playerId: playerId, state: newState)
    }

    func audioPlayerDidFinishPlaying(player _: AudioPlayer,
                                     entryId _: AudioEntryId,
                                     stopReason _: AudioPlayerStopReason,
                                     progress _: Double,
                                     duration _: Double)
    {
        print("audioPlayerDidFinishPlaying")
        reload()
      

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



