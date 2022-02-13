//
//  Download.swift
//  AudioStreaming
//
//  Created by Dotsocket on 2/7/22.
//

import Foundation

class Download {
    var url: String
    var localUrl:String = ""
    var downloadState: DownloadState = .none
    var isDownloading: Bool = false
    var progress: Double = 0.0
    var resumeData: Data?
    var sessionTask: URLSessionDownloadTask?


    init(url: String) {
        self.url = url
    }
    
}


class DownloadStatus{
    var requestUrl: [String]
    var download: [Download]
    var progress: Double = 0.0
    var requestLoop:Int = 0
    var isFinish : Bool = false
    
    init(requestUrl: [String],download:[Download],progress: Double,requestLoop:Int,isFinish : Bool){
        self.requestUrl = requestUrl
        self.download = download
        self.progress = progress
        self.requestLoop = requestLoop
        self.isFinish = isFinish
    }
 

    
    func convertObjectToJson()->String{
        var json = "{"
        json.append("\"requestUrl\":[")
        for var i in 0..<self.requestUrl.count {
            json.append("\"\(self.requestUrl[i])\"")
            if(i<(self.requestUrl.count-1)){
                json.append(",")
            }
        }
        json.append("],")
        json.append("\"download\":[")
        for var i in 0..<self.download.count {
            json.append("{\"url\":\"\(self.download[i].url)\",\"localUrl\":\"\(self.download[i].localUrl)\",\"progress\":\(self.download[i].progress),\"downloadState\":\"\(self.download[i].downloadState)\"}")
            if(i<(self.download.count-1)){
                json.append(",")
            }
        }
        json.append("],")
        json.append("\"progress\":\(self.progress),")
        json.append("\"requestLoop\":\(self.requestLoop),")
        json.append("\"isFinish\":\(self.isFinish)")
        json.append("}")

        return json
    }
}





enum DownloadState {
    case none
    case start
    case pause
    case resume
    case cancel
    case finish
    case error
    case alreadyDownloaded

    var isOngoing: Bool {
        return self == .start || self == .resume
    }


}


