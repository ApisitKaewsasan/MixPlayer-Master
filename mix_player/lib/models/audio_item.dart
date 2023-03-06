
import 'request_song.dart';

class AudioItem{
  final RequestSong url;
  final String? title;
  final String? albumTitle;
  final String? artist;
  final String? albumimageUrl;
  final double? skipInterval;
  final double? volume;
  final bool? enable_equalizer;
  final bool isLocalFile;
  final double speed;
  final double duration;
  final double pan;
  final double pitch;

  final List<double>? frequecy;

  AudioItem({required this.url,  this.title = "",  this.albumTitle = "",  this.artist = "",  this.albumimageUrl = "",  this.skipInterval = 10.0,this.volume = 100,this.enable_equalizer = false,this.isLocalFile = false,this.duration = 0.0,this.frequecy,this.speed = 1.0,this.pan = 0.0,this.pitch = 0.0});
}