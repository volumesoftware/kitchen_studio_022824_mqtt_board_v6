import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
import 'package:kitchen_studio_10162023/dao/recipe_data_access.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/task.dart';

class RecipeSearchResult extends StatefulWidget {
  final String query;

  const RecipeSearchResult({Key? key, required this.query})
      : super(key: key);

  @override
  State<RecipeSearchResult> createState() => _RecipeSearchResultState();
}

class _RecipeSearchResultState extends State<RecipeSearchResult> {
  List<Recipe> recipes = [];
  RecipeDataAccess? recipeDataAccess;
  TaskDataAccess? taskDataAccess;
  DeviceDataAccess? deviceDataAccess;

  File? file;
  String? fileName = "";
  String? _moduleName = "";
  String? _mode = "";
  TextEditingController _taskNameController = TextEditingController();
  List<DeviceStats> devices = [];

  @override
  void initState() {
    recipeDataAccess = RecipeDataAccess.instance;
    taskDataAccess = TaskDataAccess.instance;
    deviceDataAccess = DeviceDataAccess.instance;
    populateRecipe();
    super.initState();
  }

  populateRecipe() {
    recipeDataAccess?.search("recipe_name like ?",
        whereArgs: [widget.query]).then((value) {
      if (value != null) {
        setState(() {
          recipes = value;
        });
      }
    });

    deviceDataAccess?.findAll().then((value) {
      setState(() {
        if(value!=null){
          devices = value;
        }
      });
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
        itemCount: recipes.length,
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
                                recipes[index].imageFilePath ??
                                    "assets/images/img.png")))),
                  ),
                  Text(
                    "${recipes[index].recipeName}",
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
                  devices.isNotEmpty ? DropdownButton<String>(
                    hint: Text("Choose Unit"),
                    isExpanded: true,
                    focusColor: Colors.transparent,
                    isDense: true,
                    padding: EdgeInsets.all(10),
                    items:devices
                        .map(( value) {
                      return DropdownMenuItem<String>(
                        value: value.moduleName,
                        child: Text("${value.moduleName}"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null){
                        setState(() {
                          _moduleName = value;
                        });
                      }

                    },
                  ):SizedBox(),
                  ElevatedButton(
                      onPressed: () {
                        Task item = Task();
                        item.recipeName = recipes[index].recipeName;
                        item.recipeId = recipes[index].id;
                        item.taskName = _taskNameController.text;
                        item.moduleName = _moduleName;
                        item.status = Task.CREATED;
                        item.progress = 0.0;
                        taskDataAccess?.create(item);
                        Navigator.of(context).pop(item);
                      },
                      child: Text("Select Task"))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
