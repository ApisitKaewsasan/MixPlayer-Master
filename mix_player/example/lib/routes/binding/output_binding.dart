
import 'package:get/get.dart';
import 'package:mix_player_example/controller/mixplayer_controller.dart';
import 'package:mix_player_example/controller/player_controller.dart';

class OutPutBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(MixPlayerController());
  }

}