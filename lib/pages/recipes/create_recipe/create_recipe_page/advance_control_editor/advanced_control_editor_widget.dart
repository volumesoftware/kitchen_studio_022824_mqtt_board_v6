import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/advance_control_editor/control_item_editor.dart';
import 'package:timelines/timelines.dart';

class AdvanceControlWidget extends StatefulWidget {
  final AdvancedOperation advancedOperation;

  const AdvanceControlWidget({Key? key, required this.advancedOperation})
      : super(key: key);

  @override
  State<AdvanceControlWidget> createState() => _AdvanceControlWidgetState();
}

const kTileHeight = 50.0;

const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);

class _AdvanceControlWidgetState extends State<AdvanceControlWidget> {
  late AdvancedOperation _advancedOperation;
  List<AdvancedOperationItem> _advancedOperationItems = [];
  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  AdvancedOperationItemDataAccess advancedOperationItemDataAccess =
      AdvancedOperationItemDataAccess.instance;
  int _currentEditIndex = 0;
  bool _requireUserPermission = false;

  @override
  void initState() {
    _advancedOperation = widget.advancedOperation;
    populateData();
    super.initState();
  }

  Future<void> populateData() async {
    var result = await baseOperationDataAccess.getById(_advancedOperation.id!);
    if (result != null) {
      setState(() {
        _advancedOperation = result as AdvancedOperation;
        _advancedOperationItems = _advancedOperation.controlItems;
      });
    }
  }

  Future<void> addToOperationItem(AdvancedOperationItem item) async {
    item.operationId = _advancedOperation.id!;
    await advancedOperationItemDataAccess.create(item);
    await populateData();
    setState(() {
      _currentEditIndex = _advancedOperationItems.length - 1;
    });
  }

