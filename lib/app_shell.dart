import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_units_page_v2.dart';
import 'package:kitchen_studio_10162023/pages/ingredients/ingredients_page.dart';
import 'package:kitchen_studio_10162023/pages/operation_template/operation_template_page.dart';
import 'package:kitchen_studio_10162023/pages/recipes/recipes_page.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/tasks_pagev2.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/cooking_units_page.dart';
import 'package:kitchen_studio_10162023/service/globla_loader_service.dart';
import 'package:kitchen_studio_10162023/widgets/cursor.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({Key? key}) : super(key: key);

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  ThreadPool threadPool = ThreadPool.instance;
  List<RecipeProcessor> _recipeProcessors = [];
  FocusScopeNode _focusNode = FocusScopeNode();
  final GlobalKey _cookingUnitListTile = GlobalKey();
  final GlobalKey _recipesListTile = GlobalKey();
  final GlobalKey _tasksListTile = GlobalKey();
  final GlobalKey _operationTemplateListTile = GlobalKey();

  double X = 0;
  double Y = 0;

  int selectedIndex = 0;

  @override
  void initState() {
    threadPool.stateChanges.listen((List<RecipeProcessor> recipeProcessor) {
      setState(() {
        _recipeProcessors = recipeProcessor;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width *
                        (selectedIndex == 3 ? 0.05 : 0.15),
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
                          height: 200,
                          width: 200,
                          child: selectedIndex == 3
                              ? Row()
                              : Center(
                                  child: Text(
                                    "Kitchen Studio",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                          margin: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        ListTile(
                          key: _cookingUnitListTile,
                          selected: selectedIndex == 0,
                          leading: Icon(Icons.device_hub),
                          title: selectedIndex == 3
                              ? Row()
                              : const Text('Cooking Units'),
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                        ),
                        // ListTile(
                        //   selected: selectedIndex == 1,
                        //   enabled: false,
                        //   leading: Icon(Icons.transform_outlined),
                        //   title: const Text('Transporter Units'),
                        //   subtitle: const Text('Coming soon'),
                        //   onTap: () {
                        //     setState(() {
                        //       selectedIndex = 1;
                        //     });
                        //   },
                        // ),
                        ListTile(
                          key: _recipesListTile,
                          selected: selectedIndex == 2,
                          leading: Icon(Icons.list_alt_outlined),
                          title: selectedIndex == 3
                              ? Row()
                              : const Text('Recipes'),
                          onTap: () {
                            setState(() {
                              selectedIndex = 2;
                            });
                          },
                        ),
                        // ListTile(
                        //   key: _operationTemplateListTile,
                        //   selected: selectedIndex == 5,
                        //   leading: Icon(Icons.calculate_sharp),
                        //   subtitle: selectedIndex == 3 ? Row() : const Text('Complex Recipe Creator'),
                        //   title: selectedIndex == 3 ? Row() : const Text('Advanced recipe'),
                        //   onTap: () {
                        //     setState(() {
                        //       selectedIndex = 5;
                        //     });
                        //   },
                        // ),
                        ListTile(
                          key: _tasksListTile,
                          selected: selectedIndex == 3,
                          leading: Icon(Icons.list),
                          title:
                              selectedIndex == 3 ? Row() : const Text('Tasks'),
                          onTap: () {
                            setState(() {
                              selectedIndex = 3;
                            });

                            // Navigator.of(context).pushNamed(AppRouter.taskScreen);
                          },
                        ),
                        // ListTile(
                        //   selected: selectedIndex == 4,
                        //   enabled: false,
                        //   leading: Icon(Icons.data_object),
                        //   title: const Text('Ingredients'),
                        //   subtitle: const Text('Coming Soon'),
                        //   onTap: () {
                        //     setState(() {
                        //       selectedIndex = 4;
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.green,
                  width: MediaQuery.of(context).size.width *
                      (selectedIndex == 3 ? 0.95 : 0.8),
                  height: MediaQuery.of(context).size.height,
                  child: getBody(selectedIndex),
                )
              ],
            ),
          ),
        ),
        Positioned(
            left: X,
            top: Y,
            child: PositionedCursor(
              onChanged: (CursorPosition value) {
                setState(() {
                  X = value.x;
                  Y = value.y;
                });
              },
            )),
        StreamBuilder(
          stream: GlobalLoaderService.instance.loaderState,
          builder: (context, snapshot) {
            return snapshot.data ?? GlobalLoaderService.instance.show
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.green,
                  )
                : Row();
          },
        )
      ],
    );
  }

  Widget getBody(int index) {
    switch (index) {
      case 0:
        {
          return CookingUnitsPageV2();
        }
      case 1:
        {
          return TransporterUnitsPage();
        }
      case 2:
        {
          return RecipesPage();
        }
      case 3:
        {
          return TasksPageV2();
        }
      case 4:
        {
          return IngredientsPage();
        }
      case 5:
        {
          return OperationTemplatePage();
        }

      default:
        return CookingUnitsPageV2();
    }
  }
}
