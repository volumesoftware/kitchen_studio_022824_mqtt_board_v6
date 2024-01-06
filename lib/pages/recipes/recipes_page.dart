import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/app_router.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/service/globla_loader_service.dart';
import 'package:path_provider/path_provider.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({Key? key}) : super(key: key);

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String? newlySavedRecipeName = "";

  File? file;
  String? fileName = "";
  String _typeHandler = '';
  RecipeDataAccess? recipeDataAccess;

  List<Recipe>? recipes = [];
  static const String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void initState() {
    recipeDataAccess = RecipeDataAccess.instance;
    pullRecipes();
    super.initState();
  }

  void pullRecipes() {
    recipeDataAccess?.findAll().then((value) {
      setState(() {
        recipes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Recipes"),
          actions: [
            IconButton(onPressed: () async {}, icon: Icon(Icons.search))
          ]),
      body: recipes!.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: .76,
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: recipes?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  shadowColor:
                      recipes?[index].recipeName == newlySavedRecipeName
                          ? Colors.red
                          : Colors.black12,
                  elevation: 20,
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
                            SizedBox(
                              child: Text(
                                "${recipes?[index].recipeName}",
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.clip,
                              ),
                              width: 140,
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.filter_list),
                              onSelected: (String result) async {
                                switch (result) {
                                  case 'delete':
                                    int? count = await recipeDataAccess
                                        ?.delete(recipes![index].id!);
                                    pullRecipes();
                                    break;
                                  case 'filter2':
                                    print('filter 2 clicked');
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            )
                          ],
                        )),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(
                                      recipes?[index].imageFilePath ??
                                          "assets/images/img.png")))),
                        ),
                        Text(
                          "Cook Count, ${recipes?[index].cookCount}",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          "Duration ${timeLeft(recipes?[index].estimatedTimeCompletion?.toInt() ?? 0)}",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          "Author : ${recipes?[index].author} ",
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        ButtonBar(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      AppRouter.createRecipePage,
                                      arguments: recipes![index]);
                                },
                                child: Text("Edit")),
                            // ElevatedButton(
                            //     onPressed: () {},
                            //     child: Row(
                            //       children: [Text("Cook")],
                            //     ))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
              "No recipes available",
              style: Theme.of(context).textTheme.displaySmall,
            )),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Recipe? a = await _displayTextInputDialog(context);
            if (a != null) {
              setState(() {
                newlySavedRecipeName = a.recipeName;
              });
              pullRecipes();
            }
          },
          label: Row(
            children: [Text("Add Recipe"), Icon(Icons.add)],
          )),
    );
  }

  void setTypeHandler(String typeHandler, setState) {
    setState(() {
      _typeHandler = typeHandler;
    });
  }

  void setImagePath(String filename, setState) {
    setState(() {
      fileName = filename;
    });
  }

  Future _displayTextInputDialog(BuildContext context) async {
    TextEditingController _recipeNameController = TextEditingController();
    TextEditingController _authorController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add new recipe'),
              content: Container(
                height: 280,
                width: 450,
                child: Column(
                  children: [
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
                    ),
                    ListTile(
                      title: Text("Choose A Type Handler"),
                      subtitle: Text("${_typeHandler}"),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (String value) {
                          setTypeHandler(value, setState);
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Stir Fry',
                            child: Text('Stir Fry'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Deep Fry',
                            child: Text('Deep Fry'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _recipeNameController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: 'Recipe Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: TextField(
                        controller: _authorController,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          hintText: 'Author',
                        ),
                      ),
                    ),
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

                    GlobalLoaderService.instance.showLoading();
                    final Directory tempDir = await getTemporaryDirectory();
                    String path = "${tempDir.path}\\kitchen\\assets\\images";
                    Directory myNewDir =
                        await Directory('$path').create(recursive: true);
                    File? copiedFile = await file?.copy(
                        "${tempDir.path}\\kitchen\\assets\\images\\${fileName}");

                    Recipe recipe = Recipe(
                        author: _authorController.text,
                        recipeName: _recipeNameController.text,
                        imageFilePath: '${copiedFile?.path}',
                        typeHandler: _typeHandler);
                    var i = await recipeDataAccess?.create(recipe);
                    if (i != null) {
                      Recipe? createdRecipe = await recipeDataAccess?.getById(i);
                      Navigator.pop(context, createdRecipe);
                    } else {
                      Navigator.pop(context);
                    }
                    GlobalLoaderService.instance.hideLoading();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String timeLeft(int seconds) {
    String eta = "";
    if (seconds >= 60) {
      eta = (seconds / 60).toStringAsFixed(2);
      return "$eta minutes";
    } else if (seconds >= 3600) {
      eta = (seconds / (60 * 60)).toStringAsFixed(2);
      return "$eta hours";
    } else {
      return "$seconds seconds";
    }
  }
}
