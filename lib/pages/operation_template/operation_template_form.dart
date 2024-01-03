import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';



class OperationTemplateFormPage extends StatefulWidget {
  @override
  State<OperationTemplateFormPage> createState() => _OperationTemplateFormPageState();
}

class _OperationTemplateFormPageState extends State<OperationTemplateFormPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Timeline.tileBuilder(
        scrollDirection: Axis.vertical,
        builder: TimelineTileBuilder.fromStyle(
          contentsAlign: ContentsAlign.basic,

          indicatorStyle: IndicatorStyle.outlined,
          contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Timeline Event $index'),
          ),
          itemCount: 20,
        ),
      ),
    );
  }
}
