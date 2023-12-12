import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/app_router.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_units_page.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_units_page_v2.dart';
import 'package:kitchen_studio_10162023/pages/ingredients/ingredients_page.dart';
import 'package:kitchen_studio_10162023/pages/recipes/recipes_page.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/cooking_units_page.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({Key? key}) : super(key: key);

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  ThreadPool threadPool = ThreadPool.instance;
  List<RecipeProcessor> _recipeProcessors = [];
  FocusScopeNode _focusNode = FocusScopeNode();

  int selectedIndex = 0;

  @override
  void initState() {
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    threadPool.stateChanges.listen((List<RecipeProcessor> recipeProcessor) {
      setState(() {
        _recipeProcessors = recipeProcessor;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;
    if (event is KeyDownEvent) {
      print("Key down: $key");
      if (key == 'Numpad 8' || key == 'Arrow Up') {
        _focusNode.previousFocus();
      } else if (key == 'Numpad 2' || key == 'Arrow Down') {
        _focusNode.nextFocus();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        node: _focusNode,
        child: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.redAccent.withOpacity(0.1),
                        ),
                        height: 200,
                        width: 200,
                        child: Center(
                          child: Text(
                            "Kitchen Studio",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      ListTile(
                        leading: Icon(Icons.device_hub),
                        title: const Text('Cooking Units'),
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                      ),
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.transform_outlined),
                        title: const Text('Transporter Units'),
                        subtitle: const Text('Coming soon'),
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list_alt_outlined),
                        title: const Text('Recipes'),
                        onTap: () {
                          setState(() {
                            selectedIndex = 2;
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list),
                        title: const Text('Tasks'),
                        onTap: () {
                          // setState(() {
                          //   selectedIndex = 3;
                          // });
                          Navigator.of(context).pushNamed(AppRouter.taskScreen);
                        },
                      ),
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.data_object),
                        title: const Text('Ingredients'),
                        subtitle: const Text('Coming Soon'),
                        onTap: () {
                          setState(() {
                            selectedIndex = 4;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: getBody(selectedIndex),
              )
            ],
          ),
        ));
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
          return Row();
        }
      case 4:
        {
          return IngredientsPage();
        }

      default:
        return CookingUnitsPageV2();
    }
  }
}
