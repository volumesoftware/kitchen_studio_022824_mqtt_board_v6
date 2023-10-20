import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/ingredient_data_access.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/ingredient.dart';

class IngredientSearchResult extends StatefulWidget {
  final String query;

  const IngredientSearchResult({Key? key, required this.query})
      : super(key: key);

  @override
  State<IngredientSearchResult> createState() => _IngredientSearchResultState();
}

class _IngredientSearchResultState extends State<IngredientSearchResult> {
  List<Ingredient> ingredients = [];
  IngredientDataAccess? ingredientDataAccess;
  File? file;
  String? fileName = "";
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _modeController = TextEditingController(text: 'SYSTEM');

  @override
  void initState() {
    ingredientDataAccess = IngredientDataAccess.instance;
    populateIngredient();
    super.initState();
  }

  populateIngredient() {
    ingredientDataAccess?.search("ingredient_name like ?",
        whereArgs: [widget.query]).then((value) {
      if (value != null) {
        setState(() {
          ingredients = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: .6,
            crossAxisCount: 8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                    "${ingredients[index].ingredientName}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Stock, ${ingredients[index].stockLevel}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          label: Text("Quantity")),
                    ),
                  ),
                  DropdownButton<String>(
                    hint: Text("Choose Mode"),
                    isExpanded: true,
                    isDense: true,
                    value: _modeController.text,
                    padding: EdgeInsets.all(10),
                    items: <String>['MANUAL', 'SYSTEM']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() {
                          _modeController.text = value;
                        });
                    },
                  ),
                  ElevatedButton(
                      onPressed: () {
                        IngredientItem item = IngredientItem();
                        item.ingredient = ingredients[index];
                        item.ingredientId = ingredients[index].id;
                        item.quantity =
                            double.tryParse(_quantityController.text);
                        item.mode = _modeController.text;

                        Navigator.of(context).pop(item);
                      },
                      child: Text("Select Ingredient"))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
