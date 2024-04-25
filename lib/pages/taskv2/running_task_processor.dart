import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;

const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);

class RunningTaskProcessorWidget extends StatefulWidget {
  final RecipeProcessor recipeProcessor;

  const RunningTaskProcessorWidget({
    super.key,
    required this.recipeProcessor,
  });

  @override
  State<RunningTaskProcessorWidget> createState() => _RunningTaskProcessorWidgetState();
}

class _RunningTaskProcessorWidgetState extends State<RunningTaskProcessorWidget> {
  late RecipeProcessor _recipeProcessor;
  ScrollController _scrollController = ScrollController();
  late StreamSubscription<ModuleResponse> _stateChange;

  Color getColor(int index) {
    if (index == _recipeProcessor.getTaskProgress()?.progressIndex) {
      return inProgressColor;
    } else if (index < _recipeProcessor.getTaskProgress()!.progressIndex) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  @override
  void initState() {
    setState(() {
      _recipeProcessor = widget.recipeProcessor;
    });

    _stateChange = widget.recipeProcessor.hearBeat.listen((ModuleResponse stats) {
      scrollToIndex(widget.recipeProcessor.getTaskProgress()?.progressIndex ?? 0);
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _stateChange.cancel();
    super.dispose();
  }

  void scrollToIndex(int index) {
    _scrollController.animateTo(
      index * MediaQuery.of(context).size.width * 0.08, // Replace ITEM_WIDTH with your item's width
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Timeline.tileBuilder(
      controller: _scrollController,
      physics: const ScrollPhysics(),
      shrinkWrap: false,
      theme: TimelineThemeData(
        direction: Axis.horizontal,
        connectorTheme: const ConnectorThemeData(
          space: 30.0,
          thickness: 5.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: _recipeProcessor.getInstructionsLength(),
        connectionDirection: ConnectionDirection.before,
        // itemExtentBuilder: (_, __) {
        //   int operationLength = operationsLength();
        //   return (MediaQuery.of(context).size.width * 1) / operationLength;
        // },
        itemExtent: MediaQuery.of(context).size.width * 0.08,
        oppositeContentsBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Icon(
                IconData(_recipeProcessor.getFlattenedInstructions()[index]['icon_data']['code_point'], fontFamily: 'MaterialIcons') ?? Icons.question_mark,
                color: getColor(index),
                size: 45),
          );
        },
        contentsBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                Text(
                  "${_recipeProcessor.getFlattenedInstructions()[index]['request_id']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getColor(index),
                  ),
                ),
                _recipeProcessor.getFlattenedInstructions()[index]['request_id'] == InstructionCode.userAction
                    ? Text(
                        "${_recipeProcessor.getFlattenedInstructions()[index]['title']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getColor(index),
                        ),
                      )
                    : Row()
              ],
            ),
          );
        },
        indicatorBuilder: (_, index) {
          int operationLength = _recipeProcessor.getInstructionsLength();
          var color;
          var child;
          if (index == _recipeProcessor.getTaskProgress()?.progressIndex) {
            color = inProgressColor;
            child = const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          } else if (index < _recipeProcessor.getTaskProgress()!.progressIndex) {
            color = completeColor;
            child = const Icon(
              Icons.check,
              color: Colors.white,
              size: 15.0,
            );
          } else {
            color = todoColor;
          }

          if (index <= _recipeProcessor.getTaskProgress()!.progressIndex) {
            return Stack(
              children: [
                CustomPaint(
                  size: const Size(30.0, 30.0),
                  painter: _BezierPainter(
                    color: color,
                    drawStart: index > 0,
                    drawEnd: index < _recipeProcessor.getTaskProgress()!.progressIndex,
                  ),
                ),
                DotIndicator(
                  size: 30.0,
                  color: color,
                  child: child,
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                CustomPaint(
                  size: const Size(15.0, 15.0),
                  painter: _BezierPainter(
                    color: color,
                    drawEnd: index < operationLength - 1,
                  ),
                ),
                OutlinedDotIndicator(
                  borderWidth: 4.0,
                  color: color,
                ),
              ],
            );
          }
        },
        connectorBuilder: (_, index, type) {
          if (index > 0) {
            if (index == _recipeProcessor.getTaskProgress()!.progressIndex) {
              final prevColor = getColor(index - 1);
              final color = getColor(index);
              List<Color> gradientColors;
              if (type == ConnectorType.start) {
                gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
              } else {
                gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)!];
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
      ),
    );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
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
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius) // TODO connector start & gradient
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
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius, radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.drawStart != drawStart || oldDelegate.drawEnd != drawEnd;
  }
}
