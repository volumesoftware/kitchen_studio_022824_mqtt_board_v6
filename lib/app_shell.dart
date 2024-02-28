import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_units_page_v2.dart';
import 'package:kitchen_studio_10162023/pages/ingredients/ingredients_page.dart';
import 'package:kitchen_studio_10162023/pages/operation_template/operation_template_page.dart';
import 'package:kitchen_studio_10162023/pages/recipes/recipes_page.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/tasks_pagev2.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/transporter_units_page.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({Key? key}) : super(key: key);

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  ThreadPool threadPool = ThreadPool.instance;
  final GlobalKey _cookingUnitListTile = GlobalKey();
  final GlobalKey _recipesListTile = GlobalKey();
  final GlobalKey _tasksListTile = GlobalKey();

  int selectedIndex = 0;

  int largeFlex = 5;
  int smallFex = 1;

  @override
  void initState() {
    threadPool.stateChanges
        .listen((List<KitchenToolProcessor> recipeProcessor) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Card(
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      height: 200,
                      width: 200,
                      child: selectedIndex == 3
                          ? Row()
                          : Center(
                              child: Text(
                                "Kitchen Studio",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
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

                    StreamBuilder(
                      stream: threadPool.stateChanges,
                      builder: (context, snapshot) {
                        if (threadPool.pool.isNotEmpty) {
                          Iterable<KitchenToolProcessor> transporters =
                              threadPool.pool.where(
                                  (element) => element is TransporterProcessor);

                          return transporters.isNotEmpty
                              ? ListTile(
                                  selected: selectedIndex == 1,
                                  leading: Icon(Icons.move_down),
                                  title: selectedIndex == 3
                                      ? Row()
                                      : const Text('Transporter'),
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                  },
                                )
                              : ListTile(
                                  selected: selectedIndex == 1,
                                  enabled: false,
                                  leading: Icon(
                                    Icons.warning,
                                    color: Colors.orangeAccent,
                                  ),
                                  title: selectedIndex == 3
                                      ? Row()
                                      : const Text('Transporter'),
                                  subtitle: selectedIndex == 3
                                      ? Row()
                                      : const Text(
                                          'Transporter is not connected'),
                                );
                        } else {
                          return ListTile(
                            enabled: false,
                            selected: selectedIndex == 1,
                            leading: Stack(
                              children: [Icon(Icons.move_down)],
                            ),
                            title: selectedIndex == 3
                                ? Row()
                                : const Text('Transporter'),
                            subtitle: selectedIndex == 3
                                ? Row()
                                : const Text('Transporter is not connected'),
                          );
                        }
                      },
                    ),
                    ListTile(
                      key: _recipesListTile,
                      selected: selectedIndex == 2,
                      leading: Icon(Icons.list_alt_outlined),
                      title: selectedIndex == 3 ? Row() : const Text('Recipes'),
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
                      title: selectedIndex == 3 ? Row() : const Text('Tasks'),
                      onTap: () {
                        setState(() {
                          selectedIndex = 3;
                        });

                        // Navigator.of(context).pushNamed(AppRouter.taskScreen);
                      },
                    ),
                    ListTile(
                      selected: selectedIndex == 4,
                      leading: Icon(Icons.data_object),
                      title: selectedIndex == 3
                          ? Row()
                          : const Text('Ingredients'),
                      subtitle: selectedIndex == 3
                          ? Row()
                          : const Text('Coming Soon'),
                      onTap: () {
                        setState(() {
                          selectedIndex = 4;
                        });
                      },
                    ),
                  ],
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: getBody(selectedIndex),
              flex: (selectedIndex == 3) ? 20 : 5,
            )
          ],
        ),
      ),
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
