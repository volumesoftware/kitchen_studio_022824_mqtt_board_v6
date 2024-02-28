class Ingredient {
  int? id;
  String? ingredientName;
  String? ingredientType;
  String? imageFilePath;
  String? stockLevel;
  double? coordinateX;
  double? coordinateY;
  double? coordinateZ;

  Ingredient(
      {this.id,
      this.ingredientName,
      this.ingredientType,
      this.imageFilePath,
      this.stockLevel,
      this.coordinateX,
      this.coordinateY,
      this.coordinateZ,
      });

  Ingredient.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    ingredientName = json['ingredient_name']==null? null: json['ingredient_name'] as String;
    ingredientType = json["ingredient_type"]==null? null: json["ingredient_type"] as String;
    imageFilePath =json["image_file_path"]==null? null: json["image_file_path"] as String;
    stockLevel = json["stock_level"]==null? null: json["stock_level"] as String;
    coordinateX = json["coordinate_x"] == null ? 0.0: json["coordinate_x"] as double;
    coordinateY = json["coordinate_y"] == null ? 0.0: json["coordinate_y"] as double;
    coordinateZ = json["coordinate_z"] == null ? 0.0: json["coordinate_z"] as double;
  }

  Map<String, dynamic> toJson(){
    return {
      'ingredient_name':ingredientName ,
      'ingredient_type': ingredientType,
      'image_file_path': imageFilePath,
      'stock_level': stockLevel,
      'coordinate_x': coordinateX,
      'coordinate_y': coordinateY,
      'coordinate_z': coordinateZ,
    };
  }

  static String tableName() {
    return 'Ingredient';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${Ingredient.tableName()};
    CREATE TABLE ${Ingredient.tableName()}(
        id INTEGER PRIMARY KEY,
        ingredient_name TEXT,
        ingredient_type TEXT,
        image_file_path TEXT,
        stock_level TEXT,
        coordinate_x FLOAT,
        coordinate_y FLOAT,
        coordinate_z FLOAT
    );
    ''';
  }
}
