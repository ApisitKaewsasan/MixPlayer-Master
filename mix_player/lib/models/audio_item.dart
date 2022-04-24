
import 'request_song.dart';

class AudioItem{
  final RequestSong url;
  final String title;
  final String albumTitle;
  final String artist;
  final String albumimageUrl;
  final double? skipInterval;
  final double? volume;
  final bool? enable_equalizer;
  final bool isLocalFile;
  final double duration;
  final List<double>? frequecy;

  AudioItem({required this.url, required this.title, required this.albumTitle, required this.artist, required this.albumimageUrl,  this.skipInterval = 10.0,this.volume = 100,this.enable_equalizer = false,this.isLocalFile = false,this.duration = 0.0,this.frequecy});
}