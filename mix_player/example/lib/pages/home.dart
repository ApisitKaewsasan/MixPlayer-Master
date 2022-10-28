import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_player_example/controller/player_controller.dart';
import 'package:mix_player_example/routes/app_pages.dart';

class HomePage extends GetView<PlayerController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            ListTile(
              title: const Text(
                "Test Song", style: TextStyle(color: Colors.black),),
              onTap: () {
                Get.toNamed(Routes.player);
              },
            ),
            ListTile(
              title: const Text(
                "DisposePlayer", style: TextStyle(color: Colors.black),),
              onTap: () {
                if(controller.player!=null){
                  controller.player!.disposePlayer();
                }

              },
            )
          ],
        ),
      ),
    );
  }
}
