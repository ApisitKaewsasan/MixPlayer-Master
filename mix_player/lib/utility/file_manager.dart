


import 'dart:io';


class FileManager{

  static  Future<File>  _localFile(String pathfilename) async => File(pathfilename);

  static  Future<bool?> deleteFile(String filename) async {
    try {
      final file = await _localFile(filename);
      await file.delete();
    } catch (e) {
      return false;

    }
    return null;
  }


}