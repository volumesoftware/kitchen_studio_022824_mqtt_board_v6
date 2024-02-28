import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/form_formatter/float_input_formatter.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/form_formatter/number_input_formatter.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';
import '../form_formatter/custom_input_formatter.dart';
class DispenseWidget extends StatefulWidget {
  final DispenseOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const DispenseWidget(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<DispenseWidget> createState() => _DispenseWidgetState();
}

class _DispenseWidgetState extends State<DispenseWidget> {
  DispenseOperation? operation;
  bool inEditMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  bool _showed = false;

  TextEditingController? _targetTemperatureController;
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
    _cycleController = TextEditingController(text: "${operation?.cycle}");

    _tiltAngleA = TextEditingController(text: "${operation?.tiltAngleA}");
    _tiltAngleB = TextEditingController(text: "${operation?.tiltAngleB}");
    _rotateAngle = TextEditingController(text: "${operation?.rotateAngle}");

    _scrollController.addListener(() {
      print(_scrollController.position.userScrollDirection);
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
                      operation?.targetTemperature =double.tryParse(_targetTemperatureController!.text);
                      operation?.cycle = int.tryParse(_cycleController!.text);

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
          "${widget.operation.presetName ?? 'Dispense'}",
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              inEditMode
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  inputFormatters: [FloatInputFormatter()],
                  controller: _targetTemperatureController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    suffixText: "celsius",
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
                  inputFormatters: [NumberInputFormatter()],
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
              inEditMode
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  inputFormatters: [FloatInputFormatter()],
                  controller: _tiltAngleA,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    label: Text("Sideway tilt angle"),
                    hintText: '45',
                  ),
                ),
              )
                  : ListTile(
                title: Text('Sideway tilt angle'),
                trailing: Text("${_tiltAngleA?.text}°"),
              ),
              inEditMode
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  inputFormatters: [FloatInputFormatter()],
                  controller: _tiltAngleB,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    label: Text("Drop tilt angle"),
                    hintText: '45',
                  ),
                ),
              )
                  : ListTile(
                title: Text('Drop tilt angle'),
                trailing: Text("${_tiltAngleB?.text}°"),
              ),
              inEditMode
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  inputFormatters: [FloatInputFormatter()],
                  controller: _rotateAngle,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    label: Text("Flat rotate angle"),
                    hintText: '45',
                  ),
                ),
              )
                  : ListTile(
                title: Text('Flat rotate angle'),
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
