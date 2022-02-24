package com.example.mix_player.service

import android.annotation.SuppressLint
import android.content.Context
import android.os.AsyncTask
import android.os.Handler
import com.example.mix_player.MixPlayerPlugin
import com.example.mix_player.models.Download
import com.example.mix_player.models.DownloadState
import com.example.mix_player.models.DownloadStatus
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.rxkotlin.subscribeBy
import zlc.season.rxdownload4.delete
import zlc.season.rxdownload4.download
import java.io.*


class DownaloadServices(var reference: MixPlayerPlugin, var requestUrl: List<String>,var context: Context) {
    var activeDownloads = HashMap<String,Download>()
    var currentRequestLoop = 0
    init {
        reference.onDownLoadTaskStream(DownloadStatus(requestUrl,emptyList<Download>(),0.0,0,false))

//        (0..requestUrl.size).forEach { i ->
//        }
        initItem()
    }

    @SuppressLint("CheckResult")
    private fun initItem(){
        var listProgress =  DoubleArray(requestUrl.size) {0.0}
        var downloadList = List<Download>(requestUrl.size) {Download("","", DownloadState.start,true,0.0)}
        var downloadStatus = DownloadStatus(requestUrl,downloadList,0.0,0,false)


            requestUrl.forEachIndexed { index, s ->
                requestUrl[index].delete()
                downloadList[index].url = requestUrl[index]

                requestUrl[index].download()
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeBy(
                        onNext = { progress ->
                            //download progress
                            downloadList[index].progress = progress.downloadSize.toDouble()
                            listProgress[index] = progress.downloadSize.toDouble()

                            updateStatus(downloadStatus,listProgress)



                        },
                        onComplete = {
                            //download complete

                        },
                        onError = {
                            //download failed

                        }

                    )
//
            }






    }

    class doAsync(val handler: () -> Unit) : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            handler()
            return null
        }
    }



    fun updateStatus(downloadStatus: DownloadStatus, process:DoubleArray){

        var statusProgress = 0.0
        process.forEach {
            statusProgress+=it
        }

        downloadStatus.requestLoop = (downloadStatus.progress*100/(100/downloadStatus.requestUrl.size)).toInt()+1
        downloadStatus.progress = (statusProgress/downloadStatus.requestUrl.size)
       // System.out.println("request ${ downloadStatus.requestLoop}  ${downloadStatus.progress}")

        if(downloadStatus.requestLoop == requestUrl.size && downloadStatus.isFinish == false){
            System.out.println("onComplete -> ")
            downloadStatus.isFinish = true
        }
        reference.onDownLoadTaskStream(downloadStatus)




    }



}