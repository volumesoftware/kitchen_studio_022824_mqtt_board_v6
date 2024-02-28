class Recipe {
  int? id;
  String? recipeName;
  String? author;
  String? imageFilePath;
  String? typeHandler;
  double? estimatedTimeCompletion;
  double? rating;
  int? cookCount;
  int? portion;
  int? parentId;

  Recipe(
      {this.id,
      this.recipeName,
      this.author,
      this.imageFilePath,
      this.typeHandler,
      this.estimatedTimeCompletion,
      this.rating,
      this.cookCount,
      this.portion,
      this.parentId
      });

  Recipe.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    recipeName = json['recipe_name']==null? null: json['recipe_name'] as String;
    author = json["author"]==null? null: json["author"] as String;
    imageFilePath =json["image_file_path"]==null? null: json["image_file_path"] as String;
    typeHandler = json["type_handler"]==null? null: json["type_handler"] as String;
    estimatedTimeCompletion = json["estimated_time_completion"] == null? 0.0 : json["estimated_time_completion"] as double;
    rating = json["rating"] == null ? 0.0: json["rating"] as double;
    cookCount = json["cook_count"] == null? 0: json["cook_count"] as int;
    portion = json["portion"] == null? 0: json["portion"] as int;
    parentId = json["parent_id"] == null? 0: json["parent_id"] as int;
  }

  Map<String, dynamic> toJson(){
    return {
          'recipe_name':recipeName ,
          'image_file_path': imageFilePath,
          'type_handler': typeHandler,
          'author': author,
          'estimated_time_completion': estimatedTimeCompletion,
          'rating': rating,
          'cook_count': cookCount,
          'portion': portion,
          'parent_id': parentId
    };
  }


  static String tableName() {
    return 'Recipe';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${Recipe.tableName()};
    CREATE TABLE ${Recipe.tableName()}(
        id INTEGER PRIMARY KEY,
        recipe_name TEXT,
        image_file_path TEXT,
        type_handler TEXT,
        author TEXT,
        estimated_time_completion FLOAT,
        rating FLOAT,
        cook_count INTEGER,
        portion INTEGER,
        parent_id INTEGER
    );
    ''';
  }
}
