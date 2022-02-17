package com.example.mix_player.urils

import java.io.IOException
import java.net.HttpURLConnection
import java.net.MalformedURLException
import java.net.URL

class Helper {
    companion object{
        fun isReachable(urlString: String?,callback: (value: Boolean)-> Unit) {
            var connection: HttpURLConnection? = null
            try {
                val u = URL("http://www.google.com/")
                connection = u.openConnection() as HttpURLConnection
                connection!!.requestMethod = "HEAD"
                val code = connection.responseCode
                callback.invoke(code==200)
            } catch (e: MalformedURLException) {
                // TODO Auto-generated catch block
                callback.invoke(false)
                e.printStackTrace()
            } catch (e: IOException) {
                // TODO Auto-generated catch block
                e.printStackTrace()
                callback.invoke(false)
            } finally {
                connection?.disconnect()
            }
        }
    }
}