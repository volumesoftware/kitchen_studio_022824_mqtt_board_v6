import 'package:flutter/material.dart';

class DispenseWidget extends StatefulWidget {
  final int index;
  final Function(int idx, double targetTemperature, int cycle) onValueUpdate;

  const DispenseWidget(
      {Key? key, required this.onValueUpdate, required this.index})
      : super(key: key);

  @override
  State<DispenseWidget> createState() => _DispenseWidgetState();
}

class _DispenseWidgetState extends State<DispenseWidget> {
  bool inEditMode = false;

  final TextEditingController targetTemperatureController =
      TextEditingController();
  final TextEditingController cycleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: Icon(
          Icons.account_tree_outlined,
        ),
        title: Text(
          "Dispense Widget",
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
              child: inEditMode
                  ? TextField(
                      controller: targetTemperatureController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: 'Target Temperature',
                      ),
                    )
                  : ListTile(
                      title: Text('Target Temperature'),
                      trailing: Text("120.00"),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: inEditMode
                  ? TextField(
                      controller: cycleController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        hintText: 'Cycle',
                      ),
                    )
                  : ListTile(
                      title: Text('Cycle'),
                      trailing: Text("120.00"),
                    ),
            )
          ],
        ),
      ),
      bottomSheet: ButtonBar(
        children: [
          ElevatedButton(onPressed: () {}, child: Text("Delete")),
          inEditMode
              ? FilledButton(
                  onPressed: () {
                    setState(() {
                      inEditMode = false;
                    });
                  },
                  child: Text(
                    "Update",
                  ))
              : FilledButton(
                  onPressed: () {
                    setState(() {
                      inEditMode = true;
                    });
                  },
                  child: Text(
                    "Edit",
                  )),
        ],
      ),
    );
  }
}
