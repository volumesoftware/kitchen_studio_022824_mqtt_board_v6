import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/app_router.dart';
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
  final GlobalKey _cookingUnitListTile = GlobalKey();
  final GlobalKey _recipesListTile = GlobalKey();
  final GlobalKey _tasksListTile = GlobalKey();

  double X = 0;
  double Y = 0;

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

      switch (key) {
        case "Numpad 7":
          {
            simulateClicking(_cookingUnitListTile);
            break;
          }
        case "Numpad 4":
          {
            simulateClicking(_recipesListTile);
            break;
          }
        case "Numpad 1":
          {
            simulateClicking(_tasksListTile);
            break;
          }
      }
    }
    return false;
  }

  Future<void> simulateClicking(GlobalKey key) async {
    final RenderObject? renderObj = key.currentContext?.findRenderObject();
    RenderBox renderbox = renderObj as RenderBox;
    Offset position = renderbox.localToGlobal(Offset.zero);
    double x = position.dx;
    double y = position.dy;

    print(" shell $x , $y");

    setState(() {
      X = x;
      Y =y;
    });

    GestureBinding.instance.handlePointerEvent(PointerDownEvent(
      position: Offset(x + 10, y),
    )); //trigger button up,

    await Future.delayed(Duration(milliseconds: 50));

    GestureBinding.instance.handlePointerEvent(PointerUpEvent(
      position: Offset(x + 10, y),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                          color: Theme.of(context).colorScheme.onInverseSurface,
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
                        key: _cookingUnitListTile,
                        selected: selectedIndex == 0,
                        leading: Icon(Icons.device_hub),
                        title: const Text('Cooking Units'),
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
                        title: const Text('Recipes'),
                        onTap: () {
                          setState(() {
                            selectedIndex = 2;
                          });
                        },
                      ),
                      ListTile(
                        key: _tasksListTile,
                        selected: selectedIndex == 3,
                        leading: Icon(Icons.list),
                        title: const Text('Tasks'),
                        onTap: () {
                          // setState(() {
                          //   selectedIndex = 3;
                          // });
                          Navigator.of(context).pushNamed(AppRouter.taskScreen);
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
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: getBody(selectedIndex),
              )
            ],
          ),
        ),
        Positioned(
          left: X,
            top: Y,
            child: CircleAvatar(
          backgroundColor: Colors.red,
        ))
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
