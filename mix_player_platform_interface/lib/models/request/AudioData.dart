


import '../../utils.dart';

class AudioData {
  final String playerId;
  final String url;
  final String title;
  final String albumTitle;
  final String artist;
  final String albumimageUrl;
  final double skipInterval;
  final double volume;
  final double speed;
  final bool enable_equalizer;
  final List<double> frequecy;
  final bool? isLocalFile;
  final double pan;
  final double pitch;

  AudioData({required this.playerId,required this.url, required this.title, required this.albumTitle, required this.artist, required this.albumimageUrl,required this.volume ,required this.skipInterval,required this.enable_equalizer,required this.frequecy, this.isLocalFile,this.speed = 1.0,this.pan = 0.0,this.pitch=0.0});

  Map<dynamic, dynamic> toMap() => <dynamic, dynamic>{
    'playerId': playerId,
    'url': url,
    'title': title,
    'albumTitle': albumTitle,
    'artist': artist,
    'albumimageUrl': albumimageUrl,
    'skipInterval': skipInterval,
    'volume': volume,
    'enable_equalizer':enable_equalizer,
    'frequecy': frequecy,
    'isLocalFile':isLocalFile,
    'speed':speed,
    'pan':pan,
    'pitch':pitch

   // 'audioLoadConfiguration': audioLoadConfiguration?.toMap(),
  };
}