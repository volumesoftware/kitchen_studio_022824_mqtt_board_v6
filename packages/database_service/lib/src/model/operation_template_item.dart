class OperationTemplateItem {
  static const int CODE = 21230;

  int? id;
  int? operationTemplateId;
  int? deviceId; //1 vertical, 2 rotation, 3 tilting, 4 vibrator, 5 oil pump, 6 water pump
  int? argument; // angle, angle, angle, duration, duration, duration, duration


  OperationTemplateItem({this.id, this.operationTemplateId, this.deviceId, this.argument}){}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation_template_id'] = operationTemplateId;
    data['device_id'] = deviceId;
    data['argument'] = argument;
    return data;
  }

  OperationTemplateItem.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    operationTemplateId = json['operation_template_id'] as int;
    deviceId = json['device_id'] as int;
    argument = json['argument'] as int;
  }


  static String tableName() {
    return 'OperationTemplateItem';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${OperationTemplateItem.tableName()};
    CREATE TABLE ${OperationTemplateItem.tableName()}(
        id INTEGER PRIMARY KEY,
        operation_template_id INTEGER,
        device_id INTEGER,
        argument INTEGER
    );
    ''';
  }
}
