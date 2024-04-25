// Flutter package imports
import 'package:flutter/material.dart';

/// Gauge imports
import 'package:syncfusion_flutter_gauges/gauges.dart';

class VolumeControl extends StatefulWidget {

  final double volume;
  final ValueChanged valueChanged;
  final Color color;

  const VolumeControl({Key? key, required this.volume, required this.valueChanged, required this.color}) : super(key: key);

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double _level = 150;
  final double _minimumLevel = 0;
  final double _maximumLevel = 1000;

 late TextEditingController _volumeController;

 @override
  void initState() {
   _volumeController = TextEditingController(text: '${widget.volume}');
    super.initState();
  }


  Widget _test(){
   return Container(
     decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(10),
         border: Border.all(color: Colors.black26, style: BorderStyle.solid)),
     child: Stack(
       children: [
         Positioned(
           child: Container(
             alignment: Alignment.center,
             width: MediaQuery.of(context).size.width >= 1000 ? 550 : 440,
             height: 350,
             child: _buildWaterIndicator(context),
           ), top: 25, left: 10, right: 10,bottom: 0,),
         Positioned(child: Text("Volume", textAlign: TextAlign.center,), top: 5, right: 5, left: 5,),
       ],
     ),
   );
  }

  @override
  Widget build(BuildContext context) {
    return _test();
  }

  /// Returns the water indicator.
  Widget _buildWaterIndicator(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Padding(
        padding: const EdgeInsets.all(10),
        child: SfLinearGauge(
          minimum: _minimumLevel,
          maximum: _maximumLevel,
          orientation: LinearGaugeOrientation.vertical,
          interval: 100,
          axisTrackStyle: const LinearAxisTrackStyle(
            thickness: 2,
          ),
          markerPointers: <LinearMarkerPointer>[
            LinearWidgetPointer(
              value: _level,
              enableAnimation: false,
              onChanged: (dynamic value) {
                setState(() {
                  _level = double.tryParse(((value) as double).toStringAsFixed(0)) ?? 0/0.0;
                  _volumeController.text = _level.toStringAsFixed(0);
                });
              },
              child: Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.blue,
                child: Ink(
                  width: 32.0,
                  height: 32.0,
                  child: InkWell(
                    splashColor: Colors.grey,
                    hoverColor: Colors.blueAccent,
                    onTap: () {},
                    child: Center(
                      child: _level == _minimumLevel
                          ? Icon(Icons.keyboard_arrow_up_outlined,
                              color: Colors.white, size: 20)
                          : _level == _maximumLevel
                              ? Icon(Icons.keyboard_arrow_down_outlined,
                                  color: Colors.white, size: 20)
                              : RotatedBox(
                                  quarterTurns: 3,
                                  child: Icon(Icons.code_outlined,
                                      color: Colors.white, size: 20)),
                    ),
                  ),
                ),
              ),
            ),
            LinearWidgetPointer(
              value: _level,
              enableAnimation: false,
              markerAlignment: LinearMarkerAlignment.end,
              offset: 20,
              position: LinearElementPosition.outside,
              child: SizedBox(
                  width: 100,
                  height: 20,
                  child: Center(
                      child: TextFormField(

                        onChanged: (value) {
                          setState(() {
                            _level = double.tryParse(value) ?? 0.0;
                          });
                        },
                        decoration: InputDecoration(
                          suffix: Text("ml"),
                          border: UnderlineInputBorder()
                        ),
                        controller: _volumeController,
                  ))),
            )
          ],
          barPointers: <LinearBarPointer>[
            LinearBarPointer(
              value: _maximumLevel,
              enableAnimation: false,
              thickness: 250,
              offset: 18,
              position: LinearElementPosition.outside,
              color: Colors.transparent,
              child: CustomPaint(
                  painter: _CustomPathPainter(
                      color: widget.color,
                      waterLevel: _level,
                      maximumPoint: _maximumLevel)),
            )
          ],
        ));
  }
}

class _CustomPathPainter extends CustomPainter {
  _CustomPathPainter(
      {required this.color,
      required this.waterLevel,
      required this.maximumPoint});

  final Color color;
  final double waterLevel;
  final double maximumPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildTumblerPath(size.width, size.height);
    final double factor = size.height / maximumPoint;
    final double height = 2 * factor * waterLevel;
    final Paint strokePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint paint = Paint()..color = color;
    canvas.drawPath(path, strokePaint);
    final Rect clipper = Rect.fromCenter(
        center: Offset(size.width / 2, size.height),
        height: height,
        width: size.width);
    canvas.clipRect(clipper);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CustomPathPainter oldDelegate) => true;
}

Path _buildTumblerPath(double width, double height) {
  return Path()
    ..lineTo(width, 0)
    ..lineTo(width * 0.75, height - 15)
    ..quadraticBezierTo(width * 0.74, height, width * 0.67, height)
    ..lineTo(width * 0.33, height)
    ..quadraticBezierTo(width * 0.26, height, width * 0.25, height - 15)
    ..close();
}
