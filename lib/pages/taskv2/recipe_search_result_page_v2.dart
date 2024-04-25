import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/service/KeyService.dart';

class RecipeSearchResultV2 extends StatefulWidget {
  final List<Recipe> recipes;
  final String query;
  final RecipeProcessor recipeProcessor;
  final String namedKey;

  const RecipeSearchResultV2({Key? key, required this.query, required this.recipeProcessor, required this.namedKey, required this.recipes}) : super(key: key);

  @override
  State<RecipeSearchResultV2> createState() => _RecipeSearchResultV2State();
}

class _RecipeSearchResultV2State extends State<RecipeSearchResultV2> {
  RecipeDataAccess? recipeDataAccess;
  TaskDataAccess? taskDataAccess;
  int gridCount = 8;
  int selectedIndex = 0;

  File? file;
  String? fileName = "";
  String? _mode = "";
  List<Recipe> allRecipes = [];
  List<Recipe> filteredRecipes = [];
  ValueNotifier<int?> selectedId = ValueNotifier(0);
  ValueNotifier<int?> pressed = ValueNotifier(0);

  int portionIdToShow = 0;

  @override
  void initState() {
    recipeDataAccess = RecipeDataAccess.instance;
    taskDataAccess = TaskDataAccess.instance;
    populateRecipe();
    super.initState();
  }

  populateRecipe() async {
    var value = await recipeDataAccess?.findAll();
    setState(() {
      allRecipes = value ?? [];
    });

    if (portionIdToShow == 0) {
      setState(() {
        filteredRecipes = allRecipes;
      });
    } else {
      var temp = allRecipes.where((recipe) => (recipe.parentId == portionIdToShow) || (recipe.parentId == 0)).toList();

      setState(() {
        filteredRecipes = temp;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes"),
      ),
      body: filteredRecipes.isEmpty
          ? Text("No recipe available")
          : Padding(
              key: Key(widget.namedKey),
              padding: EdgeInsets.all(25),
              child: GridView.builder(
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: .75, crossAxisCount: gridCount, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: Text(
                        "${filteredRecipes[index].recipeName}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      actions: [
                        filteredRecipes[index].parentId == 0
                            ? PopupMenuButton<String>(
                                icon: Icon(Icons.filter_list),
                                onSelected: (String result) async {
                                  switch (result) {
                                    case 'show_portion':
                                      setState(() {
                                        portionIdToShow = filteredRecipes[index].id!;
                                        populateRecipe();
                                      });
                                      break;
                                    case 'hide_portion':
                                      setState(() {
                                        portionIdToShow = 0;
                                        populateRecipe();
                                      });
                                      break;
                                    default:
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  portionIdToShow != 0
                                      ? const PopupMenuItem<String>(
                                          value: 'hide_portion',
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('hide Portions'),
                                              Icon(
                                                Icons.expand,
                                              )
                                            ],
                                          ),
                                        )
                                      : const PopupMenuItem<String>(
                                          value: 'show_portion',
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Show Portions'),
                                              Icon(
                                                Icons.expand,
                                              )
                                            ],
                                          ),
                                        ),
                                ],
                              )
                            : Row()
                      ],
                    ),
                    body: RecipeItemSearch(
                      key: Key('RecipeItemSearch_${filteredRecipes[index].id}'),
                      recipe: filteredRecipes[index],
                      recipeProcessor: widget.recipeProcessor,
                      selected: selectedId,
                      pressed: pressed,
                    ),
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

  const RecipeItemSearch({Key? key, required this.recipe, required this.recipeProcessor, required this.selected, required this.pressed}) : super(key: key);

  @override
  State<RecipeItemSearch> createState() => _RecipeItemSearchState();
}

class _RecipeItemSearchState extends State<RecipeItemSearch> {
  TextEditingController _taskNameController = TextEditingController();
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  BaseOperationDataAccess operationDataAccess = BaseOperationDataAccess.instance;

  Recipe? recipe;
  late RecipeProcessor recipeProcessor;
  bool selected = false;

  @override
  void initState() {
    KeyService.instance.addKeyHandler(context);

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
  void dispose() {
    KeyService.instance.removeHandler();
    super.dispose();
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
                  image: DecorationImage(fit: BoxFit.cover, image: FileImage(File(recipe?.imageFilePath ?? "assets/images/img.png")))),
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
    ModuleResponse moduleResponse = recipeProcessor.getModuleResponse();
    Task item = Task();
    item.recipeName = recipe!.recipeName;
    item.recipeId = recipe!.id;
    item.taskName = _taskNameController.text;
    item.moduleName = moduleResponse.moduleName;
    item.status = Task.CREATED;
    item.progress = 0.0;
    int? result = await taskDataAccess.create(item);
    if (result != null) {}

    if (result! > 0) {
      Task? savedTask = await taskDataAccess.getById(result);
      List<BaseOperation> operations = await operationDataAccess.search("recipe_id = ?", whereArgs: [recipe!.id!], orderBy: 'current_index ASC') ?? [];

      List<Map<String, dynamic>> dataList = jsonDecode(recipe!.v6Instruction!).cast<Map<String, dynamic>>();

      recipeProcessor.process(RecipeHandlerPayload(recipe!, savedTask!, "v6", dataList));

      Navigator.of(context).pop(item);
    }
  }
}
