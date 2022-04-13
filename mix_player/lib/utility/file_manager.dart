


import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/filemanager_task.dart';

class FileManager{
  static Future<FileManagerTask> createFolder({String newFolder="MIXAUDIO",String extensionFile="mp3",String fileName="audio_mixer_output"}) async {
    var outputPath = "";
    var time = DateTime.now();
    if(Platform.isAndroid){
      outputPath = "/storage/emulated/0/Music/$newFolder/${fileName}_${time.day}${time.month}${time.year}${time.second}_mix.${extensionFile.toLowerCase()}";
    }else if(Platform.isIOS){
      outputPath = "";
    }

    if (await Permission.storage.request().isGranted) {
      final dir = Directory('/storage/emulated/0/Music/$newFolder');

      if ((await dir.exists())) {

        //dir.path;
        deleteFile(outputPath);
      } else {
        dir.create();
        // dir.path;
      }
      return FileManagerTask(isSuccess: true,outputFile: outputPath);
    }
    return FileManagerTask(isSuccess: false,message: "No permission to access the storage file . Setting->App->permission request access");
  }

  static  Future<File>  _localFile(String pathfilename) async => File(pathfilename);

  static  Future<bool?> deleteFile(String filename) async {
    try {
      final file = await _localFile(filename);
      await file.delete();
    } catch (e) {
      return false;

    }
  }


}