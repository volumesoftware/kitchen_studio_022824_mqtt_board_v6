class OperationTemplate {
  static const int CODE = 21200;

  int? id;
  String? templateName;
  double? targetTemperature;
  int? cycle;
  int? interval;
  int? timeout;
  String? message;
  bool? promptMessage;
  String? requestId = 'OperationTemplate';
  int? operation = OperationTemplate.CODE;

  OperationTemplate(
      {this.id,
      this.templateName,
      this.targetTemperature,
      this.cycle,
      this.interval,
      this.timeout,
      this.message,
      this.promptMessage,
      this.requestId,
      this.operation}) {
    requestId = templateName;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['template_name'] = templateName;
    data['target_temperature'] = targetTemperature;
    data['cycle'] = cycle;
    data['interval'] = interval;
    data['timeout'] = timeout;
    data['message'] = message;
    data['prompt_message'] = promptMessage;
    data['request_id'] = requestId;
    data['operation'] = operation;
    return data;
  }

  OperationTemplate.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    templateName =  json['template_name'] == null ? null : json['template_name'] as String;
    targetTemperature = json['target_temperature'] == null ? 0.0 : json['target_temperature'] as double;
    cycle=json['cycle'] == null ? 0 : json['cycle'] as int;
    interval=json['cycle'] == null ? 0 : json['cycle'] as int;
    timeout=json['cycle'] == null ? 0 : json['cycle'] as int;
    message =  json['message'] == null ? null : json['message'] as String;
    promptMessage = json["is_closing"] == 0 ? false : true;
    requestId = json['template_name'] == null ? null : json['template_name'] as String;
    operation = json['cycle'] == null ? 0 : json['cycle'] as int;
  }


  static String tableName() {
    return 'OperationTemplate';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${OperationTemplate.tableName()};
    CREATE TABLE ${OperationTemplate.tableName()}(
        id INTEGER PRIMARY KEY,
        template_name TEXT,
        target_temperature FLOAT,
        cycle INTEGER,
        interval INTEGER,
        timeout INTEGER,
        message TEXT,
        prompt_message BOOLEAN,
        request_id TEXT,
        operation INTEGER
    );
    ''';
  }
}
