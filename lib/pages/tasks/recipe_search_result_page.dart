// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
// import 'package:kitchen_studio_10162023/dao/recipe_data_access.dart';
// import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
// import 'package:kitchen_studio_10162023/model/device_stats.dart';
// import 'package:kitchen_studio_10162023/model/recipe.dart';
// import 'package:kitchen_studio_10162023/model/task.dart';
// import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
//
// class RecipeSearchResult extends StatefulWidget {
//   final String query;
//
//   const RecipeSearchResult({Key? key, required this.query})
//       : super(key: key);
//
//   @override
//   State<RecipeSearchResult> createState() => _RecipeSearchResultState();
// }
//
// class _RecipeSearchResultState extends State<RecipeSearchResult> {
//   List<Recipe> recipes = [];
//   RecipeDataAccess? recipeDataAccess;
//   TaskDataAccess? taskDataAccess;
//   DeviceDataAccess? deviceDataAccess;
//   TaskRunnerPool runnerPool = TaskRunnerPool.instance;
//
//   File? file;
//   String? fileName = "";
//   String? _mode = "";
//   List<DeviceStats> devices = [];
//
//   @override
//   void initState() {
//     recipeDataAccess = RecipeDataAccess.instance;
//     taskDataAccess = TaskDataAccess.instance;
//     deviceDataAccess = DeviceDataAccess.instance;
//     populateRecipe();
//     super.initState();
//   }
//
//   populateRecipe() {
//     recipeDataAccess?.search("recipe_name like ?",
//         whereArgs: [widget.query]).then((value) {
//       if (value != null) {
//         setState(() {
//           recipes = value;
//         });
//       }
//     });
//
//
//     var tempDevices = runnerPool.getDevices();
//     setState(() {
//       devices = tempDevices;
//     });
//
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(25),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             childAspectRatio: .6,
//             crossAxisCount: 8,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10),
//         itemCount: recipes.length,
//         itemBuilder: (context, index) {
//           return RecipeItemSearch(recipe: recipes[index], devices: devices,);
//         },
//       ),
//     );
//   }
// }
//
// class RecipeItemSearch extends StatefulWidget {
//   final Recipe recipe;
//   final List<DeviceStats> devices;
//   const RecipeItemSearch({Key? key, required this.recipe, required this.devices}) : super(key: key);
//
//   @override
//   State<RecipeItemSearch> createState() => _RecipeItemSearchState();
// }
//
// class _RecipeItemSearchState extends State<RecipeItemSearch> {
//   TextEditingController _taskNameController = TextEditingController();
//   DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
//   TaskDataAccess taskDataAccess = TaskDataAccess.instance;
//    Recipe? recipe;
//    List<DeviceStats>? devices;
//   String? _moduleName = "";
//
//   @override
//   void initState() {
//      setState(() {
//        recipe = widget.recipe;
//        devices = widget.devices;
//        if(devices!=null){
//          _moduleName = devices![0].moduleName;
//        }
//
//      });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Container(
//         padding: EdgeInsets.all(20),
//         width: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Container(
//               width: double.infinity,
//               height: 150,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   image: DecorationImage(
//                       fit: BoxFit.cover,
//                       image: FileImage(File(
//                           recipe?.imageFilePath ??
//                               "assets/images/img.png")))),
//             ),
//             Text(
//               "${recipe?.recipeName}",
//               style: Theme.of(context).textTheme.titleSmall,
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 3),
//               child: TextField(
//                 controller: _taskNameController,
//                 decoration: InputDecoration(
//                     isDense: true,
//                     border: OutlineInputBorder(),
//                     label: Text("Task Name")),
//               ),
//             ),
//             devices!.isNotEmpty ? DropdownButton<String>(
//               hint: Text("Choose Unit"),
//               isExpanded: true,
//               focusColor: Colors.transparent,
//               isDense: true,
//               value: _moduleName,
//               padding: EdgeInsets.all(10),
//               items:devices!
//                   .map(( value) {
//                 return DropdownMenuItem<String>(
//                   value: value.moduleName,
//                   child: Text("${value.moduleName}"),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null){
//                   setState(() {
//                     _moduleName = value;
//                   });
//                 }
//
//               },
//             ):SizedBox(),
//             ElevatedButton(
//                 onPressed: () {
//                   Task item = Task();
//                   item.recipeName = recipe!.recipeName;
//                   item.recipeId = recipe!.id;
//                   item.taskName = _taskNameController.text;
//                   item.moduleName = _moduleName;
//                   item.status = Task.CREATED;
//                   item.progress = 0.0;
//                   taskDataAccess?.create(item);
//                   Navigator.of(context).pop(item);
//                 },
//                 child: Text("Select Task"))
//           ],
//         ),
//       ),
//     );
//   }
// }
