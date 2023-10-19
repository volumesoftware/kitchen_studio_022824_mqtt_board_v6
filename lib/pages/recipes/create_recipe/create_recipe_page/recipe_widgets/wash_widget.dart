import 'package:flutter/material.dart';

class WashWidget extends StatefulWidget {
  final int index;
  final Function(int idx, double targetTemperature, double duration, int cycle)
      onValueUpdate;

  const WashWidget({Key? key, required this.onValueUpdate, required this.index})
      : super(key: key);

  @override
  State<WashWidget> createState() => _WashWidgetState();
}

class _WashWidgetState extends State<WashWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            Icons.waves_sharp,
          ),
          title: Text(
            "Wash",
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
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: TextField(
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
