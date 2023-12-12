import 'package:kitchen_module/kitchen_module.dart';
abstract interface class RecipeWidgetActions{

  void onDelete(BaseOperation operation);
  void onValueUpdate(BaseOperation operation);
  void onTest(BaseOperation operation);

}