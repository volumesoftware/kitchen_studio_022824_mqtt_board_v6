import 'package:kitchen_studio_10162023/model/instruction.dart';

abstract interface class RecipeWidgetActions{

  void onDelete(BaseOperation operation);
  void onValueUpdate(BaseOperation operation);
  void onTest(BaseOperation operation);

}