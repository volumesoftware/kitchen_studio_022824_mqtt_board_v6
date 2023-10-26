abstract interface class BaseOperation {
  int? id;
  int? recipeId;
  int? operation;
  int? currentIndex;
  int? instructionSize;
  double? targetTemperature;
  String? requestId;

  BaseOperation(
      {this.id,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature});

  Map<String, dynamic> toJson();

  static String tableName() {
    return 'Operation';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${BaseOperation.tableName()};
    CREATE TABLE ${BaseOperation.tableName()}(
        id INTEGER PRIMARY KEY,
        request_id INTEGER,
        instruction_size INTEGER,
        recipe_id INTEGER,
        operation INTEGER,
        current_index INTEGER,
        target_temperature FLOAT,
        cycle INTEGER,
        interval INTEGER,
        duration INTEGER,
        message INTEGER,
        title INTEGER
    );
    ''';
  }
}
