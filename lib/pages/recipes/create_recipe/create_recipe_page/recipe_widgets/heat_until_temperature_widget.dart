import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class HeatUntilTemperatureWidget extends StatefulWidget {
  final HeatUntilTemperatureOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const HeatUntilTemperatureWidget(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<HeatUntilTemperatureWidget> createState() =>
      _HeatUntilTemperatureWidgetState();
}

class _HeatUntilTemperatureWidgetState
    extends State<HeatUntilTemperatureWidget> {
  HeatUntilTemperatureOperation? operation;
  bool inEditMode = false;
  RecipeWidgetActions? recipeWidgetActions;

  TextEditingController? _targetTemperatureController;
  TextEditingController? _tiltAngleController;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _tiltAngleController =
        TextEditingController(text: "${operation?.tiltAngleA}");
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
            "${widget.operation.presetName ?? 'Heat Until'}",
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
                          isDense: true,
                          suffixText: "celsius",
                          border: OutlineInputBorder(),
                          label: Text('Target Temperature'),
                          hintText: '230',
                        ),
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
                        controller: _tiltAngleController,
                        decoration: InputDecoration(
                          isDense: true,
                          suffixText: "degree",
                          border: OutlineInputBorder(),
                          label: Text('Tilt Angle'),
                          hintText: '45',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Tilt Angle'),
                      trailing: Text("${_tiltAngleController?.text}"),
                    )
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
                      operation?.tiltAngleA =double.tryParse(_tiltAngleController!.text);
                      recipeWidgetActions?.onValueUpdate(operation!);
                      setState(() {
                        inEditMode = false;
                      });
                    },
                    child: Text(
                      "Update",
                    ))
                : FilledButton(
                    onPressed: () => setState(() {
                          inEditMode = true;
                        }),
                    child: Text("Edit")),
          ],
        ));
  }
}
