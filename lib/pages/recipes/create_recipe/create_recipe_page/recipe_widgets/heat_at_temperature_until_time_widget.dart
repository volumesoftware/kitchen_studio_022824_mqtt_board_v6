import 'package:flutter/material.dart';

class HeatAtTemperatureUntilTimeWidget extends StatefulWidget {
  final int index;
  final Function(int idx, double targetTemperature, double duration) onValueUpdate;

  const HeatAtTemperatureUntilTimeWidget(
      {Key? key, required this.onValueUpdate, required this.index})
      : super(key: key);

  @override
  State<HeatAtTemperatureUntilTimeWidget> createState() =>
      _HeatAtTemperatureUntilTimeWidgetState();
}

class _HeatAtTemperatureUntilTimeWidgetState
    extends State<HeatAtTemperatureUntilTimeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Icon(
          Icons.thermostat_auto_outlined,
        ),
        title: Text(
          "Heat at Temperature, Until Time",
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
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: 'Duration',
                ),
              ),
            )
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
