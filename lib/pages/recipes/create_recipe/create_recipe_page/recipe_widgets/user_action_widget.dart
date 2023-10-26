import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/user_action_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class UserActionWidget extends StatefulWidget {
  final UserActionOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const UserActionWidget(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<UserActionWidget> createState() => _UserActionWidgetState();
}

class _UserActionWidgetState extends State<UserActionWidget> {
  UserActionOperation? operation;
  bool inEditMode = false;
  RecipeWidgetActions? recipeWidgetActions;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _titleController;
  TextEditingController? _messageController;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController = TextEditingController(text: "${operation?.targetTemperature}");
    _titleController = TextEditingController(text: "${operation?.title}");
    _messageController = TextEditingController(text: "${operation?.message}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            Icons.person_search_outlined,
          ),
          title: Text(
            "User Action",
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Title'),
                          hintText: 'Title',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Title'),
                      trailing: Text("${_titleController?.text}"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Message'),
                          hintText: 'Message',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Message'),
                      trailing: Text("${_messageController?.text}"),
                    )
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
                      operation?.targetTemperature = double.tryParse(_targetTemperatureController!.text);
                      operation?.title = _titleController!.text;
                      operation?.message = _messageController!.text;

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
