import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/advance_control_editor/advanced_control_editor_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class AdvancedControlWidget extends StatefulWidget {
  final AdvancedOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const AdvancedControlWidget(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<AdvancedControlWidget> createState() => _AdvancedControlWidgetState();
}

class _AdvancedControlWidgetState extends State<AdvancedControlWidget> {
  late AdvancedOperation operation;
  RecipeWidgetActions? recipeWidgetActions;
  bool inEditMode = false;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Container(
            child: Center(
              child: Text("${widget.operation.currentIndex! + 1}"),
            ),
          ),
          title: Text(
            "${operation.title ??  'Advanced Control Editor'}",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list),
              onSelected: (String result) async {
                switch (result) {
                  case 'delete':
                    recipeWidgetActions?.onDelete(operation);
                    break;
                  case 'save preset':
                    List<AdvancedOperationItem>? list =
                        await AdvancedOperationItemDataAccess.instance.search(
                            'operation_id = ?',
                            whereArgs: [operation.id!]);
                    recipeWidgetActions?.onPresetSave(operation, child: list);
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                const PopupMenuItem<String>(
                  value: 'save preset',
                  child: Text('Save as preset'),
                ),
              ],
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              ListTile(
                title: Text('Target Temperature'),
                trailing: Text("${operation.targetTemperature}"),
              ),
              ListTile(
                title: Text('Tilt Speed'),
                trailing: Text("${operation.tiltSpeed}"),
              ),
              ListTile(
                title: Text('Rotate Speed'),
                trailing: Text("${operation.rotateSpeed}"),
              )

            ],
          ),
        ),
        bottomSheet: ButtonBar(
          children: [
            FilledButton(
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          scrollable: true,
                          title:  Text('${operation.title ??  'Advanced Control Editor'}'),
                          content: AdvanceControlWidget(
                            advancedOperation: operation,
                            onSaved: (AdvancedOperation value) {
                              setState(() {
                                operation = value;
                              });
                              widget.recipeWidgetActions.onValueUpdate(operation);
                            },
                          ),
                        );
                      },
                    );

                    inEditMode = true;
                  });
                },
                child: Text("Edit")),
          ],
        ));
  }
}
