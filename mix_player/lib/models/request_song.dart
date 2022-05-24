
enum SongExtension{
  Song,
  Click,
}
class RequestSong{
  final String url;
  final SongExtension songExtension;
  final String? tag;
  final double pan;
  final double pitch;
  final double speed;
  final double duration;

  RequestSong({required this.url, required this.songExtension,this.tag,this.pan = 0,this.pitch=0,this.speed=1.0,this.duration = 0});

  static SongExtension getRequestSong(String event) {
    if (event == 'SongExtension.Click') {
      return SongExtension.Click;
    } else {
      return SongExtension.Song;
    }
  }
}

