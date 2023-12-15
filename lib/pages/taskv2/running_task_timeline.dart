import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/recipe_search_delegate_v2.dart';
import 'package:kitchen_studio_10162023/widgets/thermometers.dart';

class RunningTaskTimelineWidget extends StatefulWidget {
  final RecipeProcessor recipeProcessor;

  RunningTaskTimelineWidget({Key? key, required this.recipeProcessor})
      : super(key: key);

  @override
  State<RunningTaskTimelineWidget> createState() =>
      _RunningTaskTimelineWidgetState();
}

class _RunningTaskTimelineWidgetState extends State<RunningTaskTimelineWidget> {
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<DeviceStats> _stateChange;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late Stream<DeviceStats> heartBeat;

  String? message;

  @override
  void initState() {
    heartBeat = widget.recipeProcessor.hearBeat;
    _stateChange = widget.recipeProcessor.hearBeat.listen((DeviceStats stats) {
      temperature.value = stats.temperature! / 400;

      if (stats.lastError!.isNotEmpty) {
        setState(() {
          message = "${stats.lastError}";
        });
        _key.currentState?.openDrawer();

        Future.delayed(
          Duration(seconds: 2),
          () {
            _key.currentState?.closeDrawer();
          },
        );
      }

      BaseOperation? currentOperation =
          widget.recipeProcessor.getCurrentOperation();
      if (currentOperation != null) {
        if (currentOperation.operation == UserActionOperation.CODE) {
          UserActionOperation op = currentOperation as UserActionOperation;
          if (mounted) {
            setState(() {
              message = op.message;
            });
            _key.currentState?.openDrawer();
          }
        } else {
          if (mounted) {
            if (_key.currentState!.isDrawerOpen) {
              _key.currentState?.closeDrawer();
            }
          }
        }
      }

      scrollToIndex(widget.recipeProcessor.getIndexProgress());
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

  void scrollToIndex(int index) {
    _scrollController.animateTo(
      index *
          MediaQuery.of(context).size.width *
          0.05, // Replace ITEM_WIDTH with your item's width
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: heartBeat,
      builder: (context, snapshot) {
        if ((snapshot.data == null) &&
            (widget.recipeProcessor.getDeviceStats().moduleName == null)) {
          return Text('Loading timeline');
        }
        DeviceStats? deviceStats = snapshot.data;

        return Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.24,
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width * 0.12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${deviceStats?.moduleName}",
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              // Text(
                              //   "${deviceStats.ipAddress}",
                              //   style: Theme.of(context).textTheme.bodyMedium,
                              // ),
                              Text(
                                "${deviceStats?.temperature?.toStringAsFixed(2)}°C",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent),
                              ),
                              Text(
                                "${deviceStats?.targetTemperature?.toStringAsFixed(2)}°C",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.watch_later_outlined),
                                  Text(
                                    "${timeLeft(widget.recipeProcessor.etaInSeconds)}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    ThreadPool.instance
                                        .pop(widget.recipeProcessor);

                                    setState(() {
                                      message = "Please restart the module";
                                    });
                                    _key.currentState?.openDrawer();
                                    Future.delayed(
                                        const Duration(milliseconds: 15000),
                                        () {
                                      setState(() {
                                        message = "";
                                        _key.currentState?.closeDrawer();
                                      });
                                    });
                                  },
                                  child: Text(
                                    "Stop & clear cache",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ))
                            ],
                          ),
                          Container(
                            width: 25,
                            height: 130,
                            child: Thermometer(
                              temperature: temperature,
                            ),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: widget.recipeProcessor.noStateChange
                              ? Colors.orange
                              : Theme.of(context).colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.circular(10))),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.01),
                        borderRadius: BorderRadius.circular(10)),
                    child: Scaffold(
                      key: _key,
                      drawer: Drawer(
                        width: double.infinity,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Center(
                          child: Text(
                            "${message}",
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      body: Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: (widget.recipeProcessor
                                          .getPayload()
                                          ?.operations ??
                                      [])
                                  .map((e) {
                                double? currentProgress = ((widget
                                                .recipeProcessor
                                                .getDeviceStats()
                                                .currentLocalTime ??
                                            0)
                                        .toDouble()) /
                                    ((widget.recipeProcessor
                                                .getDeviceStats()
                                                .localTimeMax ??
                                            0)
                                        .toDouble());

                                if (currentProgress.isNaN ||
                                    currentProgress.isInfinite ||
                                    currentProgress == 0 ||
                                    currentProgress > 1) {
                                  currentProgress = null;
                                }

                                List<Widget> informations = [
                                  Text(
                                    "${e.requestId}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 100,
                                    child: LinearProgressIndicator(
                                      value: currentProgress,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ];
                                informations.addAll(e.toJson().entries.map((f) {
                                  if (f.key == 'request_id') {
                                    return SizedBox();
                                  }
                                  if (f.key == 'operation') {
                                    return SizedBox();
                                  }
                                  if (f.key == 'recipe_id') {
                                    return SizedBox();
                                  }
                                  if (f.key == 'current_index') {
                                    return SizedBox();
                                  }
                                  if (f.key == 'instruction_size') {
                                    return SizedBox();
                                  }
                                  return Text(
                                      "${f.key.replaceAll("_", " ")} ${f.value}");
                                }).toList());

                                return e.currentIndex ==
                                        widget.recipeProcessor
                                            .getIndexProgress()
                                    ? Stack(
                                        children: [
                                          Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            margin: EdgeInsets.all(5),
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child:
                                                Column(children: informations),
                                          ),
                                          Container(
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue
                                                      .withOpacity(0.2),
                                                  // Change the glow color here
                                                  blurRadius: 10,
                                                  // Adjust the blur radius
                                                  spreadRadius:
                                                      3, // Adjust the spread radius
                                                  // You can also use 'BoxShape.circle' for circular containers
                                                ),
                                              ],
                                            ),
                                            margin: EdgeInsets.all(5),
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Column(
                                              children: informations,
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                            color: e.currentIndex ==
                                                    widget.recipeProcessor
                                                        .getIndexProgress()
                                                ? Colors.red
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              "${e.requestId}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        ),
                                      );
                              }).toList(),
                            ),
                          ),
                          (widget.recipeProcessor.getPayload()?.operations ??
                                      [])
                                  .isEmpty
                              ? Center(
                                  child: Focus(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        var result = await showSearch<Task?>(
                                          context: context,
                                          delegate: RecipeSearchDelegateV2(
                                              widget.recipeProcessor),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(25),
                                        child: Text('Cook Recipe'),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.2,
                  )
                ],
              ),
            ),
          ],
        );
      },
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
