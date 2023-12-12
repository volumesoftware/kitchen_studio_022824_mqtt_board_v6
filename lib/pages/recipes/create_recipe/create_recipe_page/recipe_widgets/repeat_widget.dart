import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class RepeatWidget extends StatefulWidget {
  final RepeatOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const RepeatWidget(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<RepeatWidget> createState() => _RepeatWidgetState();
}

class _RepeatWidgetState extends State<RepeatWidget> {
  RepeatOperation? operation;
  bool inEditMode = false;
  RecipeWidgetActions? recipeWidgetActions;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _repeatIndexController;
  TextEditingController? _repeatCountController;
  bool isEnd = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _repeatCountController = TextEditingController(text: "${operation?.repeatCount}");
    _repeatIndexController = TextEditingController(text: "${operation?.repeatIndex}");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            isEnd ? Icons.stop_circle_outlined : Icons.person_search_outlined,
          ),
          title: Text(
            "Repeat Loop",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              child: Text("${widget.operation.currentIndex! + 1}"),
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
                        controller: _repeatIndexController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Repeat From Index'),
                          hintText: 'Repeat From Index',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Repeat From Index'),
                      subtitle: Text(
                        '${_repeatIndexController?.text}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _repeatCountController,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Repeat Count'),
                          hintText: 'Repeat Count',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Repeat Count'),
                      subtitle: Text('${_repeatCountController?.text}'),
                    )
            ],
          ),
        ),
        bottomSheet: isEnd
            ? SizedBox()
            : ButtonBar(
                children: [
                  inEditMode
                      ? FilledButton(
                          onPressed: () async {
                            setState(() {
                              inEditMode = false;
                              initialize();
                            });
                          },
                          child: Text("Cancel"))
                      : ElevatedButton(
                          onPressed: () {
                            recipeWidgetActions?.onDelete(operation!);
                          },
                          child: Text("Delete")),
                  inEditMode
                      ? FilledButton(
                          onPressed: () {
                            operation?.targetTemperature = double.tryParse(
                                _targetTemperatureController!.text);
                            operation?.repeatIndex = int.tryParse(_repeatIndexController!.text);
                            operation?.repeatCount = int.tryParse(_repeatCountController!.text);
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
