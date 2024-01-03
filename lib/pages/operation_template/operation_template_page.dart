import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/app_router.dart';

class OperationTemplatePage extends StatefulWidget {
  const OperationTemplatePage({Key? key}) : super(key: key);

  @override
  State<OperationTemplatePage> createState() => _OperationTemplatePageState();
}

class _OperationTemplatePageState extends State<OperationTemplatePage> {
  final List<String> _items = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 10; i++) {
      _items.add('Item $i');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Draggable Gridview Demo')),
      body: DraggableGridViewBuilder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height / 3),
        ),
        children: _items.map((item) => _buildItem(context, item)).toList(),
        isOnlyLongPress: false,
        dragCompletion: (List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
          print( 'onDragAccept: $beforeIndex -> $afterIndex');
        },
        dragFeedback: (List<DraggableGridItem> list, int index) {
          return Container(
            child: list[index].child,
            width: 200,
            height: 150,
          );
        },
        dragPlaceHolder: (List<DraggableGridItem> list, int index) {
          return PlaceHolderWidget(
            child: Container(
              color: Colors.green,
              child: Text("${list[index].child}"),
              width: 100.0,
              height: 100.0,
            ),
          );
        },
      ),
    );
  }

  DraggableGridItem _buildItem(BuildContext context, String item) {
    return DraggableGridItem(
        isDraggable: true,
        child: Container(
          color: Colors.greenAccent,
      child: Text("${item}"),
      width: 100.0,
      height: 100.0,
    ));
  }

}
