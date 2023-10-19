import 'package:flutter/material.dart';

class HeatUntilTemperatureWidget extends StatefulWidget {

  final int index;
  final Function(int idx, double targetTemperature) onValueUpdate;

  const HeatUntilTemperatureWidget({Key? key, required this.onValueUpdate, required this.index})
      : super(key: key);

  @override
  State<HeatUntilTemperatureWidget> createState() =>
      _HeatUntilTemperatureWidgetState();
}

class _HeatUntilTemperatureWidgetState
    extends State<HeatUntilTemperatureWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Icon(
          Icons.thermostat,
        ),
        title: Text(
          "Heat Until Temperature",
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
            TextField(
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'Target Temperature',
              ),
            ),
          ],
        ),
      ),
        bottomSheet: ButtonBar(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Delete")),
            FilledButton(onPressed: () {}, child: Text("Update",)),
          ],
        )    );
  }
}
