import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_module/kitchen_module.dart';

class RecipeSearchResultV2 extends StatefulWidget {
  final List<Recipe> recipes;
  final String query;
  final RecipeProcessor recipeProcessor;
  final String namedKey;

  const RecipeSearchResultV2(
      {Key? key,
      required this.query,
      required this.recipeProcessor,
      required this.namedKey,
      required this.recipes})
      : super(key: key);

  @override
  State<RecipeSearchResultV2> createState() => _RecipeSearchResultV2State();
}

class _RecipeSearchResultV2State extends State<RecipeSearchResultV2> {
  RecipeDataAccess? recipeDataAccess;
  TaskDataAccess? taskDataAccess;
  DeviceDataAccess? deviceDataAccess;
  int gridCount = 8;
  int selectedIndex = 0;

  File? file;
  String? fileName = "";
  String? _mode = "";
  List<Recipe> recipes = [];
  ValueNotifier<int?> selectedId = ValueNotifier(0);
  ValueNotifier<int?> pressed = ValueNotifier(0);

  @override
  void initState() {
    recipeDataAccess = RecipeDataAccess.instance;
    taskDataAccess = TaskDataAccess.instance;
    deviceDataAccess = DeviceDataAccess.instance;
    populateRecipe();

    ServicesBinding.instance.keyboard.addHandler(_onKey);

    super.initState();
  }

  populateRecipe() async {
    if (widget.recipes.isNotEmpty) {
      recipes = widget.recipes;
    } else {
      recipeDataAccess?.findAll().then(
          (value) => WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  recipes = value ?? [];
                });
              }));
    }
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyRepeatEvent ||
        event is RawKeyDownEvent ||
        event is KeyDownEvent) {
      print("DELEGATE $key}");
      switch (key) {
        case "Numpad 6":
          {
            if (selectedIndex < recipes.length) {
              setState(() {
                selectedIndex = selectedIndex + 1;
              });
            } else {
              setState(() {
                selectedIndex = 0;
              });
            }
            setState(() {
              selectedId.value = recipes[selectedIndex].id;
            });

            break;
          }
        case "Numpad 4":
          {
            if (selectedIndex > 0) {
              setState(() {
                selectedIndex = selectedIndex - 1;
              });
            } else {
              setState(() {
                selectedIndex = recipes.length - 1;
              });
            }
            setState(() {
              selectedId.value = recipes[selectedIndex].id;
            });

            break;
          }
        case "Numpad 8":
          {
            var column =
                int.parse(((selectedIndex + 1) / 8).toStringAsFixed(0)) + 1;
            if (column > 1) {
              setState(() {
                selectedIndex = (selectedIndex - column);
              });
            } else {
              setState(() {
                selectedIndex = selectedIndex;
              });
            }
            setState(() {
              selectedId.value = recipes[selectedIndex].id;
            });

            break;
          }
        case "Numpad 2":
          {
            var column =
                int.parse(((selectedIndex + 1) / 8).toStringAsFixed(0)) + 1;
            var maxColumn = (recipes.length / gridCount);

            if (column != maxColumn) {
              setState(() {
                selectedIndex = (selectedIndex + column);
              });
            } else {
              setState(() {
                selectedIndex = selectedIndex;
              });
            }

            setState(() {
              selectedId.value = recipes[selectedIndex].id;
            });

            break;
          }
        case "Numpad 5":
          {
            setState(() {
              pressed.value = recipes[selectedIndex].id;
            });
            break;
          }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title: Text("Recipes"),
      ),
      body: recipes.isEmpty
          ? Text("No recipe available")
          : Padding(
        key: Key(widget.namedKey),
        padding: EdgeInsets.all(25),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: .6,
              crossAxisCount: gridCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return RecipeItemSearch(
              recipe: recipes[index],
              recipeProcessor: widget.recipeProcessor,
              selected: selectedId,
              pressed: pressed,
            );
          },
        ),
      ),
    );
  }
}

class RecipeItemSearch extends StatefulWidget {
  final Recipe recipe;
  final RecipeProcessor recipeProcessor;
  final ValueNotifier<int?> selected;
  final ValueNotifier<int?> pressed;

  const RecipeItemSearch(
      {Key? key,
      required this.recipe,
      required this.recipeProcessor,
      required this.selected,
      required this.pressed})
      : super(key: key);

  @override
  State<RecipeItemSearch> createState() => _RecipeItemSearchState();
}

class _RecipeItemSearchState extends State<RecipeItemSearch> {
  TextEditingController _taskNameController = TextEditingController();
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  BaseOperationDataAccess operationDataAccess =
      BaseOperationDataAccess.instance;

  Recipe? recipe;
  String? _moduleName = "";
  late RecipeProcessor recipeProcessor;
  bool selected = false;

  @override
  void initState() {
    recipeProcessor = widget.recipeProcessor;

    widget.pressed.addListener(() {
      if (recipe!.id == widget.pressed.value) {
        createTask(context);
      }
    });

    widget.selected.addListener(() {
      if (recipe!.id == widget.selected.value) {
        setState(() {
          selected = true;
        });
      } else {
        setState(() {
          selected = false;
        });
      }
    });

    setState(() {
      recipe = widget.recipe;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${recipe?.recipeName}'),
      child: Container(
        color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
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
                          recipe?.imageFilePath ?? "assets/images/img.png")))),
            ),
            Text(
              "${recipe?.recipeName}",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    label: Text("Task Name")),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await createTask(context);
                },
                child: Text("Select Task"))
          ],
        ),
      ),
    );
  }

  Future<void> createTask(BuildContext context) async {
    DeviceStats deviceStats = recipeProcessor.getDeviceStats();
    Task item = Task();
    item.recipeName = recipe!.recipeName;
    item.recipeId = recipe!.id;
    item.taskName = _taskNameController.text;
    item.moduleName = deviceStats.moduleName;
    item.status = Task.CREATED;
    item.progress = 0.0;
    int? result = await taskDataAccess.create(item);
    if (result != null) {}
    if (result! > 0) {
      Task? savedTask = await taskDataAccess.getById(result);
      List<BaseOperation>? operations = await operationDataAccess
          .search('recipe_id = ?', whereArgs: [recipe!.id!]);
      recipeProcessor
          .processRecipe(TaskPayload(recipe!, operations ?? [], savedTask!));
      Navigator.of(context).pop(item);
    }
  }
}
