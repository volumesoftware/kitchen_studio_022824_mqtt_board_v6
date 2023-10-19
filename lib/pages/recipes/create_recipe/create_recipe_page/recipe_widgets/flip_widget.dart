import 'package:flutter/material.dart';

class FlipWidget extends StatefulWidget {
  final int index;
  final Function(
          int idx, double targetTemperature, int intervalDelay, int cycle)
      onValueUpdate;

  const FlipWidget({Key? key, required this.onValueUpdate, required this.index})
      : super(key: key);

  @override
  State<FlipWidget> createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget> {
  bool inEditMode = false;

  final TextEditingController targetTemperatureController = TextEditingController();
  final TextEditingController cycleController = TextEditingController();
  final TextEditingController intervalDelayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(Icons.flip_camera_android),
          title: Text(
            "Flip",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              child: Text("${widget.index + 1}"),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  controller: targetTemperatureController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'Target Temperature',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  controller: intervalDelayController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'Interval Delay',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
                  controller: cycleController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'Cycle',
                  ),
                ),
              )
            ],
          ),
        ),
        bottomSheet: ButtonBar(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Delete")),
            FilledButton(
                onPressed: () {},
                child: Text(
                  "Update",
                )),
          ],
        ));
  }
}
