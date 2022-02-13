

class PlaybackEventMessage {
  late String playerId;
  late double currentTime;
  late double duration;

  PlaybackEventMessage({
     required this.playerId,
     required this.currentTime,
     required this.duration
  });

  PlaybackEventMessage.fromJson(Map<dynamic, dynamic> json) {
    playerId = json['playerId'] as String;
    currentTime = json['currentTime'] as double;
    duration = json['duration'] as double;
  }
}