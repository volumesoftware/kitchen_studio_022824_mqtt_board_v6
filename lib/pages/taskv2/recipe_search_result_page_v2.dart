import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';



class RecipeSearchResultV2 extends StatefulWidget {
  final List<Recipe> recipes;
  final String query;
  final RecipeProcessor recipeProcessor;
  final String namedKey;

  const RecipeSearchResultV2({Key? key, required this.query, required  this.recipeProcessor, required this.namedKey, required this.recipes})
      : super(key: key);

  @override
  State<RecipeSearchResultV2> createState() => _RecipeSearchResultV2State();
}

class _RecipeSearchResultV2State extends State<RecipeSearchResultV2> {
  RecipeDataAccess? recipeDataAccess;
  TaskDataAccess? taskDataAccess;
  DeviceDataAccess? deviceDataAccess;

  File? file;
  String? fileName = "";
  String? _mode = "";
  List<Recipe> recipes = [];

  @override
  void initState() {
    recipes = widget.recipes;
    recipeDataAccess = RecipeDataAccess.instance;
    taskDataAccess = TaskDataAccess.instance;
    deviceDataAccess = DeviceDataAccess.instance;
    populateRecipe();
    super.initState();
  }

  populateRecipe() {
  }

  @override
  Widget build(BuildContext context) {
    return recipes.isEmpty ? Text("No recipe available") : Padding(
      key: Key(widget.namedKey),
      padding: EdgeInsets.all(25),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: .6,
            crossAxisCount: 8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeItemSearch(recipe: recipes[index], recipeProcessor: widget.recipeProcessor,);
        },
      ),
    );
  }
}

class RecipeItemSearch extends StatefulWidget {
  final Recipe recipe;
  final RecipeProcessor recipeProcessor;
  const RecipeItemSearch({Key? key, required this.recipe, required this.recipeProcessor}) : super(key: key);

  @override
  State<RecipeItemSearch> createState() => _RecipeItemSearchState();
}

class _RecipeItemSearchState extends State<RecipeItemSearch> {
  TextEditingController _taskNameController = TextEditingController();
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  BaseOperationDataAccess operationDataAccess = BaseOperationDataAccess.instance;

   Recipe? recipe;
  String? _moduleName = "";
  late RecipeProcessor recipeProcessor;

  @override
  void initState() {
    recipeProcessor = widget.recipeProcessor;
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
                          recipe?.imageFilePath ??
                              "assets/images/img.png")))),
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

                  DeviceStats deviceStats = recipeProcessor.getDeviceStats();
                  Task item = Task();
                  item.recipeName = recipe!.recipeName;
                  item.recipeId = recipe!.id;
                  item.taskName = _taskNameController.text;
                  item.moduleName = deviceStats.moduleName;
                  item.status = Task.CREATED;
                  item.progress = 0.0;
                  int? result = await taskDataAccess.create(item);
                  if(result!=null){}
                  if(result!> 0){
                    Task? savedTask = await taskDataAccess.getById(result);
                    List<BaseOperation>? operations = await operationDataAccess.search('recipe_id = ?', whereArgs: [recipe!.id!]);
                    recipeProcessor.processRecipe(TaskPayload(recipe!, operations ?? [], savedTask!));
                    Navigator.of(context).pop(item);
                  }

                },
                child: Text("Select Task"))
          ],
        ),
      ),
    );
  }
}
