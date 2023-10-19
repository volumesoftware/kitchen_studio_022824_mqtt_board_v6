import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/dispense_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/flip_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_at_temperature_until_time_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_until_temperature_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_oil_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_water_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/wash_widget.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({Key? key}) : super(key: key);

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  int activeStep = 0;

  List<BaseInstructions> instructions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Recipe"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.2,
              child: ListView(
                children: [
                  ListTile(
                    leading: Stack(
                      children: [
                        Icon(
                          Icons.thermostat,
                        )
                      ],
                    ),
                    title: const Text('Heat Until Temperature'),
                    onTap: () {
                      setState(() {
                        instructions.add(HeatUntilTemperatureOperation(currentIndex: instructions.length -1, targetTemperature: 20));
                      });
                    },
                  ),
                  ListTile(
                    leading: Stack(
                      children: [
                        Icon(
                          Icons.thermostat_auto_outlined,
                        )
                      ],
                    ),
                    title: const Text('Heat At Temperature, Until Time'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.waves_sharp,
                    ),
                    title: const Text('Wash'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.account_tree_outlined),
                    title: const Text('Dispense'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.flip_camera_android),
                    title: const Text('Flip'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.water_drop),
                    title: const Text('Pump Oil'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.water_drop_outlined),
                    title: const Text('Pump Water'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dock_sharp),
                    title: const Text('Dock Ingredient'),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.publish_sharp),
                    title: const Text('Drop Ingredient'),
                    onTap: () {
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.74,
            height: MediaQuery.of(context).size.height,
            child: GridView.builder(
              itemCount: instructions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, childAspectRatio: 0.9),
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: getInstructionWidget(instructions[index], index),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Save Recipe"), Icon(Icons.save)],
          )),
    );
  }

  Widget getInstructionWidget(BaseInstructions instruction, int index) {
    if (instruction.operation == HeatUntilTemperatureOperation.CODE) {
      HeatUntilTemperatureWidget wi = HeatUntilTemperatureWidget(
        onValueUpdate: (int idx, double targetTemperature) {},
        index: index,
      );
      return HeatUntilTemperatureWidget(
        onValueUpdate: (int idx, double targetTemperature) {},
        index: index,
      );
    } else if (instruction.operation == HeatForOperation.CODE) {
      return HeatAtTemperatureUntilTimeWidget(
        onValueUpdate: (int idx, double targetTemperature, double duration) {},
        index: index,
      );
    } else if (instruction.operation == WashOperation.CODE) {
      return WashWidget(
        onValueUpdate:
            (int idx, double targetTemperature, double duration, int cycle) {},
        index: index,
      );
    } else if (instruction.operation == DispenseOperation.CODE) {
      return DispenseWidget(
        onValueUpdate: (int idx, double targetTemperature, int cycle) {},
        index: index,
      );
    } else if (instruction.operation == FlipOperation.CODE) {
      return FlipWidget(
        onValueUpdate: (int idx, double targetTemperature, int intervalDelay,
            int cycle) {},
        index: index,
      );
    } else if (instruction.operation == PumpOilOperation.CODE) {
      return PumpOilWidget(
        onValueUpdate: (int idx, double targetTemperature, double duration) {},
        index: index,
      );
    } else if (instruction.operation == PumpWaterOperation.CODE) {
      return PumpWaterWidget(
        onValueUpdate: (int idx, double targetTemperature, double duration) {},
        index: index,
      );
    }
    return Container(
      child: Text("Undefined Component"),
    );
  }
}