  Future<void> deleteOperationItem(AdvancedOperationItem item) async {
    await advancedOperationItemDataAccess.delete(item.id!);
    populateData();
    setState(() {
      _currentEditIndex = _advancedOperationItems.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
              flex: 2,
              child: Container(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text("Tilt Motor"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Angle',
                            hint: '90',
                            operationItemCode:
                                OperationItemCodeEnum.TILT_MOTOR));
                      },
                    ),
                    ListTile(
                      title: Text("Rotation Motor"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Angle',
                            hint: '90',
                            operationItemCode:
                                OperationItemCodeEnum.ROTATING_MOTOR));
                      },
                    ),
                    ListTile(
                      title: Text("Bucket Motor"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Angle',
                            hint: '90',
                            operationItemCode:
                                OperationItemCodeEnum.BUCKET_MOTOR));
                      },
                    ),
                    ListTile(
                      title: Text("Wok Vibrator"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Repeat',
                            hint: '2',
                            operationItemCode:
                                OperationItemCodeEnum.WOK_VIBRATOR));
                      },
                    ),
                    ListTile(
                      title: Text("Oil Pump"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Duration',
                            hint: '10',
                            operationItemCode: OperationItemCodeEnum.OIL_PUMP));
                      },
                    ),
                    ListTile(
                      title: Text("Water Pump"),
                      onTap: () {
                        addToOperationItem(AdvancedOperationItem(
                            label: 'Duration',
                            hint: '10',
                            operationItemCode:
                                OperationItemCodeEnum.WATER_PUMP));
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text("Parameter"),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      child: TextField(
                        decoration: InputDecoration(
                            suffixText: "celsius",
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '100',
                            label: Text("Target Temperature")),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      child: TextField(
                        decoration: InputDecoration(
                            suffixText: "seconds",
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: '60',
                            label: Text("Timeout")),
                      ),
                    ),
                    _requireUserPermission
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 3, horizontal: 5),
                            child: TextField(
                              maxLines: 4,
                              minLines: 3,
                              decoration: InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  hintText: 'Attention',
                                  label: Text("message to user")),
                            ),
                          )
                        : SizedBox(),
                    ListTile(
                      title: Text("Require user permission?"),
                      trailing: Checkbox(
                        value: _requireUserPermission,
                        onChanged: (bool? value) {
                          setState(() {
                            _requireUserPermission =
                                value ?? _requireUserPermission;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Tilt speed"),
                      subtitle:
                          Text(getSpeedLabel(_advancedOperation.tiltSpeed)),
                      trailing: PopupMenuButton<int>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (int result) {
                          switch (result) {
                            case 0:
                              setState(() {
                                _advancedOperation.tiltSpeed = 0;
                              });
                              break;
                            case 1:
                              setState(() {
                                _advancedOperation.tiltSpeed = 1;
                              });
                              break;
                            case 2:
                              setState(() {
                                _advancedOperation.tiltSpeed = 2;
                              });
                              break;
                            case 3:
                              setState(() {
                                _advancedOperation.tiltSpeed = 3;
                              });
                              break;
                            case 4:
                              setState(() {
                                _advancedOperation.tiltSpeed = 4;
                              });
                              break;

                            default:
                              setState(() {
                                _advancedOperation.rotateSpeed = 0;
                              });
                          }
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
                    ListTile(
                      title: Text("Rotate speed"),
                      subtitle: Text(
                          "${getSpeedLabel(_advancedOperation?.rotateSpeed)}"),
                      trailing: PopupMenuButton<int>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (int result) {
                          switch (result) {
                            case 0:
                              setState(() {
                                _advancedOperation!.rotateSpeed = 0;
                              });
                              break;
                            case 1:
                              setState(() {
                                _advancedOperation!.rotateSpeed = 1;
                              });
                              break;
                            case 2:
                              setState(() {
                                _advancedOperation!.rotateSpeed = 2;
                              });
                              break;
                            case 3:
                              setState(() {
                                _advancedOperation!.rotateSpeed = 3;
                              });
                              break;
                            case 4:
                              setState(() {
                                _advancedOperation!.rotateSpeed = 4;
                              });
                              break;

                            default:
                              setState(() {
                                _advancedOperation?.rotateSpeed = 0;
                              });
                          }
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
                    SizedBox(height: 20,),
                    Divider(),
                    ElevatedButton(onPressed: () {
                      
                    }, child: Text("Save"))
                  ],
                ),
              )),
          Expanded(
              flex: 3,
              child: Timeline.tileBuilder(
                physics: const ScrollPhysics(),
                shrinkWrap: false,
                theme: TimelineThemeData(
                  direction: Axis.vertical,
                  connectorTheme: const ConnectorThemeData(
                    space: 30.0,
                    thickness: 5.0,
                  ),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemExtent: MediaQuery.of(context).size.height * 0.09,
                  oppositeContentsBuilder: (context, index) {
                    return ButtonBar(
                      children: [

                        IconButton(
                            onPressed: () {
                              deleteOperationItem(
                                  _advancedOperationItems[index]);
                            },
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ))
                      ],
                    );
                  },
                  contentsBuilder: (context, index) {
                    return ControlItemEditor(
                      onUpdateValue: (){
                        populateData();
                      },
                          enabled: _currentEditIndex == index,
                        advancedOperationItem: _advancedOperationItems[index]);
                  },
                  indicatorBuilder: (_, index) {
                    int operationLength = _advancedOperationItems.length;
                    var color;
                    var child;
                    color = inProgressColor;
                    child =                         CircleAvatar(
                      child: Text("${index + 1}"),
                      backgroundColor: inProgressColor,
                    );

                    return Stack(
                      children: [
                        CustomPaint(
                          size: const Size(30.0, 30.0),
                          painter: _BezierPainter(
                            color: color,
                            drawStart: index > 0,
                            drawEnd: index < _currentEditIndex,
                          ),
                        ),
                        DotIndicator(
                          size: 30.0,
                          color: color,
                          child: child,
                        ),
                      ],
                    );
                  },
                  connectorBuilder: (_, index, type) {
                    if (index > 0) {
                      if (index == _currentEditIndex) {
                        final prevColor = getColor(index - 1);
                        final color = getColor(index);
                        List<Color> gradientColors;
                        if (type == ConnectorType.start) {
                          gradientColors = [
                            Color.lerp(prevColor, color, 0.5)!,
                            color
                          ];
                        } else {
                          gradientColors = [
                            prevColor,
                            Color.lerp(prevColor, color, 0.5)!
                          ];
                        }
                        return DecoratedLineConnector(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                            ),
                          ),
                        );
                      } else {
                        return DashedLineConnector(
                          color: getColor(index),
                        );
                      }
                    } else {
                      return null;
                    }
                  },
                  itemCount: _advancedOperationItems.length,
                ),
              ))
        ],
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

  Color getColor(int index) {
    if (index == _currentEditIndex) {
      return inProgressColor;
    } else if (index < _currentEditIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
