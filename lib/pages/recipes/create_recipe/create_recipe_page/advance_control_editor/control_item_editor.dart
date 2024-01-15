import 'package:database_service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/form_formatter/float_input_formatter.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/form_formatter/number_input_formatter.dart';

class ControlItemEditor extends StatelessWidget {
  final VoidCallback onUpdateValue;
  final AdvancedOperationItem advancedOperationItem;
  final bool enabled;
  final AdvancedOperationItemDataAccess advancedOperationItemDataAccess =
      AdvancedOperationItemDataAccess.instance;

  final TextEditingController _valueController = TextEditingController();

  ControlItemEditor(
      {super.key,
      required this.advancedOperationItem,
      required this.enabled,
      required this.onUpdateValue}) {
    switch (advancedOperationItem.valueType ?? 0) {
      case OperationItemValueType.INTEGER:
        _valueController.text = "${advancedOperationItem.integerValue}";
        break;
      case OperationItemValueType.DOUBLE:
        _valueController.text = "${advancedOperationItem.doubleValue}";
        break;
      case OperationItemValueType.BOOLEAN:
        _valueController.text = "${advancedOperationItem.booleanValue}";
        break;
      case OperationItemValueType.STRING:
        _valueController.text = "${advancedOperationItem.stringValue}";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: advancedOperationItem.valueType == OperationItemValueType.NULL
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: Center(
                child: Text(
                  "${advancedOperationItem.operationItemCode.toString().split('.').last}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Text(
                  "${advancedOperationItem.operationItemCode.toString().split('.').last}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: TextField(
                    inputFormatters: [
                      getInputTypeFormatter()
                    ],
                    controller: _valueController,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            switch (advancedOperationItem.valueType ?? 0) {
                              case OperationItemValueType.INTEGER:
                                advancedOperationItem.integerValue =
                                    int.parse(_valueController.text);
                                break;
                              case OperationItemValueType.DOUBLE:
                                advancedOperationItem.doubleValue =
                                    double.parse(_valueController.text);
                                break;
                              case OperationItemValueType.BOOLEAN:
                                advancedOperationItem.booleanValue =
                                int.parse(_valueController.text) == 0
                                    ? false
                                    : true;
                                break;
                              case OperationItemValueType.STRING:
                                advancedOperationItem.stringValue =
                                    _valueController.text;
                                break;
                            }
                            await advancedOperationItemDataAccess.updateById(
                                advancedOperationItem.id!,
                                advancedOperationItem);
                          },
                        ),
                        suffixText: "${advancedOperationItem.label}",
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: '${advancedOperationItem.hint}',
                        label: Text("${advancedOperationItem.label}")),
                  ),
                )
              ],
            ),
    );
  }

  TextInputFormatter getInputTypeFormatter() {
    switch (advancedOperationItem.valueType ?? 0) {
      case OperationItemValueType.INTEGER:
        return NumberInputFormatter();
      case OperationItemValueType.DOUBLE:
        return FloatInputFormatter();
      case OperationItemValueType.BOOLEAN:
        return FilteringTextInputFormatter.deny("");
      case OperationItemValueType.STRING:
        return FilteringTextInputFormatter.deny("");
      default:
        return FilteringTextInputFormatter.deny("");
    }
  }
}
