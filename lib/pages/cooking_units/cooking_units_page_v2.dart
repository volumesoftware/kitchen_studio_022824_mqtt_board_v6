import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_unit_card_component.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_unit_card_component_v2.dart';

class CookingUnitsPageV2 extends StatefulWidget {
  const CookingUnitsPageV2({Key? key}) : super(key: key);

  @override
  State<CookingUnitsPageV2> createState() => _CookingUnitsPageV2State();
}

class _CookingUnitsPageV2State extends State<CookingUnitsPageV2> {
  Timer? timer;
  UdpService? udpService = UdpService.instance;
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  ThreadPool threadPool = ThreadPool.instance;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Cooking Units"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))]),
      body: StreamBuilder<List<RecipeProcessor>>(
        stream: threadPool.stateChanges,
        builder: (BuildContext context,
            AsyncSnapshot<List<RecipeProcessor>> snapshot) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: .65,
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: snapshot.data?.length ?? threadPool.poolSize,
            itemBuilder: (context, index) {
              return CookingUnitCardComponentV2(
                  recipeProcessor:snapshot.data!=null? snapshot.data![index] : threadPool.pool[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _displayTextInputDialog(context);
          },
          label: Row(
            children: [Text("Add Units"), Icon(Icons.add)],
          )),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new unit'),
          content: TextField(
            decoration: InputDecoration(hintText: "Unit Ip Address"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
