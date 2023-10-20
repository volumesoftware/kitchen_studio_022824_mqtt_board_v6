import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/flip_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class FlipWidget extends StatefulWidget {
  final FlipOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const FlipWidget({
    Key? key,
    required this.operation,
    required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<FlipWidget> createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget> {
  FlipOperation? operation;
  bool inEditMode = false;

  TextEditingController? _targetTemperatureController;
  TextEditingController? _cycleController;
  TextEditingController? _intervalDelayController;
  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _intervalDelayController =
        TextEditingController(text: "${operation?.interval}");
    _cycleController = TextEditingController(text: "${operation?.cycle}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(Icons.flip_camera_android),
          title: Text(
            "Flip",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              child: Text("${operation!.currentIndex! + 1}"),
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
                          border: OutlineInputBorder(),
                          label: Text('Target Temperature'),
                          hintText: 'Target Temperature',
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
                        controller: _intervalDelayController,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Interval Delay',
                            label: Text("Interval Delay")),
                      ),
                    )
                  : ListTile(
                      title: Text('Interval Delay'),
                      trailing: Text("${_intervalDelayController?.text}"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _cycleController,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Cycle count',
                            label: Text("Cycle count")),
                      ),
                    )
                  : ListTile(
                      title: Text('Cycle Count'),
                      trailing: Text("${_cycleController?.text}"),
                    ),
            ],
          ),
        ),
        bottomSheet: ButtonBar(
          children: [
            ElevatedButton(
                onPressed: () {
                  recipeWidgetActions?.onDelete(operation!);
                },
                child: Text("Delete")),
            ElevatedButton(
                onPressed: () async {
                  recipeWidgetActions?.onTest(operation!);
                },
                child: Text("Run Test")),
            inEditMode
                ? FilledButton(
                    onPressed: () {
                      operation?.targetTemperature =
                          double.tryParse(_targetTemperatureController!.text);
                      operation?.cycle = int.tryParse(_cycleController!.text);
                      operation?.interval =
                          int.tryParse(_intervalDelayController!.text);
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
