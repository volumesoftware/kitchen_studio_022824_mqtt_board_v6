class SystemSettings {
  int? id;
  String? key;
  String? label;
  String? value;

  SystemSettings({this.id, this.key, this.label, this.value});

  SystemSettings.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    key = json['key'] == null ? null : json['key'] as String;
    label = json['label'] == null ? null : json['label'] as String;
    value = json['value'] == null ? null : json['value'] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'value': value,
    };
  }

  Map<String, dynamic> toJsonApi() {
    return {
      'id' : id,
      'key': key,
      'label': label,
      'value': value,
    };
  }

  static String tableName() {
    return 'SystemSettings';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${SystemSettings.tableName()};
    CREATE TABLE ${SystemSettings.tableName()}(
        id INTEGER PRIMARY KEY,
        key TEXT,
        label TEXT,
        value TEXT
    );
    ''';
  }
}
