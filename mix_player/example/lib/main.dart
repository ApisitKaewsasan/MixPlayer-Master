import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player/mix_service.dart';
import 'package:mix_player/models/PlaybackEventMessage.dart';
import 'package:mix_player/models/download_task.dart';
import 'package:mix_player/models/player_state.dart';
import 'package:mix_player/models/request_song.dart';
import 'package:mix_player_example/viewmodel/player_data.dart';
import 'package:mix_player_example/widget/SeekBar.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'controller/player_controller.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(GetMaterialApp(
    initialRoute: AppPages.initial,
    getPages: AppPages.routes,
  ));
}


