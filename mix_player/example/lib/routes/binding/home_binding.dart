
import 'package:get/get.dart';
import 'package:mix_player_example/controller/player_controller.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(PlayerController());
  }

}