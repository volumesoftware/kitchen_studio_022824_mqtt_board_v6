// import 'dart:typed_data';
//
// class DeviceStats {
//   int? id;
//   int? currentIndex;
//   String? ipAddress;
//   int? port;
//   String? moduleName;
//   String? type;
//   String? group;
//   double? v5;
//   String? code;
//   String? requestId;
//   double? memoryUsage;
//   double? progress;
//   bool? oilValveOpen;
//   bool? waterValveOpen;
//   bool? waterJetOpen;
//   double? temperature;
//   int? currentLocalTime;
//   int? localTimeMax;
//   int? machineTime;
//   double? targetTemperature;
//   int? instructionSize;
//   double? rotaryMotorAngle;
//   double? tiltingMotorAngle;
//   String? lastError;
//
//   List<double> temperatureArray = [];
//
//   DeviceStats.fromJson(Map<String, dynamic> json) {
//     ipAddress = json['ip'];
//     port = json['port'];
//     lastError = json['le'];
//     moduleName = json['name'];
//     type = json['type'];
//     group = json['group'];
//     v5 = json['v5'] == null ? 0.0 : json['v5'].toDouble();
//     code = json['code'];
//     requestId = json['rid'];
//     memoryUsage = json['mem'] == null ? 0.0 : json['mem'].toDouble();
//     progress = json['prog'] == null ? 0.0 : json['prog'].toDouble();
//     currentIndex = json['ci'].toInt();
//     instructionSize = json['i_s'].toInt();
//     temperature = json['temp'] == null || json['temp'] == 0
//         ? 0.0
//         : json['temp']?.toDouble();
//     currentLocalTime = json['clt'].toInt();
//     localTimeMax = json['ltm'].toInt();
//     machineTime = json['mt'].toInt();
//     targetTemperature = json['ttemp'] == null || json['ttemp'] == 0
//         ? 0.0
//         : json['ttemp']?.toDouble();
//     oilValveOpen = json['ovo'] == 1 ? true : false;
//     waterValveOpen = json['wvo'] == 1 ? true : false;
//     waterJetOpen = json['wjo'] == 1 ? true : false;
//     rotaryMotorAngle = json['rmotor'] == null ? 0.0 : json['rmotor'].toDouble();
//     tiltingMotorAngle =
//         json['tmotor'] == null ? 0.0 : json['tmotor'].toDouble();
//   }
//
//   Map<String, dynamic> toJson() {
//     var map = {
//       'ip': ipAddress,
//       'c_i': currentIndex,
//       'port': port,
//       'name': moduleName,
//       'type': type,
//       'v5': v5,
//       'code': code,
//       'rid': requestId,
//       'mem': memoryUsage,
//       'prog': progress,
//       'wvo': waterValveOpen == true ? 1 : 0,
//       'wjo': waterJetOpen == true ? 1 : 0,
//       'temp': temperature,
//       'clt': currentLocalTime,
//       'ltm': localTimeMax,
//       'mt': machineTime,
//       'ttemp': targetTemperature,
//       'i_s': instructionSize,
//       'rmotor': rotaryMotorAngle,
//       'tmotor': tiltingMotorAngle,
//     };
//     // map.removeWhere((key, value) => value == null);
//
//     return map;
//   }
//
//   DeviceStats.fromDatabase(Map<String, Object?> json) {
//     id = json['id'] as int;
//     ipAddress = json['ip'] as String;
//     port = json["port"] as int;
//     moduleName = json["name"] as String;
//     type = json["type"] as String;
//     code = json["code"] as String;
//     requestId = json["rid"] as String;
//     memoryUsage = json["mem"] as double;
//     progress = json["prog"] as double;
//     waterValveOpen = json["wvo"] == 1 ? true : false;
//     waterJetOpen = json["wjo"] == 1 ? true : false;
//     temperature = json['temp'] == null ? 0.0 : json['temp'] as double;
//     currentLocalTime = json['clt'] == null ? 0 : json['clt'] as int;
//     localTimeMax = json['ltm'] == null ? 0 : json['ltm'] as int;
//     machineTime = json['mt'] == null ? 0 : json['mt'] as int;
//     targetTemperature = json['ttemp'] == null ? 0 : json['ttemp'] as double;
//     instructionSize = json['i_s'] == null ? 0 : json['i_s'] as int;
//     rotaryMotorAngle = json["rmotor"] as double;
//     tiltingMotorAngle = json["tmotor"] as double;
//   }
//
//   static String tableName() {
//     return 'DeviceStats';
//   }
//
//   static String dropCreateCommand() {
//     return '''
//     DROP TABLE IF EXISTS ${DeviceStats.tableName()};
//     CREATE TABLE ${DeviceStats.tableName()}(
//         id INTEGER PRIMARY KEY,
//         ip TEXT,
//         port INTEGER,
//         name TEXT,
//         type TEXT,
//         v5 INTEGER,
//         code TEXT,
//         rid TEXT,
//         mem FLOAT,
//         prog FLOAT,
//         wvo BOOLEAN,
//         wjo BOOLEAN,
//         temp FLOAT,
//         clt INTEGER,
//         ltm INTEGER,
//         mt INTEGER,
//         ttemp FLOAT,
//         i_s INTEGER,
//         c_i INTEGER,
//         rmotor FLOAT,
//         tmotor FLOAT
//
//     );
//     ''';
//   }
// }
