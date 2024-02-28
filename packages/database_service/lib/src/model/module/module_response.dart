
abstract class ModuleResponse {
  int? currentIndex;
  String? ipAddress;
  int? port;
  String? moduleName;
  String? type;
  String? group;
  double? v5;
  String? code;
  String? requestId;
  double? memoryUsage;
  int? currentLocalTime;
  int? localTimeMax;
  int? machineTime;
  String? lastError;

  //creation of device stats only allowed from the connectivity
  ModuleResponse(Map<String, dynamic> json) {
    ipAddress = json['ip'];
    port = json['port'];
    lastError = json['le'];
    moduleName = json['name'];
    type = json['type'];
    group = json['group'];
    v5 = json['v5'] == null ? 0.0 : json['v5'].toDouble();
    code = json['code'];
    requestId = json['rid'];
    memoryUsage = json['mem'] == null ? 0.0 : json['mem'].toDouble();
    currentIndex = json['ci'].toInt();
    currentLocalTime = json['clt'].toInt();
    localTimeMax = json['ltm'].toInt();
    machineTime = json['mt'].toInt();
    build(json);
  }

  void build(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    var map = {
      'ip': ipAddress,
      'c_i': currentIndex,
      'port': port,
      'name': moduleName,
      'type': type,
      'v5': v5,
      'code': code,
      'rid': requestId,
      'mem': memoryUsage,
      'clt': currentLocalTime,
      'ltm': localTimeMax,
      'mt': machineTime,
    };
    return map;
  }
}
