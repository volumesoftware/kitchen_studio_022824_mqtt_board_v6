import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';

class IngredientCreationDialog extends StatefulWidget {

  final VoidCallback onEvent;

  const IngredientCreationDialog({super.key, required this.onEvent});

  @override
  State<IngredientCreationDialog> createState() =>
      _IngredientCreationDialogState();
}

class _IngredientCreationDialogState extends State<IngredientCreationDialog> {
  String _stockLevel = '';
  String _ingredientType = '';
  File? file;
  String? fileName = "";

  late IngredientDataAccess ingredientDataAccess;


  TextEditingController _ingredientNameController = TextEditingController();
  TextEditingController _coordinateXController = TextEditingController();
  TextEditingController _coordinateYController = TextEditingController();
  TextEditingController _coordinateZController = TextEditingController();


  @override
  void initState() {
    ingredientDataAccess = IngredientDataAccess.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: 450,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: TextField(
              controller: _ingredientNameController,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                label: Text('Ingredient Name'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: TextField(
              controller: _coordinateXController,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                label: Text('Coordinate X'),
              ),
            ),
          ),
          ListTile(
            title: Text("Choose a stock level"),
            subtitle: Text("${_stockLevel}"),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                items: <String>['LOW', 'MEDIUM', 'HIGH'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null){
                    setState(() {
                      _stockLevel = value;
                    });
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: Text("Choose ingredient type"),
            subtitle: Text("${_ingredientType}"),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                items:
                    <String>['LIQUID', 'SOLID', 'GRANULAR'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _ingredientType = value;
                    });
                  }
                },
              ),
            ),
          ),
          ListTile(
            subtitle: Text("${fileName}"),
            title: Text("Pick image"),
            trailing: Icon(Icons.image),
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                file = File(result.files.single.path!);
                var split = result.files.single.path!.split('\\');
                setState(() {
                  fileName = split[split.length - 1];
                });

              } else {
                // User canceled the picker
              }
            },
          ),
          ButtonBar(
            children: _actions(),
          )
        ],
      ),
    );
  }

  List<Widget> _actions() {
    return <Widget>[
      ElevatedButton(
        child: Text('CANCEL'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      ElevatedButton(
        child: Text('OK'),
        onPressed: () async {
          File? copiedFile = await file?.copy("assets/images/${fileName}");
          Ingredient ing = Ingredient();
          ing.ingredientName = _ingredientNameController.text;
          ing.ingredientType = _ingredientType;
          ing.stockLevel = _stockLevel;
          ing.imageFilePath = copiedFile?.path;

          ing.coordinateX = double.tryParse(_coordinateXController.text);
          ing.coordinateY = double.tryParse(_coordinateYController.text);
          ing.coordinateZ = double.tryParse(_coordinateZController.text);
          await ingredientDataAccess.create(ing);
          widget.onEvent();
          Navigator.pop(context);
        },
      ),
    ];
  }
}
