
import 'package:get/get.dart';
import 'package:mix_player/mix_player.dart';
import 'package:mix_player_example/pages/player.dart';

import '../pages/home.dart';
import '../pages/output_mixplayer.dart';
import 'binding/home_binding.dart';
import 'binding/output_binding.dart';

part 'app_routes.dart';
class AppPages {
  static const initial = Routes.home;
  static final routes = [
    GetPage(
        name: _Paths.home,
        page: () =>  const HomePage(),
      binding: HomeBinding(),

    ),
    GetPage(
      name: _Paths.player,
      page: () =>  const Player(),


    ),
    GetPage(
      name: _Paths.mixPlayer,
      page: () =>   const OutputMixPlayer(),
      binding: OutPutBinding()
    ),
  ];

}

