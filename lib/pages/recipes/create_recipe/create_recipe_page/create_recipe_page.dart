import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/advanced_control_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget.dart';
import 'package:kitchen_studio_10162023/service/globla_loader_service.dart';

class CreateRecipePage extends StatefulWidget {
  final Recipe recipe;

  const CreateRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage>
    implements RecipeWidgetActions {
  int activeStep = 0;
  RecipeProcessor? recipeProcessor;
  List<RecipeProcessor> recipeProcessors = [];
  Timer? timer;
  List<BaseOperation> instructions = [];
  List<BaseOperation> presets = [];
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  ThreadPool threadPool = ThreadPool.instance;

  UdpService? udpService = UdpService.instance;
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  bool showAddBetweenButton = false;
  bool manualOpen = false;
  TextEditingController _presetSearchController = TextEditingController();

  late StreamSubscription<List<RecipeProcessor>> listen;

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  void initState() {
    populateOperations();
    listen = threadPool.stateChanges
        .listen((List<RecipeProcessor> recipeProcessors) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          recipeProcessors = threadPool.pool;
        });
      });
    });
    super.initState();
  }

  void populateOperations() async {
    GlobalLoaderService.instance.showLoading();
    List<BaseOperation> tempOperations = await baseOperationDataAccess.search(
            "recipe_id = ?",
            whereArgs: [widget.recipe.id!],
            orderBy: 'current_index ASC') ??
        [];
    List<BaseOperation> tempPresets = await baseOperationDataAccess
            .search("recipe_id = ?", whereArgs: [-1]) ??
        [];

    for (var i = 0; i < tempOperations.length; i++) {
      tempOperations[i].currentIndex = i;
      await baseOperationDataAccess.updateById(
          tempOperations[i].id!, tempOperations[i]);
    }

    tempOperations = await baseOperationDataAccess.search("recipe_id = ?",
            whereArgs: [widget.recipe.id!], orderBy: 'current_index ASC') ??
        [];

    setState(() {
      presets = tempPresets;
      instructions = tempOperations;
    });
    GlobalLoaderService.instance.hideLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _key,
          onEndDrawerChanged: (isOpened) {
            if (!isOpened) {
              setState(() {
                manualOpen = false;
              });
            }
          },
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text("Doodle Recipe (${widget.recipe.recipeName})"),
          ),
          drawer: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.24,
            height: MediaQuery.of(context).size.height,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: TextField(
                  controller: _presetSearchController,
                  onChanged: (value) async {
                    if (value.isEmpty) {
                      populateOperations();
                    } else {
                      print(value);
                      var filteredPreset = await baseOperationDataAccess.search(
                          "preset_name like ? and recipe_id = ?",
                          whereArgs: ["%$value%", -1]);
                      print(filteredPreset);
                      setState(() {
                        presets = filteredPreset ?? [];
                      });
                    }
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Heat ...',
                      label: Text("Search Presets")),
                ),
              ),
              body: presets.isEmpty
                  ? Center(
                      child: Text("No presets available"),
                    )
                  : ListView(
                      children: presets
                          .map((e) => ListTile(
                                subtitle: Text("${e.requestId}"),
                                title: Text("${e.presetName}"),
                                leading: Icon(e.iconData),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () async {
                                    await baseOperationDataAccess.delete(e.id!);
                                    populateOperations();
                                  },
                                ),
                                onTap: () async {
                                  setState(() {
                                    e.currentIndex = instructions.length;
                                    e.recipeId = widget.recipe.id;
                                  });
                                  if (e is AdvancedOperation) {
                                    int? savedOpId = await onSave(e);
                                    AdvancedOperation?
                                        selectedAdvancedOperation =
                                        (await baseOperationDataAccess.getById(
                                            e.id!)) as AdvancedOperation?;
                                    selectedAdvancedOperation?.controlItems
                                        .forEach((element) {
                                      element.operationId = savedOpId;
                                      AdvancedOperationItemDataAccess.instance
                                          .create(element);
                                    });
                                  } else {
                                    onSave(e);
                                  }
                                  Navigator.of(context).pop();
                                  _presetSearchController.clear();
                                },
                              ))
                          .toList(),
                    ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Card(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.settings_applications),
                          title: Text("Preset"),
                          subtitle: Text("Load Saved Presets"),
                          onTap: () async {
                            populateOperations();
                            _key.currentState?.openDrawer();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.label),
                          title: const Text('Advanced Control'),
                          onTap: () {
                            setState(() {
                              onSave(AdvancedOperation(
                                  currentIndex: instructions.length,
                                  targetTemperature: 35));
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Stack(
                            children: [
                              Icon(
                                Icons.person,
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
                                  tiltAngleA: 90,
                                  targetTemperature: 20));
                            });
                          },
                        ),
                        ListTile(
                          leading: Stack(
                            children: [
                              Icon(
                                Icons.share_arrival_time_outlined,
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
                                    currentIndex: instructions.length,
                                    duration: 6,
                                    tiltAngleA: 90,
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
                                    tiltAngleA: 45,
                                    tiltAngleB: 15,
                                    rotateAngle: 270,
                                    rotateSpeed: 0,
                                    tiltSpeed: 0,
                                    targetTemperature: 20));
                              });
                            });
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.eject),
                          title: const Text('Dispense'),
                          onTap: () {
                            setState(() {
                              setState(() {
                                onSave(DispenseOperation(
                                    currentIndex: instructions!.length,
                                    cycle: 1,
                                    targetTemperature: 20,
                                    tiltAngleB: -30,
                                    tiltAngleA: 15,
                                    tiltSpeed: 0,
                                    rotateSpeed: 0));
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
                                  tiltAngleA: -15,
                                  tiltAngleB: 95,
                                  targetTemperature: 20,
                                  tiltSpeed: 0,
                                  rotateSpeed: 0));
                            });
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.severe_cold),
                          title: const Text('Cold Mix'),
                          onTap: () {
                            setState(() {
                              onSave(ColdMixOperation(
                                  currentIndex: instructions!.length,
                                  duration: 15,
                                  tiltAngleA: 45,
                                  tiltAngleB: 15,
                                  rotateAngle: 270,
                                  targetTemperature: 20));
                            });
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.heat_pump_outlined),
                          title: const Text('Hot Mix'),
                          onTap: () {
                            setState(() {
                              onSave(HotMixOperation(
                                  currentIndex: instructions!.length,
                                  duration: 15,
                                  targetTemperature: 20,
                                  tiltAngleA: 150,
                                  tiltAngleB: 35,
                                  rotateAngle: 270));
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
                          leading: Icon(Icons.repeat),
                          title: const Text('Repeat'),
                          onTap: () {
                            setState(() {
                              onSave(RepeatOperation(
                                  currentIndex: instructions!.length,
                                  repeatIndex: 0,
                                  repeatCount: 0));
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
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height,
                  child: instructions.isEmpty
                      ? Center(
                          child: Text("Please add instructions"),
                        )
                      : DraggableGridViewBuilder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 0.8,
                          ),
                          children: instructions
                              .map((item) => _buildItem(context, item))
                              .toList(),
                          isOnlyLongPress: true,
                          dragCompletion: (List<DraggableGridItem> list,
                              int beforeIndex, int afterIndex) async {
                            print('onDragAccept: $beforeIndex -> $afterIndex');
                            print(instructions[beforeIndex].requestId);
                            print(instructions[afterIndex].requestId);
                            instructions[beforeIndex].currentIndex = afterIndex;
                            instructions[afterIndex].currentIndex = beforeIndex;
                            await baseOperationDataAccess.updateById(
                                instructions[beforeIndex].id!,
                                instructions[beforeIndex]);
                            await baseOperationDataAccess.updateById(
                                instructions[afterIndex].id!,
                                instructions[afterIndex]);
                            populateOperations();
                          },
                          dragFeedback:
                              (List<DraggableGridItem> list, int index) {
                            return Container(
                              child: list[index].child,
                            );
                          },
                          dragPlaceHolder:
                              (List<DraggableGridItem> list, int index) {
                            return PlaceHolderWidget(
                              child: Container(
                                color: Theme.of(context).colorScheme.primary,
                                child: list[index].child,
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          ),
        ),
        StreamBuilder(
          stream: GlobalLoaderService.instance.loaderState,
          builder: (context, snapshot) {
            return snapshot.data ?? GlobalLoaderService.instance.show
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: null,
                      ),
                    ),
                  )
                : Row();
          },
        )
      ],
    );
  }

  DraggableGridItem _buildItem(BuildContext context, BaseOperation e) {
    return DraggableGridItem(
        isDraggable: true,
        child: SizedBox(
          height: 200,
          width: 200,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: getInstructionWidget(e),
            ),
          ),
        ));
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
    } else if (instruction.operation == RepeatOperation.CODE) {
      return RepeatWidget(
        operation: instruction as RepeatOperation,
        recipeWidgetActions: this,
      );
    } else if (instruction.operation == AdvancedOperation.CODE) {
      return AdvancedControlWidget(
        operation: instruction as AdvancedOperation,
        recipeWidgetActions: this,
      );
    }
    return Container(
      child: Text("Undefined Component"),
    );
  }

  void refreshPage() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          CreateRecipePage(recipe: widget.recipe),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }

  Future<int?> onSave(BaseOperation operation) async {
    GlobalLoaderService.instance.showLoading();
    operation.recipeId = widget.recipe.id;
    int? savedId = await baseOperationDataAccess.create(operation);
    populateOperations();
    GlobalLoaderService.instance.hideLoading();
    return savedId;
  }

  @override
  Future<void> onDelete(BaseOperation operation) async {
    await baseOperationDataAccess.delete(operation.id!);
    refreshPage();
  }

  @override
  void onValueUpdate(BaseOperation operation) async {
    await baseOperationDataAccess.updateById(operation.id!, operation);
    refreshPage();
  }

  @override
  Future<void> onTest(BaseOperation operation) async {
    if (recipeProcessor == null) {
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
        InternetAddress(recipeProcessor!.getDeviceStats().ipAddress!), 8888);
  }

  TextEditingController _presetNameController = TextEditingController();

  Future<void> _displayTextInputDialog(
      BuildContext context, BaseOperation operation,
      {dynamic child}) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('PresetName'),
          content: TextField(
            controller: _presetNameController,
            decoration: InputDecoration(hintText: "Text Field in Dialog"),
          ),
          actions: <Widget>[
            FilledButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () async {
                GlobalLoaderService.instance.showLoading();
                operation.recipeId = -1;
                operation.presetName = _presetNameController.text;
                int? createdId =
                    await baseOperationDataAccess.create(operation);

                if (createdId != null) {
                  if (operation is AdvancedOperation) {
                    print('is advanced operation');
                    List<AdvancedOperationItem> items = child;
                    for (var value in items) {
                      value.operationId = createdId;
                      await AdvancedOperationItemDataAccess.instance
                          .create(value);
                      print(value);
                    }
                  }
                }
                refreshPage();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void onPresetSave(BaseOperation operation, {dynamic child}) {
    _displayTextInputDialog(context, operation, child: child);
  }
}
