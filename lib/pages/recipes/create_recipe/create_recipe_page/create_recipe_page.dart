import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
import 'package:kitchen_studio_10162023/dao/operation_data_access.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/cold_mix_operation.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/dispense_operation.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/drop_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/flip_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_for_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_until_temperature_operation.dart';
import 'package:kitchen_studio_10162023/model/hot_mix_operation.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/pump_oil_operation.dart';
import 'package:kitchen_studio_10162023/model/pump_water_operation.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/stir_operation.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/model/user_action_operation.dart';
import 'package:kitchen_studio_10162023/model/wash_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/painters/cold_wok_painter.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/painters/hot_wok_painter.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/dispense_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/dock_ingredient_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/drop_ingredient_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/flip_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_at_temperature_until_time_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_until_temperature_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_oil_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_water_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/stirl_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/user_action_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/wash_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/unit_monitoring_card_component.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';

import 'recipe_widgets/cold_mix_widget.dart';
import 'recipe_widgets/hot_mix_widget.dart';

class CreateRecipePage extends StatefulWidget {
  final Recipe recipe;

  const CreateRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage>
    implements RecipeWidgetActions, UdpListener {
  int activeStep = 0;
  DeviceStats? selectedDevice;
  List<DeviceStats> devices = [];
  Timer? timer;
  List<BaseOperation>? instructions = [];
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  TaskRunnerPool taskRunnerPool = TaskRunnerPool.instance;
  UdpService? udpService = UdpService.instance;
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;

  bool manualOpen = false;

  @override
  void dispose() {
    taskRunnerPool.removeStatsListener(this);
    super.dispose();
  }

  @override
  void initState() {
    taskRunnerPool.addStatsListener(this);
    populateOperations();
    super.initState();
  }

  void populateOperations() async {
    var temp = await baseOperationDataAccess
        .search("recipe_id = ?", whereArgs: [widget.recipe.id!]);

    var tempDevices = await taskRunnerPool.getDevices();

    setState(() {
      instructions = temp;

      // instructions.sort((a, b) => a.currentIndex < b.currentIndex,)
      devices = tempDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) {
          setState(() {
            manualOpen = false;
          });
        }
      },
      key: _key,
      appBar: AppBar(
        title: Text("Doodle Recipe (${widget.recipe.recipeName})"),
        actions: [
          PopupMenuButton<DeviceStats>(
            child: Row(
              children: [
                selectedDevice != null
                    ? Text("${selectedDevice!.moduleName}")
                    : Text("Choose module"),
                SizedBox(width: 10),
                Icon(Icons.account_tree_outlined)
              ],
            ),
            onSelected: (DeviceStats result) {
              setState(() {
                selectedDevice = result;
              });
            },
            itemBuilder: (BuildContext context) => devices
                .map((e) => PopupMenuItem<DeviceStats>(
                      value: e,
                      child: Text('${e.moduleName}'),
                    ))
                .toList(),
          ),
          SizedBox(width: 10),
          IconButton(
              onPressed: () {
                setState(() {
                  manualOpen = true;
                });
                _key.currentState?.openEndDrawer();
              },
              icon: Icon(Icons.menu_open))
        ],
      ),
      endDrawer: selectedDevice != null
          ? Container(
              width: 300,
              height: 350,
              child: UnitMonitoringCardComponent(
                deviceStats: selectedDevice!,
                onTestRecipe: () async {
                  var taskRunner = TaskRunnerPool.instance
                      .getTaskRunner(selectedDevice!.moduleName!);
                  Task task = Task(
                      progress: 0,
                      recipeName: widget.recipe.recipeName,
                      moduleName: selectedDevice?.moduleName,
                      recipeId: widget.recipe.id,
                      taskName: "Recipe doodling test",
                      status: Task.CREATED);
                  int? taskId = await taskDataAccess.create(task);
                  if (taskId != null) {
                    Task? task = await taskDataAccess.getById(taskId);
                    if (task != null) {
                      await taskRunner?.submitTask(TaskPayload(
                          widget.recipe, instructions!, selectedDevice!, task));
                    }
                  }
                },
              ),
            )
          : SizedBox(),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.15,
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 50),
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(
                                  widget.recipe.imageFilePath ??
                                      "assets/images/img.png")))),
                    ),
                    ListTile(
                      leading: Stack(
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                          )
                        ],
                      ),
                      title: const Text('User Action'),
                      onTap: () {
                        setState(() {
                          onSave(UserActionOperation(
                            isClosing: false,
                            currentIndex: instructions!.length,
                            targetTemperature: 20,
                          ));
                        });
                      },
                    ),
                    ListTile(
                      leading: Stack(
                        children: [
                          Icon(
                            Icons.thermostat,
                          )
                        ],
                      ),
                      title: const Text('Heat'),
                      subtitle: Text(
                        "Heating won't stop until temperature is reached",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        setState(() {
                          onSave(HeatUntilTemperatureOperation(
                              currentIndex: instructions!.length,
                              targetTemperature: 20));
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
                      title: const Text('Timeout heat'),
                      subtitle: Text(
                        "Heating won't stop until timeout",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        setState(() {
                          setState(() {
                            onSave(HeatForOperation(
                                currentIndex: instructions!.length,
                                duration: 6,
                                targetTemperature: 20));
                          });
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.waves_sharp,
                      ),
                      title: const Text('Wash'),
                      // subtitle:  Text("Heating won't stop until timeout", style: Theme.of(context).textTheme.bodySmall,),
                      onTap: () {
                        setState(() {
                          setState(() {
                            onSave(WashOperation(
                                currentIndex: instructions!.length,
                                duration: 6,
                                cycle: 1,
                                targetTemperature: 20));
                          });
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.account_tree_outlined),
                      title: const Text('Dispense'),
                      onTap: () {
                        setState(() {
                          setState(() {
                            onSave(DispenseOperation(
                                currentIndex: instructions!.length,
                                cycle: 1,
                                targetTemperature: 20));
                          });
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.flip_camera_android),
                      title: const Text('Flip'),
                      onTap: () {
                        setState(() {
                          onSave(FlipOperation(
                              currentIndex: instructions!.length,
                              cycle: 1,
                              interval: 2,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.ads_click_outlined),
                      title: const Text('Stir Operation'),
                      onTap: () {
                        setState(() {
                          onSave(StirOperation(
                              currentIndex: instructions!.length,
                              duration: 15000,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: CustomPaint(
                        painter: ColdWokPainter(),
                      ),
                      title: const Text('Cold Mix Operation'),
                      onTap: () {
                        setState(() {
                          onSave(ColdMixOperation(
                              currentIndex: instructions!.length,
                              duration: 15000,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: CustomPaint(
                        painter: HotWokPainter(),
                      ),
                      title: const Text('Hot Mix Operation'),
                      onTap: () {
                        setState(() {
                          onSave(HotMixOperation(
                              currentIndex: instructions!.length,
                              duration: 15000,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.water_drop),
                      title: const Text('Pump Oil'),
                      onTap: () {
                        setState(() {
                          onSave(PumpOilOperation(
                              currentIndex: instructions!.length,
                              duration: 10,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.water_drop_outlined),
                      title: const Text('Pump Water'),
                      onTap: () {
                        setState(() {
                          onSave(PumpWaterOperation(
                              currentIndex: instructions!.length,
                              duration: 10,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.dock_sharp),
                      enabled: false,
                      subtitle: const Text('Coming soon'),
                      title: const Text('Dock Ingredient'),
                      onTap: () {
                        setState(() {
                          onSave(DockIngredientOperation(
                              currentIndex: instructions!.length,
                              targetTemperature: 20));
                        });
                      },
                    ),
                    ListTile(
                      enabled: false,
                      subtitle: const Text('Coming soon'),
                      leading: Icon(Icons.publish_sharp),
                      title: const Text('Drop Ingredient'),
                      onTap: () {
                        setState(() {
                          onSave(DropIngredientOperation(
                              currentIndex: instructions!.length,
                              targetTemperature: 20,
                              cycle: 3));
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                itemCount: instructions!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, childAspectRatio: .8),
                itemBuilder: (context, index) {
                  instructions![index].currentIndex = index;
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          getInstructionWidget(instructions![index]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //     onPressed: () {},
      //     label: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [Text("Save Recipe"), Icon(Icons.save)],
      //     )),
    );
  }

  void removeOperation(int index) {
    setState(() {
      instructions!.remove(instructions![index]);
    });
    for (var i = 0; i < instructions!.length; i++) {
      setState(() {
        instructions![i].currentIndex = i;
      });
    }
  }

  Widget getInstructionWidget(BaseOperation instruction) {
    if (instruction.operation == HeatUntilTemperatureOperation.CODE) {
      return HeatUntilTemperatureWidget(
        operation: instruction as HeatUntilTemperatureOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == HeatForOperation.CODE) {
      return HeatAtTemperatureUntilTimeWidget(
        operation: instruction as HeatForOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == WashOperation.CODE) {
      return WashWidget(
        operation: instruction as WashOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == DispenseOperation.CODE) {
      return DispenseWidget(
        operation: instruction as DispenseOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == FlipOperation.CODE) {
      return FlipWidget(
        operation: instruction as FlipOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == PumpOilOperation.CODE) {
      return PumpOilWidget(
        operation: instruction as PumpOilOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == PumpWaterOperation.CODE) {
      return PumpWaterWidget(
        operation: instruction as PumpWaterOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == DockIngredientOperation.CODE) {
      return DockIngredientWidget(
        operation: instruction as DockIngredientOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == DropIngredientOperation.CODE) {
      return DropIngredientWidget(
        operation: instruction as DropIngredientOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == ColdMixOperation.CODE) {
      return ColdMixOperationWidget(
        operation: instruction as ColdMixOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == HotMixOperation.CODE) {
      return HotMixOperationWidget(
        operation: instruction as HotMixOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == StirOperation.CODE) {
      return StirOperationWidget(
        operation: instruction as StirOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == UserActionOperation.CODE) {
      return UserActionWidget(
        operation: instruction as UserActionOperation,
        recipeWidgetActions: this,
      );
    }
    return Container(
      child: Text("Undefined Component"),
    );
  }

  void onSave(BaseOperation operation) async {
    populateOperations();
    operation.recipeId = widget.recipe.id;
    await baseOperationDataAccess.create(operation);
    populateOperations();
  }

  @override
  void onDelete(BaseOperation operation) {
    var json = operation.toJson();
    json['id'] = operation.id;
    print("Deleteing ${json}");
    baseOperationDataAccess
        .delete(operation.id!)
        .then((value) => populateOperations());
  }

  @override
  void onValueUpdate(BaseOperation operation) {
    baseOperationDataAccess
        .updateById(operation.id!, operation)
        .then((value) => populateOperations());
  }

  @override
  Future<void> onTest(BaseOperation operation) async {
    if (selectedDevice == null) {
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("No Device Selected"),
                    Icon(Icons.warning),
                  ],
                ),
                content: Container(
                  height: 100,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Please select a device in order to test this operation")
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('OK'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    udpService?.send(jsonEncode(operation.toJson()).codeUnits,
        InternetAddress(selectedDevice!.ipAddress!), 8888);
  }

  @override
  void udpData(Datagram? dg) {
    if (dg != null) {
      populateOperations();

      devices.forEach((device) {
        if (selectedDevice != null) {
          if (selectedDevice?.ipAddress == device.ipAddress) {
            setState(() {
              selectedDevice = device;
              if (!manualOpen) {
                if (selectedDevice?.requestId != 'idle') {
                  _key.currentState?.openEndDrawer();
                } else {
                  _key.currentState?.closeEndDrawer();
                }
              }
            });
          }
        }
      });
    }
  }
}
