import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import '../inputs_widgets/input_widget.dart';

class ValueEditorDialog extends StatefulWidget {
  final BaseOperation operation;
  final Map<String, dynamic> json;
  final ValueChanged<Map<String, dynamic>> valueChanged;

  const ValueEditorDialog(
      {Key? key, required this.operation,
        required this.json,
        required this.valueChanged})
      : super(key: key);

  @override
  State<ValueEditorDialog> createState() => _ValueEditorDialogState();
}

class _ValueEditorDialogState extends State<ValueEditorDialog> {
  late Map<String, dynamic> jsonData;

  double temperatureValue = 0.0;
  double temperatureTextSize = 18;

  late TextEditingController _titleController;
  late TextEditingController _messageController;

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  @override
  void initState() {
    // TODO: implement initState
    jsonData = widget.json;
    _titleController =
        TextEditingController(text: "${jsonData['title'] ?? ''}");
    _messageController =
        TextEditingController(text: "${jsonData['message'] ?? ''}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: (jsonData.containsKey('message') ||
              jsonData.containsKey('title') ||
              jsonData.containsKey("duration"))
          ? MediaQuery.of(context).size.height * 0.8
          : MediaQuery.of(context).size.height * 0.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _key,
        body: Center(
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                  flex: 5,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      jsonData.containsKey("target_temperature")
                          ? Expanded(
                              flex: 1,
                              child: RadialThermometerControls(
                                targetTemperature:
                                    jsonData['target_temperature'] as double,
                                valueChanged: (value) {
                                  setState(() {
                                    jsonData['target_temperature'] = value;
                                  });
                                },
                              ),
                            )
                          : Row(),
                      SizedBox(
                        width: 5,
                      ),
                      jsonData.containsKey("tilt_speed")
                          ? Expanded(
                              flex: 1,
                              child: TiltMotorAngleControls(
                                angleA: jsonData['tilt_angle_a'],
                                angleB: jsonData['tilt_angle_b'],
                                valueChanged: (TiltMotorAngle value) {},
                              ),
                            )
                          : Row(),
                      // SizedBox(width: 250,child: TiltMotorAngleControls(),),
                      SizedBox(
                        width: 5,
                      ),
                      jsonData.containsKey("rotate_angle")
                          ? Expanded(
                              flex: 1,
                              child: RotateMotorAngleControls(
                                angle: jsonData['rotate_angle'] ?? 0.0,
                                valueChanged: (value) {
                                  setState(() {
                                    jsonData['rotate_angle'] = value;
                                  });
                                },
                              ),
                            )
                          : Row(),
                      // SizedBox(width: 250,child: RotateMotorAngleControls(),),
                      // TimerControl(),
                      SizedBox(
                        width: 5,
                      ),
                      jsonData.containsKey("cycle")
                          ? Expanded(
                              flex: 1,
                              child: NumberPicker(),
                            )
                          : Row(),
                      SizedBox(
                        width: 5,
                      ),
                      jsonData.containsKey("volume")
                          ? Expanded(
                              flex: 1,
                              child: VolumeControl(
                                volume: jsonData['volume'],
                                valueChanged: (value) {
                                  jsonData['volume'] = value;
                                }, color: widget.operation is PumpOilOperation ? Colors.orangeAccent : Colors.blueAccent,
                              ),
                            )
                          : Row(),
                      // NumberPicker(),
                    ],
                  )),
              SizedBox(
                height: 5,
              ),
              (jsonData.containsKey('message') ||
                      jsonData.containsKey('title') ||
                      jsonData.containsKey("duration"))
                  ? Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          jsonData.containsKey("duration")
                              ? Expanded(
                                  flex: 3,
                                  child: TimerControl(),
                                )
                              : Row(),
                          SizedBox(
                            height: 20,
                          ),
                          jsonData.containsKey('title')
                              ? TextFormField(
                                  controller: _titleController,
                                  onChanged: (value) {
                                    jsonData['title'] = value;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Title"),
                                )
                              : Row(),
                          SizedBox(
                            height: 20,
                          ),
                          jsonData.containsKey('message')
                              ? TextFormField(
                                  controller: _messageController,
                                  onChanged: (value) {
                                    jsonData['message'] = value;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Message"),
                                  minLines: 4,
                                  maxLines: 10,
                                )
                              : Row(),
                        ],
                      ))
                  : Row(),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel")),
            SizedBox(
              width: 20,
            ),
            FilledButton(
                onPressed: () {
                  widget.valueChanged(jsonData);
                },
                child: Text("Ok"))
          ],
        ),
      ),
    );
  }
}
