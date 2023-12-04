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
    _titleController = TextEditingController(text: "${operation?.title}");
    _messageController = TextEditingController(text: "${operation?.message}");

    if (operation != null) {
      if (operation!.isClosing!) {
        setState(() {
          isEnd = true;
        });
      } else {
        setState(() {
          isEnd = false;
        });
      }
    }
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
            isEnd ? "Recipe's End" : "User Action",
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
                      subtitle: Text(
                        '"${_titleController?.text}"',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _messageController,
                        minLines: 4,
                        maxLines: 4,
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
                      subtitle: Text('"${_messageController?.text}"'),
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
