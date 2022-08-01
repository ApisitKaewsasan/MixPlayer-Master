
enum SongExtension{
  Song,
  Click,
}
class RequestSong{
  final String url;
  final String? tag;
  final double pan;
  final double pitch;
  final double speed;
  final double duration;

  RequestSong({required this.url,this.tag,this.pan = 0,this.pitch=0,this.speed=1.0,this.duration = 0});


}

