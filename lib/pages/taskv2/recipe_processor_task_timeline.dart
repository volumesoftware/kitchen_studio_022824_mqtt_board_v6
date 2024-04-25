import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/app_router.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/running_task_processor.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/widget/module_items.dart';

class RecipeProcessorTaskTimeline extends StatefulWidget {
  final RecipeProcessor recipeProcessor;

  const RecipeProcessorTaskTimeline({Key? key, required this.recipeProcessor}) : super(key: key);

  @override
  State<RecipeProcessorTaskTimeline> createState() => _RecipeProcessorTaskTimelineState();
}

class _RecipeProcessorTaskTimelineState extends State<RecipeProcessorTaskTimeline> {
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<ModuleResponse> _stateChange;
  late Stream<ModuleResponse> heartBeat;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String? message;
  bool showMessage = false;
  bool isError = false;

  @override
  void initState() {
    heartBeat = widget.recipeProcessor.hearBeat;
    _stateChange = widget.recipeProcessor.hearBeat.listen((ModuleResponse stats) {
      if (stats is StirFryResponse) {
        temperature.value = stats.temperature! / 400;
      }

      if (stats.lastError!.isNotEmpty) {
        setState(() {
          message = "${stats.lastError}";
          isError = true;
          showMessage = true;
        });

        Future.delayed(
          const Duration(seconds: 2),
          () {
            showMessage = false;
          },
        );
      }

      Map<String, dynamic>? currentProgress = widget.recipeProcessor.getTaskProgress()?.currentProcess;
      if (currentProgress != null) {
        if (currentProgress['operation'] == InstructionCode.userAction) {
          if (mounted) {
            setState(() {
              isError = false;
              showMessage = true;
              message = currentProgress['message'];
            });
            Future.delayed(
              const Duration(seconds: 2),
              () {
                showMessage = false;
              },
            );
          }
        } else {
          if (mounted) {
            if (showMessage) {
              _key.currentState?.closeDrawer();
              showMessage = false;
            }
          }
        }
      }

      // scrollToIndex(widget.recipeProcessor.getIndexProgress());
    });
    super.initState();
  }

  @override
  void dispose() {
    _stateChange.cancel();
    _scrollController.dispose();
    _key.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: StreamBuilder(
          stream: heartBeat,
          builder: (BuildContext context, AsyncSnapshot<ModuleResponse> snapshot) {
            ModuleResponse? moduleResponse = snapshot.data ?? widget.recipeProcessor.getModuleResponse();
            if ((snapshot.data == null) && (widget.recipeProcessor.getModuleResponse().moduleName == null)) {
              return const Text('Loading timeline');
            }

            return Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${moduleResponse.moduleName}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "${moduleResponse.type}",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        (moduleResponse is StirFryResponse)
                            ? SizedBox(
                                height: 150,
                                child: ModuleItems(
                                  percentValue: (widget.recipeProcessor.getTaskProgress()?.progress ?? 0) * 100,
                                  temperatureValue: moduleResponse.temperature ?? 0.0,
                                  targetTemperatureValue: moduleResponse.targetTemperature ?? 0.0,
                                ),
                              )
                            : const Row(),
                      ],
                    )),
                VerticalDivider(
                  thickness: 0.5,
                ),
                Expanded(
                    flex: 10,
                    child: showMessage
                        ? AvatarGlow(
                            endRadius: 25,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isError ? Icons.warning : Icons.info,
                                    size: 36,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "$message",
                                    style: Theme.of(context).textTheme.displayMedium,
                                  )
                                ],
                              ),
                            ))
                        : Stack(
                            children: [
                              RunningTaskProcessorWidget(recipeProcessor: widget.recipeProcessor),
                              widget.recipeProcessor.getFlattenedInstructions().isEmpty
                                  ? Center(
                                      child: Focus(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pushNamed(AppRouter.searchRecipe, arguments: widget.recipeProcessor);
                                            // var result = await showSearch<Task?>(
                                            //   context: context,
                                            //   delegate: RecipeSearchDelegateV2(
                                            //       widget.recipeProcessor),
                                            // );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(25),
                                            child: Text('Cook Recipe'),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12, style: BorderStyle.solid)),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: LinearProgressIndicator(
                                                  minHeight: 35,
                                                  value: (widget.recipeProcessor.getTaskProgress()?.progress ?? 0) * 100,
                                                ),
                                              ),
                                              Center(
                                                child: Text("Estimated ${timeLeft(widget.recipeProcessor.etaInSeconds)} to completion",
                                                    style: Theme.of(context).textTheme.headlineSmall),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                            ],
                          )),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FilledButton(
                              onPressed: () async {
                                showMessage = true;
                                message = "Priming Water Pump";
                                await widget.recipeProcessor.sendAction({"operation": InstructionCode.primeWater, "current_index": 0, "instruction_size": 0});
                                showMessage = false;
                                message = "";
                              },
                              child: Text("Prime Water")),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton(
                              onPressed: () async {
                                showMessage = true;
                                message = "Priming Oil Pump";
                                await widget.recipeProcessor.sendAction({"operation": InstructionCode.primeOil, "current_index": 0, "instruction_size": 0});
                                showMessage = false;
                                message = "";
                              },
                              child: Text("Prime Oil")),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton(onPressed: () {}, child: Text("Clear Task")),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton(
                              onPressed: () async {
                                showMessage = true;
                                message = "Homing";
                                await widget.recipeProcessor.sendAction({"operation": InstructionCode.zeroing, "current_index": 0, "instruction_size": 0});
                                showMessage = false;
                                message = "";
                              },
                              child: Text("Homing")),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton(
                              onPressed: () async {
                                showMessage = true;
                                message = "Dispensing";
                                await widget.recipeProcessor.sendAction({"operation": InstructionCode.dispense, "current_index": 0, "instruction_size": 0});
                                showMessage = false;
                                message = "";
                              },
                              child: Text("Dispense")),
                          const SizedBox(
                            height: 5,
                          ),
                          FilledButton(
                              onPressed: () async {
                                showMessage = true;
                                message = "Washing";
                                await widget.recipeProcessor
                                    .sendAction({"operation": InstructionCode.wash, "duration": 30, "current_index": 0, "instruction_size": 0});
                                showMessage = false;
                                message = "";
                              },
                              child: Text("Wash")),
                        ],
                      ),
                    ))
              ],
            );
          },
        ),
      ),
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
