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
  State<AdvancedControlWidget> createState() =>
      _AdvancedControlWidgetState();
}

class _AdvancedControlWidgetState
    extends State<AdvancedControlWidget> {
  AdvancedOperation? operation;
  RecipeWidgetActions? recipeWidgetActions;
  bool inEditMode = false;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _durationController;
  TextEditingController? _tiltAngleController;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
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
            "Advanced Control",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list),
              onSelected: (String result) {
                switch (result) {
                  case 'delete':
                    recipeWidgetActions?.onDelete(operation!);
                    break;
                  case 'save preset':
                    recipeWidgetActions?.onPresetSave(operation!);
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
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _targetTemperatureController,
                        decoration: InputDecoration(
                            suffixText: "celsius",
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Target Temperature',
                            label: Text("Target Temperature")),
                      ),
                    )
                  : ListTile(
                      title: Text('Target Temperature'),
                      trailing: Text("${_targetTemperatureController?.text}"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _durationController,
                        decoration: InputDecoration(
                            suffixText: "seconds",
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Duration',
                            label: Text("Duration")),
                      ),
                    )
                  : ListTile(
                      title: Text('Duration'),
                      trailing: Text("${_durationController?.text}"),
                    ),
            ],
          ),
        ),
        bottomSheet: ButtonBar(
          children: [
            inEditMode
                ? FilledButton(
                    onPressed: () async {
                      setState(() {
                        inEditMode = false;
                      });
                    },
                    child: Text("Cancel"))
                : Row(),
            inEditMode
                ? FilledButton(
                    onPressed: () {
                      operation?.targetTemperature =
                          double.tryParse(_targetTemperatureController!.text);
                      recipeWidgetActions?.onValueUpdate(operation!);
                      setState(() {
                        inEditMode = false;
                      });
                    },
                    child: Text(
                      "Update",
                    ))
                : FilledButton(
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Text('Advanced Control Editor'),
                              content: AdvanceControlWidget(advancedOperation: operation!),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                ),
                              ],
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
