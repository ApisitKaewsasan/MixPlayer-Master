
enum SongExtension{
  Song,
  Click,
}
class RequestSong{
  final String url;
  final SongExtension songExtension;
  final String? tag;

  RequestSong({required this.url, required this.songExtension,this.tag});
}