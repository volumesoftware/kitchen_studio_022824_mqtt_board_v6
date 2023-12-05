import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/app_router.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_units_page.dart';
import 'package:kitchen_studio_10162023/pages/ingredients/ingredients_page.dart';
import 'package:kitchen_studio_10162023/pages/recipes/recipes_page.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/cooking_units_page.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({Key? key}) : super(key: key);

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen>{


  ThreadPool threadPool = ThreadPool.instance;
  List<RecipeProcessor> _recipeProcessors = [];


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
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: StreamBuilder<List<RecipeProcessor>>(
        stream: threadPool.stateChanges,
        builder: (context, snapshot) {
          return snapshot.data!=null? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: snapshot.data!.map((e) => Column(
              children: [Text("${e.moduleName}"), StreamBuilder(stream: e.stateChanges, builder: (context2, snapshot2) {
                return snapshot2.data!=null? Text("${snapshot2.data?.temperature}") : Text("Loading...");
              },)],
            ) ).toList(),
          ) : Row();
        },
      ),
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
    );
  }

  Widget getBody(int index) {
    switch (index) {
      case 0:
        {
          return CookingUnitsPage();
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
        return CookingUnitsPage();
    }
  }


}
