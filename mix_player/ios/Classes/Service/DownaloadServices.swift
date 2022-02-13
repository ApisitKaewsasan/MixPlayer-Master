//
//  DownaloadServices.swift
//  AudioStreaming
//
//  Created by Dotsocket on 2/7/22.
//

import Foundation
import UIKit

class DownaloadServices:NSObject {

   

    var urlSession: URLSession = URLSession(configuration: .default)
    var activeDownloads: [URL: Download] = [:]
    var currentRequestLoop = 0
    
    var reference : SwiftMixPlayerPlugin
    var requestUrl : [String]
    
        lazy var downloadsSession: URLSession = {
          let configuration = URLSessionConfiguration.background(withIdentifier:
            "com.raywenderlich.HalfTunes.bgSession")
          return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }()
    
    
    init(result : SwiftMixPlayerPlugin,requestUrl : [String]){
        self.reference = result
        self.requestUrl = requestUrl
        super.init()
        
        
        reference.onDownLoadTaskStream(download: DownloadStatus(
          requestUrl: requestUrl, download: [], progress: 0.0, requestLoop: 0, isFinish: false
        ))
        DispatchQueue(label: "sync").sync {
            for var i in 0..<requestUrl.count {
                let theURL = URL(string: requestUrl[i])!.lastPathComponent
                clearCachesAudio(fileName:theURL)
            }
        }
        
        
        DispatchQueue(label: "sync").sync {
            self.initItem()
        }
      
       
    }
    
   func initItem(){
      
        urlSession = downloadsSession
      
      

                for var i in 0..<self.requestUrl.count {
                    addItem(with:  self.requestUrl[i],id: i)
                }
        
        
                     for var i in 0..<self.requestUrl.count {
//                         if let url = URL(string: self.requestUrl[i]), let destinationURL = localFilePath(for: url) {
//                             if isFileExist(destinationPath: destinationURL.path) {
//                                 let download = activeDownloads[URL(string:  self.requestUrl[i])!]
//                                 download?.downloadState = .finish
//                                 download?.localUrl = "\(destinationURL)"
//
//                                 download?.progress = 1.0
//                                 currentRequestLoopUpdate()
//                                 updatedownloadStatusItem()
//                               //  print("this song can play")
//                             } else {
//                                 isReachable(url: self.requestUrl[i]) { [self] Bool in
//                                     if(Bool){
//                                         start(with: self.requestUrl[i], downloadState: DownloadState.start)
//                                      //   print("this song is not in your local directory. need to download")
//                                     }else{
//                                         let download = activeDownloads[URL(string:  self.requestUrl[i])!]
//                                         download?.downloadState = .finish
//                                         download?.localUrl = "\(destinationURL)"
//                                         download?.progress = 1.0
//                                         currentRequestLoopUpdate()
//                                         updatedownloadStatusItem()
//                                      //   print("this song can play")
//                                     }
//                                 }
//
//                             }
//                         }
                         start(with: self.requestUrl[i], downloadState: DownloadState.start)
                        
                     }
    }
    
    
    func currentRequestLoopUpdate(){
        currentRequestLoop = currentRequestLoop + 1
    }
    


  


    func cancelTask(with url: String, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: url)!] else { return }

        download.sessionTask?.cancel()
        download.isDownloading = false
        activeDownloads[URL(string: url)!] = nil
        download.downloadState = downloadState
    }

    func pauseTask(with url: String, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: url)!], download.isDownloading else { return }
        download.sessionTask?.cancel(byProducingResumeData: { (data) in
            download.resumeData = data
        })
        download.downloadState = downloadState
        download.isDownloading = false
    }

    func resumeTask(with url: String, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: url)!] else { return }


        if let resumeData = download.resumeData {
            download.sessionTask = urlSession.downloadTask(withResumeData: resumeData)
        } else {
            download.sessionTask = urlSession.downloadTask(with: URL(string: url)!)
        }

        download.downloadState = downloadState
        download.sessionTask?.resume()
        download.isDownloading = true


    }
    
    func addItem(with url: String,id:Int){
        let download = Download(url: url)
        if let url = URL(string: url)  {
            activeDownloads[url] = download
        }
    }
    
    func isReachable(url:String,completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "HEAD"
            URLSession.shared.dataTask(with: request) { _, response, _ in
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }.resume()
        }


    func start(with url: String, downloadState: DownloadState) {
        //let download = Download(url: url)
        guard let download = self.activeDownloads[URL(string: url)!] else { return }
        download.isDownloading = true
        download.downloadState = downloadState
        download.sessionTask = urlSession.downloadTask(with: URL(string: url)!)
        
        download.sessionTask?.resume()
        
//        download.dowloadState = downloadState
//        download.isDownloading = true
//        if let url = URL(string: url)  {
//            activeDownloads[url] = download
//        }
    }

}

extension DownaloadServices: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Task has been resumed")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let sourceUrl = downloadTask.originalRequest?.url else {
            return
        }

        let download = activeDownloads[sourceUrl]
        guard let destinationURL = localFilePath(for: sourceUrl) else { return }

        do {
          
           try FileManager.default.copyItem(at: location, to: destinationURL)
            download?.localUrl = "\(destinationURL)"
            
            download?.downloadState = DownloadState.finish
            

        } catch let error {
            download?.downloadState = .error
            print("Error test -> \(error.localizedDescription)")
        }
        currentRequestLoopUpdate()
      updatedownloadStatusItem()

    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
      guard let url = downloadTask.originalRequest?.url,
        let download = activeDownloads[url]  else {
          return
      }
        //guard let index = self.requestUrl.firstIndex(where: {$0 == url.absoluteString}) else { return }
        download.progress = Double(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        updatedownloadStatusItem()
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {


        guard let sourceUrl = error?._userInfo?.value(forKey: "NSErrorFailingURLKey") else {
            return
        }
        let download = activeDownloads[URL(string: "\(sourceUrl)")!]
        download?.downloadState = .error

        currentRequestLoopUpdate()
        updatedownloadStatusItem()
    }

    func updatedownloadStatusItem(){
        var progress = 0.0
        var statusDownload = [Download]()
        for var i in 0..<self.requestUrl.count {
            var download = activeDownloads[URL(string: self.requestUrl[i])!]!
            progress =   progress + download.progress
            statusDownload.append(download)
         
            
     }
        
        print("request \(currentRequestLoop)/\(self.requestUrl.count) status  \((progress / Double(self.requestUrl.count))*100)")

        if(currentRequestLoop == self.requestUrl.count){
            //load()
           
            reference.onDownLoadTaskStream(download: DownloadStatus(requestUrl: requestUrl, download: statusDownload, progress:(progress / Double(self.requestUrl.count)), requestLoop: currentRequestLoop,isFinish: true))
            
            currentRequestLoop = 0
        }else{
            reference.onDownLoadTaskStream(download: DownloadStatus(requestUrl: requestUrl, download: statusDownload, progress: (progress / Double(self.requestUrl.count)), requestLoop: currentRequestLoop,isFinish: false))
        }
       
       
    }


}
