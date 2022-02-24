
 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mix_player/models/download_task.dart';

class PlayerData{
  late String songName;
  late String artist;
  late List<PlayerUrl> urlSong;
  late double duration;
  PlayerData({required this.songName,required this.artist, required this.urlSong,this.duration = 0.0});
 }

 class PlayerUrl{
   late String url;
   late String icon;
   late Download? download;

  PlayerUrl({required this.url,this.download, required this.icon});
 }

 PlayerData audioItem = PlayerData(songName: "Johnny Knox-I Like You[Demo]",artist: "Artist Name -- Alburm Name",urlSong: [
   PlayerUrl(url: "https://dev-api.muse-master.com/api/v1/files/songtest/vocals.mp3",icon: "assets/images/png/mic.png",download: Download()),
   // PlayerUrl(url: "https://dev-api.muse-master.com/api/v1/files/songtest/bass.mp3",icon: "assets/images/png/bass.png",download: Download()),
   // PlayerUrl(url: "https://dev-api.muse-master.com/api/v1/files/songtest/drums.mp3",icon: "assets/images/png/drums.png",download: Download()),
   // PlayerUrl(url: "https://dev-api.muse-master.com/api/v1/files/songtest/other.mp3",icon: "assets/images/png/orther.png",download: Download()),
   // PlayerUrl(url: "https://dev-api.muse-master.com/api/v1/files/songtest/piano.mp3",icon: "assets/images/png/piano.png",download: Download())
 ],duration: 182.88326530612244);

 // PlayerData audioItem = PlayerData(songName: "Johnny Knox-I Like You[Demo]",urlSong: [
 //   PlayerUrl(url: "https://cvws.icloud-content.com/B/AfSmYtENmJ1cRgDhDo96qGrMn9A6AXtGqhQuAJY4NtANZwzMmhQWpTn5/vocals.mp3?o=Apy6iP7aUIpBoSjabVD-kvjZGq4qxNr1AXT3o4oW-hRL&v=1&x=3&a=CAogilRMmtiMkCSVTZ_wyMBpPWCrAZrdXlDEraNUE1YWrHMSbRD1jtKL7y8YlYaJjO8vIgEAUgTMn9A6WgQWpTn5aibArfcTAzqR4qKUplTMLqLx0udlldO1zKrKgvoALyhRQFFodvsowXIm7j307vPmdrR3D41SdbXrHnHhhaqSrCRVmEjLmr8En6py7RgRJG0&e=1644729352&fl=&r=de0bab99-a4a3-46a7-81d2-b1082d6fbaa3-1&k=8ZwhVgE1uS3MDxw105UrOw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=35&s=XxNa1L1xnCWsADCCKyX_YeBvdK0&cd=i",icon: "assets/images/png/mic.png"),
 //   PlayerUrl(url: "https://cvws.icloud-content.com/B/AduVq3nBlDLd8V2Ev0DF0cWjmLfSAduVnb69uw_-HKAuFFoaacr_-hMg/bass.mp3?o=Au9VteIHfN1rSkwOsnhPSXG4N8oszr5cpHjC1Ocm1bUm&v=1&x=3&a=CAogG4i1fJ3OZi6x9lr70FWhwCqwFOKyni4-bPW6YAvjQ-8SbRCDk9OL7y8Yo4qKjO8vIgEAUgSjmLfSWgT_-hMgaiZCAk1JuEon_BjPuf-rrNp7xDfIMIjyy_quWwWDfpbxO94qH1MjP3ImxQrz-5zsfJNk0P3zTGBq93bs25Y0ILydqtjkuFqb-0DgdPg0RIM&e=1644729369&fl=&r=a6942825-3625-4741-946a-06a5bd0e8d65-1&k=gUAU5ZoN3g76YYzcQNxAtw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=35&s=VK7Rq9sRztKooyM5ZJX026sy3uM&cd=i",icon: "assets/images/png/bass.png"),
 //   PlayerUrl(url: "https://cvws.icloud-content.com/B/AWlN-kSmAxvEaems5t6-rk1bCK1-AdWgYSyHZ04v6mo1y82LXo7k_zTc/drums.mp3?o=As0dX97p25HjHl-o8bjmRHtzFtbsdy4pg97a_fRZZrjz&v=1&x=3&a=CAogq97tEog2km87rTkCTZO8Zjs7kxsc185JisMs0l75uZcSbRCL9NOL7y8Yq-uKjO8vIgEAUgRbCK1-WgTk_zTcaiaauoC_rJBf6j9JpBUOyDpknIGFfgR36C4ANh7t6PcS9zKVlb4C_3ImWmicTqPNobUCQNplSzsnzmMnrlBFB7V_aTt6LjWErsHjhq17B_Y&e=1644729382&fl=&r=d7048d41-c66d-4138-94d1-263907d92b46-1&k=KY0B3oQrJbtSsC60sRN6Lw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=35&s=bvQ0f0AMWxujhQZfzFAqv6sNu44&cd=i",icon: "assets/images/png/drums.png"),
 //   PlayerUrl(url: "https://cvws.icloud-content.com/B/AS5lUWit3DhkR1_1-K8XTjNi8wHsAVi9oPPJ6KQmXW9E6cKVCEzBoRBm/other.mp3?o=AskKCYIMpEjYVSpz5zcjvxlBbFz6aIaL3jOile3yeWsY&v=1&x=3&a=CAogUNPd8HgQaHPhnr4c1VCpN9zsufd6qP1HXLchaY7ajzwSbRDMx9SL7y8Y7L6LjO8vIgEAUgRi8wHsWgTBoRBmaiZ_tOleyQ-irGWoiUCpWG4ObPK5gV-MmVK8S1dCtv4pPmFLLXfK33ImdCXK2H6WrBVGkpzidenIMTmnDjPVt_EqWLIGWvNqnn_rNU1n1Nk&e=1644729393&fl=&r=dad1d2fe-c862-4b23-9081-2e6ada31048d-1&k=q4OM1Eg7nspA9OVm0KPTUw&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=35&s=_B4AengFCJmD80Eif-gSaxfQ_zU&cd=i",icon: "assets/images/png/orther.png"),
 //   PlayerUrl(url: "https://cvws.icloud-content.com/B/AWuD4DbY2icIJbDmTYN55xDDveCQAWiVwzCGH8hoU1kn19-Hz8gkEk-9/piano.mp3?o=AqJc7306QHQtFZvXlcraz-UWP1xbouvfmMBTl4igPcQQ&v=1&x=3&a=CAogarxSGvl6xp8lC1FW08W3NymO3Q2O1jQXPJsMZQ8mnCUSbRD5x9WL7y8Ymb-MjO8vIgEAUgTDveCQWgQkEk-9aiYxFy_oCdwkcm-alkQJMgJEUi1wDdBdT3CRgvRigkJMhSSRAnzskXImQRpfFfjmGSWCwao_hDbn2aOps8DFNiqFWpoifF-F3nReEXo1Vxk&e=1644729409&fl=&r=4cb48fd0-6605-4837-9ff1-addeb727bd07-1&k=DDRvvh5OyaH_WO8AeYtPMQ&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=35&s=dekpNtnk3FGILXnE65MPF1NdHvo&cd=i",icon: "assets/images/png/piano.png")
 //
 // ]);



