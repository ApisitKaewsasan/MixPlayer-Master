//
//  NotificationsHandler.swift
//  audio_player
//
//  Created by Dotsocket on 1/21/22.
//

import Foundation
import MediaPlayer

class NotificationsHandler {
    private let reference: AudioPlayerService
    
    #if os(iOS)
    private var infoCenter: MPNowPlayingInfoCenter? = nil
    private var remoteCommandCenter: MPRemoteCommandCenter? = nil
    #endif
  
  
    init(reference: AudioPlayerService) {
        self.reference = reference
        
    }
    
    func setupNotificationMedia(playbackRate:Double
    ) {
    
        self.infoCenter = MPNowPlayingInfoCenter.default()
   
//        clearNotification()
//
        UpdateCenterInfo(playbackRate:  playbackRate)
   
        
        if (remoteCommandCenter == nil) {
            
            remoteCommandCenter = MPRemoteCommandCenter.shared()
          
            remoteCommandCenter?.pauseCommand.isEnabled = true
            remoteCommandCenter?.pauseCommand.addTarget(handler: { MPRemoteCommandEvent in
                self.reference.toggle()
                return .success
            })
            remoteCommandCenter?.playCommand.isEnabled = true
            remoteCommandCenter?.playCommand.addTarget(handler: { MPRemoteCommandEvent in
                self.reference.toggle()
                return .success
            })
            remoteCommandCenter?.togglePlayPauseCommand.isEnabled = true
            remoteCommandCenter?.togglePlayPauseCommand.addTarget(handler: { MPRemoteCommandEvent in
                self.reference.toggle()
                return .success
            })
            remoteCommandCenter?.previousTrackCommand.isEnabled = false
            remoteCommandCenter?.nextTrackCommand.isEnabled = false
            
            remoteCommandCenter?.skipBackwardCommand.isEnabled = true
            remoteCommandCenter?.skipBackwardCommand.preferredIntervals = [reference.audioItem!.skipInterval! as NSNumber]
            remoteCommandCenter?.skipBackwardCommand.addTarget(handler: { MPRemoteCommandEvent in
                let interval = (MPRemoteCommandEvent as! MPSkipIntervalCommandEvent).interval
                self.reference.skipBackward(time: Float(interval))
                return .success
            })
            
           
            
            remoteCommandCenter?.skipForwardCommand.isEnabled = true
            remoteCommandCenter?.skipForwardCommand.preferredIntervals = [reference.audioItem!.skipInterval! as NSNumber]
            remoteCommandCenter?.skipForwardCommand.addTarget(handler: { MPRemoteCommandEvent in
                let interval = (MPRemoteCommandEvent as! MPSkipIntervalCommandEvent).interval
                self.reference.skipForward(time: Float(interval))
                return .success
            })
           
       
            
            if #available(iOS 9.1, *) {
                remoteCommandCenter?.changePlaybackPositionCommand.isEnabled = true
                
                remoteCommandCenter?.changePlaybackPositionCommand.addTarget(handler: { MPRemoteCommandEvent in
                 
                    if let changePlaybackPositionCommandEvent = MPRemoteCommandEvent as? MPChangePlaybackPositionCommandEvent
                        {
                        self.reference.seek(at: Double(changePlaybackPositionCommandEvent.positionTime))
                        }
                    return .success
                })
            }
        
        }
    }
    
    
    
    func clearNotification() {
        
        #if os(iOS)
        // Set both the nowPlayingInfo and infoCenter to nil so
        // we clear all the references to the notification
        self.infoCenter?.nowPlayingInfo = nil
        self.infoCenter = nil
        #endif
    }
    
    #if os(iOS)
    static func geneateImageFromUrl(urlString: String) -> UIImage? {
        if urlString.hasPrefix("http") {
            guard let url: URL = URL.init(string: urlString) else {
                Logger.error("Error download image url, invalid url %@", urlString)
                return nil
            }
            do {
                let data = try Data(contentsOf: url)
                return UIImage.init(data: data)
            } catch {
                Logger.error("Error download image url %@", error)
                return nil
            }
        } else {
            return UIImage.init(contentsOfFile: urlString)
        }
    }
    
    func UpdateCenterInfo(playbackRate: Double) {
       
        if (infoCenter == nil) {
            return
        }
   
        //Logger.info("Updating playing \(reference.player.duration)   elapsedTime \(reference.player.progress)")
        
        var playingInfo: [String: Any?] = [
            MPMediaItemPropertyTitle: reference.audioItem?.title,
            MPMediaItemPropertyAlbumTitle: reference.audioItem?.albumTitle,
            MPMediaItemPropertyArtist: reference.audioItem?.artist,
           // MPMediaItemPropertyPlaybackDuration: reference.player.duration,
            //MPNowPlayingInfoPropertyElapsedPlaybackTime: reference.progress,
            MPNowPlayingInfoPropertyPlaybackRate: Float(playbackRate)
            
            
        ]
        
        Logger.info("Updating playing info...")
        
        // fetch notification image in async fashion to avoid freezing UI
        DispatchQueue.global().async() { [weak self] in
            if let imageUrl = self!.reference.audioItem?.albumimageUrl {
                let artworkImage = NotificationsHandler.geneateImageFromUrl(urlString: imageUrl)
                if let artworkImage = artworkImage {
                    if #available(iOS 10, *) {
                        let albumArt = MPMediaItemArtwork.init(
                            boundsSize: artworkImage.size,
                            requestHandler: { (size) -> UIImage in
                                return artworkImage
                            }
                        )
                        playingInfo[MPMediaItemPropertyArtwork] = albumArt
                    } else {
                        let albumArt = MPMediaItemArtwork.init(image: artworkImage)
                        playingInfo[MPMediaItemPropertyArtwork] = albumArt
                    }
                    Logger.info("Will add custom album art")
                }
            }
            
            if let infoCenter = self?.infoCenter {
                let filteredMap = playingInfo.filter { $0.value != nil }.mapValues { $0! }
                Logger.info("Setting playing info: %@", filteredMap)
                infoCenter.nowPlayingInfo = filteredMap
                
            }
        }
    }

    #endif
}

