import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/ingredient.dart';
import 'package:kitchen_studio_10162023/model/pump_water_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/ingredient_search_delegate.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';

class DockIngredientWidget extends StatefulWidget {
  final DockIngredientOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const DockIngredientWidget({
    Key? key,
    required this.operation,
    required this.recipeWidgetActions,
  }) : super(key: key);

  @override
  State<DockIngredientWidget> createState() => _DockIngredientWidgetState();
}

class _DockIngredientWidgetState extends State<DockIngredientWidget> {
  List<IngredientItem> ingredientItems = [];
  DockIngredientOperation? operation;
  bool inEditMode = false;
  TextEditingController? _targetTemperatureController;
  TextEditingController? _durationController;
  RecipeWidgetActions? recipeWidgetActions;

  @override
  void initState() {
    this.recipeWidgetActions = widget.recipeWidgetActions;
    operation = widget.operation;
    _targetTemperatureController =
        TextEditingController(text: "${operation?.targetTemperature}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Icon(
            Icons.dock_sharp,
          ),
          title: Text(
            "Dock Ingredient",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              child: Text("${operation!.currentIndex! + 1}"),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              inEditMode
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _targetTemperatureController,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: 'Target Temperature',
                            label: Text("Target Temperature")),
                      ),
                    )
                  : ListTile(
                      title: Text('Target Temperature'),
                      trailing: Text("${_targetTemperatureController?.text}"),
                    ),
              inEditMode
                  ? ListTile(
                      title: Text('Ingredients'),
                      trailing: IconButton(
                        onPressed: () async {
                          var result = await showSearch<IngredientItem?>(
                            context: context,
                            delegate: IngredientSearchDelegate(),
                          );

                          if (result != null) {
                            setState(() {
                              ingredientItems.add(result);
                            });
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    )
                  : ListTile(
                      title: Text('Ingredients'),
                      trailing: Text("${ingredientItems.length}"),
                    ),
              CarouselSlider(
                options: CarouselOptions(
                    height: 80.0,
                    autoPlay: true,
                    enableInfiniteScroll: false,
                    disableCenter: true),
                items: ingredientItems.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Stack(
                          children: [
                            ListTile(
                              tileColor: Theme.of(context).indicatorColor,
                              title: Text("${i.ingredient?.ingredientName}"),
                              trailing: Text("${i.quantity}"),
                              subtitle: Text("${i.mode}"),
                              leading: CircleAvatar(
                                backgroundImage: FileImage(File(
                                    i.ingredient!.imageFilePath ??
                                        "assets/images/img.png")),
                              ),
                            ),
                            inEditMode ? Positioned(
                              child: IconButton(
                                  onPressed: () {}, icon: Icon(Icons.close, color: Colors.red,)),
                              top: 0,
                              right: 0,
                            ) : SizedBox()
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        bottomSheet: ButtonBar(
          children: [
            ElevatedButton(
                onPressed: () {
                  recipeWidgetActions?.onDelete(operation!);
                },
                child: Text("Delete")),
            ElevatedButton(
                onPressed: () async {
                  recipeWidgetActions?.onTest(operation!);
                },
                child: Text("Run Test")),
            inEditMode
                ? FilledButton(
                    onPressed: () {
                      operation?.targetTemperature =
                          double.tryParse(_targetTemperatureController!.text);
                      recipeWidgetActions?.onValueUpdate(operation!);
                      setState(() {
                        inEditMode = false;
                      });
                    },
                    child: Text(
                      "Update",
                    ))
                : FilledButton(
                    onPressed: () => setState(() {
                          inEditMode = true;
                        }),
                    child: Text("Edit")),
          ],
        ));
  }
}
