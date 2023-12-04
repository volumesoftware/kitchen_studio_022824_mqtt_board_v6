import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/wash_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class WashWidget extends StatefulWidget {
  final WashOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const WashWidget({
    Key? key,
    required this.operation, required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<WashWidget> createState() => _WashWidgetState();
}

class _WashWidgetState extends State<WashWidget> {
  WashOperation? operation;
  bool inEditMode = false;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _durationController;
  TextEditingController? _cycleController;
  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController = TextEditingController(text: "${operation?.targetTemperature}");
    _durationController = TextEditingController(text: "${operation?.duration}");
    _cycleController = TextEditingController(text: "${operation?.cycle}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            Icons.waves_sharp,
          ),
          title: Text(
            "Wash",
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
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _cycleController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text("Cycle"),
                          hintText: 'Cycle',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Cycle'),
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
                      operation?.duration =
                          int.tryParse(_durationController!.text);
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
        ));
  }
}
