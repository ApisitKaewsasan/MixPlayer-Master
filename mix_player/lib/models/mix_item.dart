

class MixItem{

  late List<String> request;
  late double reverbConfig;
  late double speedConfig;
  late double panConfig;
  late double pitchConfig;
  late List<double> frequencyConfig;
  late List<double> gainConfig;
  late List<double> panPlayerConfig;
  late List<double> volumeConfig;
  late String extension;
   String? outputPath;
   String? fileName;



   MixItem({required  this.request,required this.reverbConfig,required  this.speedConfig,required  this.panConfig,required this.pitchConfig,
     required this.frequencyConfig,required this.gainConfig,required this.panPlayerConfig,required this.volumeConfig,required this.extension, this.outputPath,this.fileName}){

   }
}