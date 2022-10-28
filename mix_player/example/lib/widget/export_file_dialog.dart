
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix_player/models/extension.dart';

class ExportFile extends StatelessWidget {

 final Function(FileExtension) onclick;

  const ExportFile({Key? key, required this.onclick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children:  [
              TextButton(onPressed: (){
                onclick.call(FileExtension.MP3);
              }, child: Text("MP3",style: GoogleFonts.kanit(color: Colors.black,fontSize: 16),)),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              TextButton(onPressed: (){
                onclick.call(FileExtension.M4A);
              }, child: Text("M4A",style: GoogleFonts.kanit(color: Colors.black,fontSize: 16),)),
              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              TextButton(onPressed: (){
                onclick.call(FileExtension.WAV);
              }, child: Text("WAV",style: GoogleFonts.kanit(color: Colors.black,fontSize: 16),)),
            ],
          ),
        ),
      ),
    );
  }
}
