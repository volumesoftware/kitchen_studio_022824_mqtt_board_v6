import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/operation_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/dispense_operation.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/drop_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/flip_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_for_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_until_temperature_operation.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/pump_oil_operation.dart';
import 'package:kitchen_studio_10162023/model/pump_water_operation.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/wash_operation.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/dispense_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/dock_ingredient_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/drop_ingredient_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/flip_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_at_temperature_until_time_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/heat_until_temperature_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_oil_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/pump_water_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget_action.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/wash_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/unit_monitoring_card_component.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:kitchen_studio_10162023/service/recipe_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CreateRecipePage extends StatefulWidget {
  final Recipe recipe;

  const CreateRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage>
    implements RecipeWidgetActions, UdpListener {
  int activeStep = 0;
  UdpService? udpService = UdpService.instance;
  DeviceStats? selectedDevice;
  Database? connectedDatabase;
  List<DeviceStats> devices = [];
  Timer? timer;
  List<BaseOperation>? instructions = [];
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  BaseOperationDataAccess baseOperationDataAccess = BaseOperationDataAccess
      .instance;

  bool manualOpen = false;

  @override
  void dispose() {
    udpService?.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    UdpService.instance.addListener(this);

    var instance = DatabaseService.instance;
    connectedDatabase = instance.connectedDatabase;
    try {
      connectedDatabase?.query('DeviceStats').then(
            (value) {
          if (value.isNotEmpty) {
            for (var mappedUnits in value) {
              setState(() {
                devices.add(DeviceStats.fromDatabase(mappedUnits));
              });
            }
          }
        },
      );
    } catch (e) {}

    String jsonData = '{"operation":100}';
    udpService?.send(
        jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
    timer = Timer.periodic(
      Duration(seconds: 3),
          (timer) {
        udpService?.send(
            jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
      },
    );

    populateOperations();

    super.initState();
  }

  void populateOperations() async {
    var temp = await baseOperationDataAccess.search(
        "recipe_id = ?", whereArgs: [widget.recipe.id!]);
    print(temp);
    setState(() {
      instructions = temp;
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
            itemBuilder: (BuildContext context) =>
                devices
                    .map((e) =>
                    PopupMenuItem<DeviceStats>(
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
        width: 400,
        height: 450,
        child: UnitMonitoringCardComponent(
          udpSocket: udpService?.udp,
          deviceStats: selectedDevice!,
          onTestRecipe: () async{
            // @todo recipeRunner
            await recipeRunner(widget.recipe, instructions!, selectedDevice!);
          },
        ),
      )
          : SizedBox(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.2,
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 50),
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(widget.recipe.imageFilePath ??
                                "assets/images/img.png")))),
                  ),
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
                    title: const Text('Heat At Temperature, Until Time'),
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
                        onSave(PumpOilOperation(
                            currentIndex: instructions!.length,
                            duration: 10,
                            targetTemperature: 20));
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dock_sharp),
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
            width: MediaQuery
                .of(context)
                .size
                .width * 0.74,
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: GridView.builder(
              itemCount: instructions!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, childAspectRatio: 1),
              itemBuilder: (context, index) {
                instructions![index].currentIndex = index;

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: getInstructionWidget(instructions![index]),
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
    }
    return Container(
      child: Text("Undefined Component"),
    );
  }

  void onSave(BaseOperation operation) async {
    operation.recipeId = widget.recipe.id;
    await baseOperationDataAccess.create(operation);

    populateOperations();

    for (var i = 0; i < instructions!.length; i++) {
      setState(() {
        instructions![i].currentIndex = i;
      });
    }
  }

  @override
  void onDelete(BaseOperation operation) {
    baseOperationDataAccess.delete(operation.id!).then((value) => populateOperations());
  }

  @override
  void onValueUpdate(BaseOperation operation) {
    baseOperationDataAccess.updateById(operation.id!, operation).then((value) => populateOperations());
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
      String result = String.fromCharCodes(dg.data);
      DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
      bool newItem = true;
      devices.forEach((element) {
        var indexOf = devices.indexOf(element);
        if (element.ipAddress == incomingStats.ipAddress) {
          setState(() {
            devices[indexOf] = incomingStats;
          });
          newItem = false;
        }
      });
      if (selectedDevice != null) {
        if (selectedDevice?.ipAddress == incomingStats.ipAddress) {
          setState(() {
            selectedDevice = incomingStats;

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

      if (newItem)
        setState(() {
          devices.add(incomingStats);
        });
      devices.forEach((unit) async {
        try {
          if (connectedDatabase != null) {
            var list = await connectedDatabase!.query('DeviceStats',
                where: 'ip_address = ?', whereArgs: [unit.ipAddress]);
            if (list.isEmpty) {
              await connectedDatabase!.insert('DeviceStats', {
                'ip_address': unit.ipAddress,
                'port': unit.port,
                'module_name': unit.moduleName,
                'type': unit.type,
                'v5': unit.v5,
                'code': unit.code,
                'request_id': unit.requestId,
                'memory_usage': unit.memoryUsage,
                'progress': unit.progress,
                'water_valve_open': unit.waterValveOpen == true ? 1 : 0,
                'water_jet_open': unit.waterJetOpen == true ? 1 : 0,
                'temperature_1': unit.temperature1,
                'temperature_2': unit.temperature2,
                'current_local_time': unit.currentLocalTime,
                'local_time_max': unit.localTimeMax,
                'machine_time': unit.machineTime,
                'target_temperature': unit.targetTemperature,
                'instruction_size': unit.instructionSize
              });
            }
          }
        } catch (e) {}
      });
    }
  }
}
