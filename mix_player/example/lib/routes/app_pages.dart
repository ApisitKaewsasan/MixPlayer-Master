
import 'package:get/get.dart';
import 'package:mix_player_example/player.dart';

import '../home.dart';
import '../main.dart';
import 'binding/home_binding.dart';

part 'app_routes.dart';
class AppPages {
  static const initial = Routes.home;
  static final routes = [
    GetPage(
        name: _Paths.home,
        page: () =>  HomePage(),
      binding: HomeBinding(),

    ),
    GetPage(
      name: _Paths.player,
      page: () =>  Player(),


    ),
  ];

}

