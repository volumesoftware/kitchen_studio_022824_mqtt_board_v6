import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class DropIngredientWidget extends StatefulWidget {
  final DropIngredientOperation operation;
  final RecipeWidgetActions recipeWidgetActions;


  const DropIngredientWidget({
    Key? key,
    required this.operation, required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<DropIngredientWidget> createState() => _DropIngredientWidgetState();
}

class _DropIngredientWidgetState extends State<DropIngredientWidget> {

  DropIngredientOperation? operation;
  bool inEditMode = false;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _cycleController;
  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _cycleController = TextEditingController(text: "${operation?.cycle}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Icon(
          Icons.publish_sharp,
        ),
        title: Text(
          "${widget.operation.presetName ?? 'Drop Ingredient'}",
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
                  suffixText: "celsius",
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
          inEditMode
              ? FilledButton(
              onPressed: () {
                operation?.targetTemperature =
                    double.tryParse(_targetTemperatureController!.text);
                operation?.cycle = int.tryParse(_cycleController!.text);
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
      ),
    );
  }
}
