class Task{

  static const String CREATED = "Created";
  static const String STARTED = "Started";
  static const String COMPLETED = "Completed";

  int? id;
  int? recipeId;
  String? recipeName;
  String? taskName;
  String? moduleName;
  String? status;
  double? progress;

  Task(
      {this.id,
        this.recipeId,
        this.recipeName,
        this.taskName,
        this.moduleName,
        this.status,
        this.progress
      });

  Task.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    recipeName = json["recipe_name"]==null? null: json["recipe_name"] as String;
    taskName =json["task_name"]==null? null: json["task_name"] as String;
    moduleName = json["module_name"]==null? null: json["module_name"] as String;
    status = json["status"]==null? null: json["status"] as String;
    progress = json["progress"]==null? 0.0: json["progress"] as double;
  }

  Map<String, dynamic> toJson(){
    return {
      'recipe_id':recipeId ,
      'recipe_name': recipeName,
      'task_name': taskName,
      'module_name': moduleName,
      'status': status,
      'progress': progress,
    };
  }


  static String tableName() {
    return 'Task';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${Task.tableName()};
    CREATE TABLE ${Task.tableName()}(
        id INTEGER PRIMARY KEY,
        recipe_id INTEGER,
        recipe_name TEXT,
        task_name TEXT,
        module_name TEXT,
        status TEXT,
        progress FLOAT
    );
    ''';
  }


}