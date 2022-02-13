


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
  final bool enable_equalizer;
  final List<double> frequecy;
  final bool? isLocalFile;

  AudioData({required this.playerId,required this.url, required this.title, required this.albumTitle, required this.artist, required this.albumimageUrl,required this.volume ,required this.skipInterval,required this.enable_equalizer,required this.frequecy, this.isLocalFile});

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
    'isLocalFile':isLocalFile

   // 'audioLoadConfiguration': audioLoadConfiguration?.toMap(),
  };
}