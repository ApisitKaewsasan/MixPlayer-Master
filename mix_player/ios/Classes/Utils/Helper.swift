//
//  helper.swift
//  mix_player
//
//  Created by Dotsocket on 2/8/22.
//

import Foundation


func localFilePath(for url: URL) -> URL? {
    guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    return documentsPath.appendingPathComponent(url.lastPathComponent)
}


func isFileExist(destinationPath: String) -> Bool {
    
    return FileManager.default.fileExists(atPath: destinationPath)
}


func clearCachesDirectory(){
    let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
      } catch {
            return
     }
 }

func clearCachesAudio(fileName : String)->Bool{
    let fileManager = FileManager.default
    let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let filePath = docDir.appendingPathComponent(fileName)
    do {
        try FileManager.default.removeItem(at: filePath)
        print("File deleted")
        return true
    }
    catch {
        print("Error")
    }
    return false
}

func clearTmpDirectory(){
    var tmpDirectory: [String]? = nil
       do {
           tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
       } catch {
       }
       for file in tmpDirectory ?? [] {
           do {
               
               try FileManager.default.removeItem(atPath: "\(NSTemporaryDirectory())\(file)")
               
           } catch {
           }
       }
}

