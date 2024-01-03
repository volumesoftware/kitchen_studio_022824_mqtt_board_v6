import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class StirOperationWidget extends StatefulWidget {
  final StirOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const StirOperationWidget({
    Key? key,
    required this.operation, required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<StirOperationWidget> createState() => _StirOperationWidgetState();
}

class _StirOperationWidgetState extends State<StirOperationWidget> {
  StirOperation? operation;
  bool inEditMode = false;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _durationController;
  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _durationController = TextEditingController(text: "${operation?.duration}");
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
            "Stir",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [                          PopupMenuButton<String>(
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
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<String>>[
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
                      operation?.targetTemperature = double.tryParse(_targetTemperatureController!.text);
                      operation?.duration = int.tryParse(_durationController!.text);
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
