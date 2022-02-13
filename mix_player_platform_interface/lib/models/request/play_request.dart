


import '../../utils.dart';

class PlayRequest {
  late String url;
  late bool? isLocal;
  late double volume;
  // final AudioLoadConfigurationMessage? audioLoadConfiguration;

  PlayRequest(this.url,{ this.isLocal, required this.volume});

  Map<dynamic, dynamic> toMap() => <dynamic, dynamic>{
    'url': url,
    'isLocal': isLocal ?? isLocalUrl(url),
    'volume': volume,
    // 'audioLoadConfiguration': audioLoadConfiguration?.toMap(),
  };
}