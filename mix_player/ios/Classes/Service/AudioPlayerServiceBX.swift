//
//  AudioPlayerService.swift
//  audio_player
//
//  Created by Dotsocket on 1/26/22.
//


//import AudioStreaming
//import Foundation
//import AVFoundation
//import SDDownloadManager
//
//
//class AudioPlayerService:NSObject{
//    var IsMuted = true
//    private var reference: SwiftAudioPlayerPlugin
//    var playState:AudioPlayerState = AudioPlayerState.stopped
//    var playerId: String
//    var audioItem: AudioItem?
//    private var audioSystemResetObserver: Any?
//    var notificationsHandler: NotificationsHandler? = nil
//    private var displayLink: CADisplayLink?
//
//    let speedControl = AVAudioUnitVarispeed()
//    let pitchControl = AVAudioUnitTimePitch()
//
//    let unitSampler =  AVAudioMixerNode()
//
//    var audioPlayer = [AVAudioPlayerNode]()
//    var mixernode = AVAudioMixerNode()
//    var engines = AVAudioEngine()
//
//
//
//    var equaliserService: EqualizerService? = nil
//
//    var objective = AudioRander()
//
//    var resultPath :String?
//
//
////
////
////    var itemplay = ["/Users/dotsocket/Desktop/songtest/vocals.mp3","/Users/dotsocket/Desktop/songtest/bass.mp3",
////                    "/Users/dotsocket/Desktop/songtest/drums.mp3","/Users/dotsocket/Desktop/songtest/other.mp3","/Users/dotsocket/Desktop/songtest/piano.mp3"]
//
////    var itemplay = ["https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview115//v4//bd//84//31//bd843169-11f8-adc6-7da1-0e744dc889f2//mzaf_9976382207184264032.plus.aac.p.m4a","https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview125//v4//ce//32//81//ce32816e-b9e8-e9a8-94bf-40e4f99e3596//mzaf_2990346819158497013.plus.aac.p.m4a",
////                    "https://audio-ssl.itunes.apple.com//itunes-assets//AudioPreview125//v4//bf//dc//a7//bfdca705-3502-a2ba-d4a6-31a34995f79f//mzaf_1275653087888885460.plus.aac.p.m4a","https://audio-ssl.itunes.apple.com//itunes-assets//Music6//v4//6a//81//f9//6a81f917-7bf5-1d40-6469-6eb40f774513//mzaf_3839953628687486964.plus.aac.p.m4a","https://audio-ssl.itunes.apple.com//itunes-assets//Music3//v4//ca//ca//1a//caca1a77-7a61-43b7-9907-a31871de0bc7//mzaf_3360273604681908658.plus.aac.p.m4a"]
//
//    var itemplay1 = [String]()
//
//    let downloadService = DownaloadServices.shared
//
//    var statusDownload = [Download]()
//
//    init(reference: SwiftAudioPlayerPlugin,playerId : String) {
//        self.reference = reference
//        self.playerId = playerId
//    }
//
//    func initData(audioItem:AudioItem){
//        self.audioItem = audioItem
//       // self.player.volume =   Float((0.01*audioItem.volume!))
//
//        self.configureAudioSession()
//        self.registerSessionEvents()
//
//        self.downloadService.urlSession = self.downloadsSession
//
//        for var i in 0..<self.audioItem!.url!.count {
//            let download = downloadService.addItem(with:  self.audioItem!.url![i],id: i)
//        }
//
//
//             for var i in 0..<self.audioItem!.url!.count {
//                 if let url = URL(string: self.audioItem!.url![i]), let destinationURL = downloadService.localFilePath(for: url) {
//                     if downloadService.isFileExist(destinationPath: destinationURL.path) {
//                         let download = downloadService.activeDownloads[URL(string:  self.audioItem!.url![i])!]
//                         download?.dowloadState = .finish
//                         download?.localUrl = destinationURL
//                         download?.progress = 1.0
//                         downloadService.currentRequestLoopUpdate()
//                         updatedownloadStatusItem()
//                       //  print("this song can play")
//                     } else {
//                         downloadService.isReachable(url: self.audioItem!.url![i]) { [self] Bool in
//                             if(Bool){
//                                 downloadService.start(with: self.audioItem!.url![i], downloadState: DownloadState.start)
//                              //   print("this song is not in your local directory. need to download")
//                             }else{
//                                 let download = downloadService.activeDownloads[URL(string:  self.audioItem!.url![i])!]
//                                 download?.dowloadState = .finish
//                                 download?.localUrl = destinationURL
//                                 download?.progress = 1.0
//                                 downloadService.currentRequestLoopUpdate()
//                                 updatedownloadStatusItem()
//                              //   print("this song can play")
//                             }
//                         }
//
//                     }
//                 }
//             }
//
//    }
//
//    //MARK: - Lazy Stored Properties
//    lazy var downloadsSession: URLSession = {
//      let configuration = URLSessionConfiguration.background(withIdentifier:
//        "com.raywenderlich.HalfTunes.bgSession")
//      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//    }()
//
//
//
//
//    func load() {
//
//        playState = AudioPlayerState.paused
//        activateAudioSession()
//
//
//        for var i in 0..<self.audioItem!.url!.count {
//            audioPlayer.append(AVAudioPlayerNode())
//            engines.attach(audioPlayer[i])
//        }
//
//        engines.attach(pitchControl)
//        engines.attach(mixernode)
//        engines.attach(speedControl)
//
//        for var i in 0..<self.audioItem!.url!.count {
//            do{
//                let download = downloadService.activeDownloads[URL(string: "\(self.audioItem!.url![i])")!]
//                let file = try AVAudioFile(forReading: (download?.localUrl)!)
//                audioPlayer[i].scheduleFile(file, at: nil){
//                    self.playState = .paused
//                    print("Did Finish \(i)")
//                }
//            } catch let error  {
//                print("AVAudioFile -> \(error)")
//            }
//            engines.connect(audioPlayer[i], to: mixernode, format: nil)
//
//        }
//
//        engines.connect(mixernode, to: speedControl, format: nil)
//        engines.connect(speedControl, to: pitchControl, format: nil)
//        engines.connect(pitchControl, to: engines.outputNode, format: nil)
//
//
//
//        do{
//           try  engines.start()
//
//        }
//        catch  let error {
//            playState = AudioPlayerState.error
//                print("Can't start engine")
//           }
//
//
//               // objective.configureAudioEngine(engine,playerNode: audioPlayer[0], fileUrl:file)
//
//
//    }
//
//
//
//    func stop() {
//        if(playState != AudioPlayerState.error){
//            playState = AudioPlayerState.stopped
//
//           // deactivateAudioSession()
//            for var i in 0..<self.audioItem!.url!.count {
//                audioPlayer[i].stop()
//
//            }
//        }
//
//    }
//
//    func pause() {
//        if(playState != AudioPlayerState.error){
//        playState = AudioPlayerState.paused
//        for var i in 0..<self.audioItem!.url!.count {
//            audioPlayer[i].pause()
//        }
//        }
//    }
//
//    func resume() {
//
//        playState = AudioPlayerState.playing
//        for var i in 0..<self.audioItem!.url!.count {
//            print("wefc \(playState)")
//            audioPlayer[i].play()
//        }
//    }
//
//    func toggleMute() {
//        if(IsMuted){
//            IsMuted = false
//            for var i in 0..<self.audioItem!.url!.count {
//                audioPlayer[i].volume = 0
//            }
//        }else{
//            IsMuted = true
//            for var i in 0..<self.audioItem!.url!.count {
//                audioPlayer[i].volume = 1
//            }
//        }
//    }
//
//    func update(rate: Float) {
//       // player.rate = rate
//    }
//
//    func toggle() {
//
//        if(playState != .error){
//            if(playState == .playing){
//             pause()
//        }else{
//         //   print("revre \(audioPlayer.count)")
//        resume()
//        }
//        }
//    }
//
//    func skipForward(time:Float){
////        let increase = self.player.progress + Double(time)
////        if increase < self.player.duration{
////            seek(at: Float(increase))
////        }
//
//    }
//
//    func skipBackward(time:Float){
////        let increase = self.player.progress - Double(time)
////        seek(at: Float(increase))
//    }
//
//    func updateVolume(volume:Float){
//        for var i in 0..<self.audioItem!.url!.count {
//            audioPlayer[i].volume = (0.01 * volume)
//        }
//    }
//
//    func seek(at time: Float) {
//       // player.seek(to: Double(time))
////        for var i in 0..<itemplay.count {
////            audioPlayer[i].seek
////        }
//    }
//
//
//    func setPan(pan:Float){
//        for var i in 0..<self.audioItem!.url!.count {
//            audioPlayer[i].pan = pan
//        }
//    }
//
//    func setPitch(pitch:Float){
//        pitchControl.pitch = pitch * 100
//    }
//
//    func addNode(_ node: AVAudioNode) {
//        //player.attach(node: node)
//    }
//
//    func removeNode(_ node: AVAudioNode) {
//       // player.detach(node: node)
//    }
//
//
//    func setPlaybackRate(playbackRate: Float) {
//        speedControl.rate = playbackRate
//    }
//
//     func recreatePlayer() {
//       // player = AudioPlayer(configuration: .init(enableLogs: true))
//        //player.delegate = self
//    }
//
//    private func startDisplayLink() {
//        displayLink?.invalidate()
//        displayLink = nil
//        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(tick))
//        displayLink?.preferredFramesPerSecond = 6
//        displayLink?.add(to: .current, forMode: .common)
//    }
//
//    private func stopDisplayLink() {
//        displayLink?.invalidate()
//        displayLink = nil
//
//    }
//
//    @objc private func tick() {
////        let duration = player.duration
////        let progress = player.progress
////
////
////        let elapsed = Int(progress)
////        let remaining = Int(duration - progress)
////        //print("ewfcewfc \(timeFrom(seconds: elapsed))     \(timeFrom(seconds: remaining))")
////        reference.playbackEventMessageStream(playerId: playerId, currentTime: progress, duration: duration)
//    }
//
//
//    private func timeFrom(seconds: Int) -> String {
//        let correctSeconds = seconds % 60
//        let minutes = (seconds / 60) % 60
//        let hours = seconds / 3600
//
//        if hours > 0 {
//            return String(format: "%02d:%02d:%02d", hours, minutes, correctSeconds)
//        }
//        return String(format: "%02d:%02d", minutes, correctSeconds)
//    }
//
//    private func registerSessionEvents() {
//        // Note that a real app might need to observer other AVAudioSession notifications as well
//        audioSystemResetObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification,
//                                                                          object: nil,
//                                                                          queue: nil) { [unowned self] _ in
//            self.configureAudioSession()
//            self.recreatePlayer()
//        }
//    }
//
//    private func configureAudioSession() {
//        do {
//            print("AudioSession category is AVAudioSessionCategoryPlayback")
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.1)
//        } catch let error as NSError {
//            print("Couldn't setup audio session category to Playback \(error.localizedDescription)")
//        }
//    }
//
//    private func activateAudioSession() {
//        do {
//            print("AudioSession is active")
//            try AVAudioSession.sharedInstance().setActive(true, options: [])
//
//        } catch let error as NSError {
//            print("Couldn't set audio session to active: \(error.localizedDescription)")
//        }
//    }
//
//    private func deactivateAudioSession() {
//        do {
//            print("AudioSession is deactivated")
//            try AVAudioSession.sharedInstance().setActive(false)
//        } catch let error as NSError {
//            print("Couldn't deactivate audio session: \(error.localizedDescription)")
//        }
//    }
//}
//
//extension AudioPlayerService: URLSessionDownloadDelegate {
//
//
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
//        print("Task has been resumed")
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//
//        guard let sourceUrl = downloadTask.originalRequest?.url else {
//            return
//        }
//
//        let download = downloadService.activeDownloads[sourceUrl]
//        guard let destinationURL = downloadService.localFilePath(for: sourceUrl) else { return }
//
//        do {
//           try FileManager.default.copyItem(at: location, to: destinationURL)
//            download?.localUrl = destinationURL
//            download?.dowloadState = DownloadState.finish
//            downloadService.currentRequestLoopUpdate()
//
//        } catch let error {
//            download?.dowloadState = .error
//            print("Error test -> \(error.localizedDescription)")
//        }
//      updatedownloadStatusItem()
//
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
//                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
//                    totalBytesExpectedToWrite: Int64) {
//      guard let url = downloadTask.originalRequest?.url,
//        let download = downloadService.activeDownloads[url]  else {
//          return
//      }
//        guard let index = self.audioItem!.url!.firstIndex(where: {$0 == url.absoluteString}) else { return }
//        download.progress = Double(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
//        updatedownloadStatusItem()
//    }
//
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//
//
//        guard let sourceUrl = error?._userInfo?.value(forKey: "NSErrorFailingURLKey") else {
//            return
//        }
//        let download = downloadService.activeDownloads[URL(string: "\(sourceUrl)")!]
//        download?.dowloadState = .error
//
//
//        updatedownloadStatusItem()
//    }
//
//    func updatedownloadStatusItem(){
//        var progress = 0.0
//        for var i in 0..<self.audioItem!.url!.count {
//            progress =   progress + downloadService.activeDownloads[URL(string: self.audioItem!.url![i])!]!.progress
//     }
//
//        print("request \(downloadService.currentRequestLoop)/\(self.audioItem!.url!.count) status  \((progress / Double(self.audioItem!.url!.count))*100)")
//
//        if(downloadService.currentRequestLoop == self.audioItem!.url!.count){
//            load()
//        }
//    }
//
//
//}
//
//
