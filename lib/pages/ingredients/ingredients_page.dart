import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/ingredients/ingredient_creation.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({Key? key}) : super(key: key);

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<Ingredient> ingredients = [];
  late IngredientDataAccess ingredientDataAccess;

  @override
  void initState() {
    ingredientDataAccess = IngredientDataAccess.instance;
    populateIngredient();
    super.initState();
  }

  populateIngredient() {
    ingredientDataAccess.findAll().then((value) {
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
                        "${ingredients[index].ingredientName} ",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      ingredients[index].stockLevel == "LOW"
                          ? AvatarGlow(
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.filter_list),
                                onSelected: (String result) async {
                                  switch (result) {
                                    case 'filter1':
                                      print('filter 1 clicked');
                                      break;
                                    case 'filter2':
                                      print('filter 2 clicked');
                                      break;
                                    case 'delete':
                                      await ingredientDataAccess.delete(ingredients[index].id!);
                                      populateIngredient();
                                      break;
                                    default:
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  ingredients[index].ingredientType == 'SOLID'
                                      ? const PopupMenuItem<String>(
                                          value: 'dispense',
                                          child: Text('Dispense'),
                                        )
                                      : ingredients[index].ingredientType ==
                                              'GRANULAR'
                                          ? const PopupMenuItem<String>(
                                              value: 'dispense',
                                              child: Text('Dispense'),
                                            )
                                          : const PopupMenuItem<String>(
                                              value: 'dispense',
                                              child: Text('Dispense'),
                                            ),
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
                              endRadius: 30)
                          : PopupMenuButton<String>(
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
                  ),
                  Text(
                    "Type, (${ingredients[index].ingredientType})",
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


  Future _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add new ingredient'),
              content: IngredientCreationDialog(onEvent: () {
                populateIngredient();
              },),
            );
          },
        );
      },
    );
  }
}
