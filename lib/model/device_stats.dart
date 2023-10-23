class DeviceStats {
  int? id;
  String? ipAddress;
  int? port;
  String? moduleName;
  String? type;
  String? group;
  double? v5;
  String? code;
  String? requestId;
  double? memoryUsage;
  double? progress;
  bool? waterValveOpen;
  bool? waterJetOpen;
  double? temperature1;
  double? temperature2;
  int? currentLocalTime;
  int? localTimeMax;
  int? machineTime;
  double? targetTemperature;
  int? instructionSize;

  List<double> temperatureArray = [];

  DeviceStats({this.id,
    this.ipAddress,
    this.port,
    this.moduleName,
    this.type,
    this.group,
    this.v5,
    this.code,
    this.requestId,
    this.memoryUsage,
    this.progress,
    this.waterValveOpen,
    this.waterJetOpen,
    this.temperature1,
    this.temperature2,
    this.currentLocalTime,
    this.localTimeMax,
    this.machineTime,
    this.targetTemperature,
    this.instructionSize
  });

  DeviceStats.fromJson(Map<String, dynamic> json) {
    instructionSize = json['instruction_size'];
    ipAddress = json['ip_address'];
    port = json['port'];
    moduleName = json['module_name'];
    type = json['type'];
    group = json['group'];
    v5 = json['v5'] == null ? 0.0 : json['v5'].toDouble();
    code = json['code'];
    requestId = json['request_id'];
    memoryUsage =
    json['memory_usage'] == null ? 0.0 : json['memory_usage'].toDouble();
    progress = json['progress'] == null ? 0.0 : json['progress'].toDouble();
    waterValveOpen = json['water_valve_open'] == 1 ? true : false;
    waterJetOpen = json['water_jet_open'] == 1 ? true : false;
    temperature1 = json['temperature_1'].toDouble();
    temperature2 = json['temperature_2'].toDouble();
    currentLocalTime = json['current_local_time'].toInt();
    localTimeMax = json['local_time_max'].toInt();
    machineTime = json['machine_time'].toInt();
    targetTemperature =
    json['target_temperature'] == null || json['target_temperature'] == 0
        ? 0.0
        : json['target_temperature']?.toDouble();

    temperatureArray = json['temperature_array'] == null
        ? []
        : json['temperature_array'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    return {
      'ip_address': ipAddress,
      'port': port,
      'module_name': moduleName,
      'type': type,
      'v5': v5,
      'code': code,
      'request_id': requestId,
      'memory_usage': memoryUsage,
      'progress': progress,
      'water_valve_open': waterValveOpen == true ? 1 : 0,
      'water_jet_open': waterJetOpen == true ? 1 : 0,
      'temperature_1': temperature1,
      'temperature_2': temperature2,
      'current_local_time': currentLocalTime,
      'local_time_max': localTimeMax,
      'machine_time': machineTime,
      'target_temperature': targetTemperature,
      'instruction_size': instructionSize
    };
  }

  DeviceStats.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    ipAddress = json['ip_address'] as String;
    port = json["port"] as int;
    moduleName = json["module_name"] as String;
    type = json["type"] as String;
    code = json["code"] as String;
    requestId = json["request_id"] as String;
    memoryUsage = json["memory_usage"] as double;
    progress = json["progress"] as double;
    waterValveOpen = json["water_valve_open"] == 1 ? true : false;
    waterJetOpen = json["water_jet_open"] == 1 ? true : false;

    temperature1 =
    json['temperature_1'] == null ? 0.0 : json['temperature_1'] as double;
    temperature2 =
    json['temperature_2'] == null ? 0.0 : json['temperature_2'] as double;
    currentLocalTime =
    json['current_local_time'] == null ? 0 : json['current_local_time'] as int;
    localTimeMax =
    json['local_time_max'] == null ? 0 : json['local_time_max'] as int;
    machineTime =
    json['machine_time'] == null ? 0 : json['machine_time'] as int;
    targetTemperature = json['target_temperature'] == null
        ? 0
        : json['target_temperature'] as double;
    instructionSize =
    json['instruction_size'] == null ? 0 : json['instruction_size'] as int;
  }

  static String tableName() {
    return 'DeviceStats';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${DeviceStats.tableName()};
    CREATE TABLE ${DeviceStats.tableName()}(
        id INTEGER PRIMARY KEY,
        ip_address TEXT,
        port INTEGER,
        module_name TEXT,
        type TEXT,
        v5 INTEGER,
        code TEXT,
        request_id TEXT,
        memory_usage FLOAT,
        progress FLOAT,
        water_valve_open BOOLEAN,
        water_jet_open BOOLEAN,
        temperature_1 FLOAT,
        temperature_2 FLOAT,
        current_local_time INTEGER,
        local_time_max INTEGER,
        machine_time INTEGER,
        target_temperature FLOAT,
        instruction_size INTEGER
    );
    ''';
  }
}
