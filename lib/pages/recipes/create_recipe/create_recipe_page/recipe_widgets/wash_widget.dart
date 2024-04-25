import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';
import '../form_formatter/custom_input_formatter.dart';

class WashWidget extends StatefulWidget {
  final WashOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const WashWidget({
    Key? key,
    required this.operation,
    required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<WashWidget> createState() => _WashWidgetState();
}

class _WashWidgetState extends State<WashWidget> {
  WashOperation? operation;
  bool inEditMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  bool _showed = false;

  TextEditingController? _targetTemperatureController;
  TextEditingController? _durationController;
  TextEditingController? _cycleController;
  TextEditingController? _tiltAngleA;
  TextEditingController? _tiltAngleB;
  TextEditingController? _rotateAngle;

  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    _durationController = TextEditingController(text: "${operation?.duration}");
    _cycleController = TextEditingController(text: "${operation?.cycle}");

    _tiltAngleA = TextEditingController(text: "${operation?.tiltAngleA}");
    _tiltAngleB = TextEditingController(text: "${operation?.tiltAngleB}");
    _rotateAngle = TextEditingController(text: "${operation?.rotateAngle}");

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showed) {
          setState(() {
            _showed = true;
          });
          _scaffoldKey.currentState?.showBottomSheet((context) {
            return ButtonBar(
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
                          operation?.cycle =int.tryParse(_cycleController!.text);

                          operation?.tiltAngleA = double.tryParse(_tiltAngleA!.text);
                          operation?.tiltAngleB = double.tryParse(_tiltAngleB!.text);
                          operation?.rotateAngle =double.tryParse(_rotateAngle!.text);
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
            );
          });
        }
      } else {
        if (_showed) {
          setState(() {
            _showed = false;
            Navigator.of(context).pop();
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Container(
          child: Center(
            child: Text("${widget.operation.currentIndex! + 1}"),
          ),
        ),
        title: Text(
          "${widget.operation.presetName ?? 'Wash'}",
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _targetTemperatureController,
                          inputFormatters: [
                            FloatInputFormatter()
                          ],
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
                        inputFormatters: [
                          FloatInputFormatter()
                        ],
                        decoration: InputDecoration(
                            suffixText: "seconds",
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '3.0',
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
                        inputFormatters: [
                          NumberInputFormatter()
                        ],
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
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _tiltAngleA,
                        inputFormatters: [
                          FloatInputFormatter()
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text("Tilt Angle A"),
                          hintText: '45',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Tilt Angle A'),
                      trailing: Text("${_tiltAngleA?.text}°"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _tiltAngleB,
                        inputFormatters: [
                          FloatInputFormatter()
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text("Tilt Angle B"),
                          hintText: '45',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Tilt Angle B'),
                      trailing: Text("${_tiltAngleB?.text}°"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _rotateAngle,
                        inputFormatters: [
                          FloatInputFormatter()
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text("Rotate angle"),
                          hintText: '45',
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Rotate angle'),
                      trailing: Text("${_rotateAngle?.text}°"),
                    ),
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Text("Tilt speed"),
                        subtitle: Text("${getSpeedLabel(operation?.tiltSpeed)}"),
                        trailing: PopupMenuButton<int>(
                          icon: Icon(Icons.filter_list),
                          onSelected: (int result) {
                            switch (result) {
                              case 0:
                                setState(() {
                                  operation!.tiltSpeed = 0;
                                });
                                break;
                              case 1:
                                setState(() {
                                  operation!.tiltSpeed = 1;
                                });
                                break;
                              case 2:
                                setState(() {
                                  operation!.tiltSpeed = 2;
                                });
                                break;
                              case 3:
                                setState(() {
                                  operation!.tiltSpeed = 3;
                                });
                                break;
                              case 4:
                                setState(() {
                                  operation!.tiltSpeed = 4;
                                });
                                break;

                              default:
                                setState(() {
                                  operation?.rotateSpeed = 0;
                                });


                            }
                            recipeWidgetActions!.onValueUpdate(operation!);

                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<int>>[
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Text('Default Speed'),
                            ),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text('Speed 1'),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text('Speed 2'),
                            ),
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('Speed 3'),
                            ),
                            const PopupMenuItem<int>(
                              value: 4,
                              child: Text('Speed 4'),
                            )
                          ],
                        ),
                      ),
                    )
                  : ListTile(
                      title: Text('Tilt speed'),
                      trailing: Text("${getSpeedLabel(operation?.tiltSpeed)}"),
                    ),

              inEditMode
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  title: Text("Rotate speed"),
                  subtitle: Text("${getSpeedLabel(operation?.rotateSpeed)}"),
                  trailing: PopupMenuButton<int>(
                    icon: Icon(Icons.filter_list),
                    onSelected: (int result) {
                      switch (result) {
                        case 0:
                          setState(() {
                            operation!.rotateSpeed = 0;
                          });
                          break;
                        case 1:
                          setState(() {
                            operation!.rotateSpeed = 1;
                          });
                          break;
                        case 2:
                          setState(() {
                            operation!.rotateSpeed = 2;
                          });
                          break;
                        case 3:
                          setState(() {
                            operation!.rotateSpeed = 3;
                          });
                          break;
                        case 4:
                          setState(() {
                            operation!.rotateSpeed = 4;
                          });
                          break;

                        default:
                          setState(() {
                            operation?.rotateSpeed = 0;
                          });
                      }

                      recipeWidgetActions!.onValueUpdate(operation!);
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Default Speed'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Speed 1'),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text('Speed 2'),
                      ),
                      const PopupMenuItem<int>(
                        value: 3,
                        child: Text('Speed 3'),
                      ),
                      const PopupMenuItem<int>(
                        value: 4,
                        child: Text('Speed 4'),
                      )
                    ],
                  ),
                ),
              )
                  : ListTile(
                title: Text('Rotate speed'),
                trailing: Text("${getSpeedLabel(operation?.rotateSpeed)}"),
              )

            ],
          ),
        ),
      ),
    );
  }

  String getSpeedLabel(int? value) {
    switch (value) {
      case 0:
        {
          return "Default speed";
        }
      case 1:
        {
          return "Speed 1";
        }
      case 2:
        {
          return "Speed 2";
        }
      case 3:
        {
          return "Speed 3";
        }
      case 4:
        {
          return "Speed 4";
        }
    }

    return "Undefined Speed";
  }
}
