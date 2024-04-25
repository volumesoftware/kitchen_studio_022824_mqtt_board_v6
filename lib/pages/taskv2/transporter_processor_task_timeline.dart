import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/widget/module_items.dart';

class TransporterProcessorTaskTimeline extends StatefulWidget {
  final TransporterProcessor transporterProcessor;

  const TransporterProcessorTaskTimeline({Key? key, required this.transporterProcessor}) : super(key: key);

  @override
  State<TransporterProcessorTaskTimeline> createState() => _TransporterProcessorTaskTimelineState();
}

class _TransporterProcessorTaskTimelineState extends State<TransporterProcessorTaskTimeline> {
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription<ModuleResponse> _stateChange;
  late StreamSubscription<Map<String, dynamic>> _taskChange;

  late Stream<ModuleResponse> heartBeat;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  String? message;
  bool showMessage = false;
  bool isError = false;

  @override
  void initState() {
    heartBeat = widget.transporterProcessor.hearBeat;
    _taskChange = widget.transporterProcessor.taskStream.listen((Map<String, dynamic> event) {
      setState(() {
        // {"operation": 20, "coordinate_x": xCoordinate, "request_title": "User Move X", "requester_name": "User"}
        message = "${event["request_title"]} by ${event["requester_name"]}";
        isError = true;
        showMessage = true;
      });
    });
    _stateChange = widget.transporterProcessor.hearBeat.listen((ModuleResponse stats) {
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
          Duration(seconds: 2),
          () {
            showMessage = false;
          },
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _taskChange.cancel();
    _stateChange.cancel();
    _scrollController.dispose();
    _key.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: StreamBuilder(
          stream: heartBeat,
          builder: (BuildContext context, AsyncSnapshot<ModuleResponse> snapshot) {
            ModuleResponse? moduleResponse = snapshot.data ?? widget.transporterProcessor.getModuleResponse();
            if ((snapshot.data == null) && (widget.transporterProcessor.getModuleResponse().moduleName == null)) {
              return Text('Loading timeline');
            }

            return Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    percentValue: (widget.transporterProcessor.getProgress() ?? 0) * 100,
                                    temperatureValue: moduleResponse.temperature ?? 0.0,
                                    targetTemperatureValue: moduleResponse.targetTemperature ?? 0.0,
                                  ),
                                )
                              : Row(),
                        ],
                      ),
                    )),
                Expanded(
                    flex: 10,
                    child: showMessage
                        ? AvatarGlow(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isError ? Icons.warning : Icons.info,
                                    size: 36,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${message}",
                                    style: Theme.of(context).textTheme.displayMedium,
                                  )
                                ],
                              ),
                            ),
                            endRadius: 25)
                        : Stack(
                            children: [],
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
