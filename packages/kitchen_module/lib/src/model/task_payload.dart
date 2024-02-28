import 'package:database_service/database_service.dart';

abstract class HandlerPayload {}

class IngredientHandlerPayload extends HandlerPayload {
  final IngredientItem ingredientItem;
  final double source;
  final double destination;

  IngredientHandlerPayload(this.ingredientItem, this.source, this.destination);


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['source'] = source; //get the item from source
    data['destination'] = destination; //bring the item to destination
    data['type'] = ingredientItem.ingredient?.ingredientType ?? "Not specified";
    data['quantity'] = ingredientItem.quantity;
    return data;
  }



}

class RecipeHandlerPayload extends HandlerPayload {
  final Recipe recipe;
  final List<BaseOperation> operations;
  final Task task;

  RecipeHandlerPayload(this.recipe, this.operations, this.task);
}
