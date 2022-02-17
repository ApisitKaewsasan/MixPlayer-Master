

class PlaybackEventMessage {
  late double currentTime;
  late double duration;

  PlaybackEventMessage({
    required this.currentTime,
    required this.duration
  });

  PlaybackEventMessage.fromJson(Map<dynamic, dynamic> json) {
    currentTime = json['currentTime'] as double;
    duration = json['duration'] as double;
  }
}