import 'package:database_service/database_service.dart';

class StirFryResponse extends ModuleResponse {
  double? progress;
  bool? oilValveOpen;
  bool? waterValveOpen;
  bool? waterJetOpen;
  double? temperature;
  double? targetTemperature;
  int? instructionSize;
  double? rotaryMotorAngle;
  double? tiltingMotorAngle;

  List<double> temperatureArray = [];

  StirFryResponse(super.json);

  @override
  void build(Map<String, dynamic> json) {
    progress = json['prog'] == null ? 0.0 : json['prog'].toDouble();
    targetTemperature = json['ttemp'] == null || json['ttemp'] == 0 ? 0.0 : json['ttemp']?.toDouble();
    oilValveOpen = json['ovo'] == 1 ? true : false;
    waterValveOpen = json['wvo'] == 1 ? true : false;
    waterJetOpen = json['wjo'] == 1 ? true : false;
    rotaryMotorAngle = json['rmotor'] == null ? 0.0 : json['rmotor'].toDouble();
    tiltingMotorAngle = json['tmotor'] == null ? 0.0 : json['tmotor'].toDouble();
    temperature = json['temp'] == null || json['temp'] == 0 ? 0.0 : json['temp']?.toDouble();
    instructionSize = json['i_s'].toInt();
  }
}
