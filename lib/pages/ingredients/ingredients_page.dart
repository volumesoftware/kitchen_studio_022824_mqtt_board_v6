import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:kitchen_studio_10162023/dao/ingredient_data_access.dart';
import 'package:kitchen_studio_10162023/model/ingredient.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({Key? key}) : super(key: key);

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<Ingredient> ingredients = [];
  IngredientDataAccess? ingredientDataAccess;
  String _stockLevel = '';
  String _ingredientType = '';
  File? file;
  String? fileName = "";

  @override
  void initState() {
    ingredientDataAccess = IngredientDataAccess.instance;
    populateIngredient();
    super.initState();
  }

  populateIngredient() {
    ingredientDataAccess?.findAll().then((value) {
      if (value != null) {
        setState(() {
          ingredients = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Ingredients"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.85,
            crossAxisCount: 6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${ingredients[index].ingredientName}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      ingredients[index].stockLevel == "LOW" ? AvatarGlow(
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.filter_list),
                            onSelected: (String result) {
                              switch (result) {
                                case 'filter1':
                                  print('filter 1 clicked');
                                  break;
                                case 'filter2':
                                  print('filter 2 clicked');
                                  break;
                                case 'clearFilters':
                                  print('Clear filters');
                                  break;
                                default:
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Refilled',
                                child: Text('Refilled'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'disable',
                                child: Text('Disable'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              )
                            ],
                          ),
                          glowColor: Colors.red,
                          shape: BoxShape.rectangle,
                          endRadius: 30):PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (String result) {
                          switch (result) {
                            case 'filter1':
                              print('filter 1 clicked');
                              break;
                            case 'filter2':
                              print('filter 2 clicked');
                              break;
                            case 'clearFilters':
                              print('Clear filters');
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Refilled',
                            child: Text('Refilled'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'disable',
                            child: Text('Disable'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          )
                        ],
                      )
                    ],
                  )),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(
                                ingredients[index].imageFilePath ??
                                    "assets/images/img.png")))),
                  ),
                  Text(
                    "Stock, ${ingredients[index].stockLevel}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Location, (${ingredients[index].coordinateX}, ${ingredients[index].coordinateY}, ${ingredients[index].coordinateZ})",
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _displayTextInputDialog(context);
          },
          label: Row(
            children: [Text("Add Ingredient"), Icon(Icons.add)],
          )),
    );
  }

  void setStockLevel(String stockLevel, setState) {
    setState(() {
      _stockLevel = stockLevel;
    });
  }

  void setIngredientType(String ingredientType, setState) {
    setState(() {
      _ingredientType = ingredientType;
    });
  }

  void setImagePath(String filename, setState) {
    setState(() {
      fileName = filename;
    });
  }

  Future _displayTextInputDialog(BuildContext context) async {
    TextEditingController _ingredientNameController = TextEditingController();
    TextEditingController _coordinateXController = TextEditingController();
    TextEditingController _coordinateYController = TextEditingController();
    TextEditingController _coordinateZController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add new ingredient'),
              content: Container(
                height: 450,
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _coordinateYController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Coordinate Y'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _coordinateZController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text('Coordinate Z'),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("Choose a stock level"),
                      subtitle: Text("${_stockLevel}"),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: <String>['LOW', 'MEDIUM', 'HIGH']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) setStockLevel(value, setState);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("Choose ingredient type"),
                      subtitle: Text("${_ingredientType}"),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items: <String>['LIQUID', 'SOLID', 'GRANULAR']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null)
                              setIngredientType(value, setState);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      subtitle: Text("${fileName}"),
                      title: Text("Pick image"),
                      trailing: Icon(Icons.image),
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          file = File(result.files.single.path!);
                          var split = result.files.single.path!.split('\\');
                          setImagePath(split[split.length - 1], setState);
                        } else {
                          // User canceled the picker
                        }
                      },
                    )
                  ],
                ),
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
                  onPressed: () async {
                    File? copiedFile =
                        await file?.copy("assets/images/${fileName}");
                    Ingredient ing = Ingredient();
                    ing.ingredientName = _ingredientNameController.text;
                    ing.ingredientType = _ingredientType;
                    ing.stockLevel = _stockLevel;
                    ing.imageFilePath = copiedFile?.path;
                    ing.coordinateX =
                        double.tryParse(_coordinateXController.text);
                    ing.coordinateY =
                        double.tryParse(_coordinateYController.text);
                    ing.coordinateZ =
                        double.tryParse(_coordinateZController.text);
                    await ingredientDataAccess?.create(ing);
                    populateIngredient();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
