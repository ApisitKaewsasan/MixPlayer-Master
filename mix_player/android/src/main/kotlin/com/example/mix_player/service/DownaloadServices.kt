package com.example.mix_player.service

import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.Download
import com.example.mix_player.models.DownloadStatus
import com.example.mix_player.urils.Helper

class DownaloadServices(var reference: MixPlayerPlugin, var requestUrl: List<String>) {
    var activeDownloads = HashMap<String,Download>()
    var currentRequestLoop = 0
    init {
        reference.onDownLoadTaskStream(DownloadStatus(requestUrl,emptyList<Download>(),0.0,0,false))

//        (0..requestUrl.size).forEach { i ->
//        }
        initItem()
    }

    private fun initItem(){
        requestUrl.forEachIndexed { index, s ->
            addItem(requestUrl[index],index)
            System.out.println("cccza001 ${requestUrl[index]}")
        }
    }

    private fun addItem(url: String, id:Int){
        activeDownloads[url] = Download(url)

        Helper.isReachable(url) {
            print("isReachable ${it}")
        }
    }
}