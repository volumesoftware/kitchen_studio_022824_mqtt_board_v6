import 'dart:io';
import 'dart:math' as math; // import this
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/user_action_operation.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'package:kitchen_studio_10162023/widgets/thermometers.dart';

class RunningTasks extends StatefulWidget {
  const RunningTasks({Key? key}) : super(key: key);

  @override
  State<RunningTasks> createState() => _RunningTasksState();
}

class _RunningTasksState extends State<RunningTasks> implements UdpListener {
  TaskRunnerPool _taskRunnerPool = TaskRunnerPool.instance;

  List<TaskRunner>? _taskRunners = [];

  @override
  void initState() {
    populateTask();
    var taskRunners = _taskRunnerPool.getTaskRunners();
    if (taskRunners != null) {
      setState(() {
        _taskRunners = taskRunners;
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _taskRunnerPool.removeStatsListener(this);
    super.dispose();
  }

  void populateTask() {
    _taskRunnerPool.addStatsListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.play_for_work_outlined),
        automaticallyImplyLeading: false,
        title: Text("Running Task"),
      ),
      body: listViewBuilder(),
    );
  }

  ListView listViewBuilder() {
    return ListView.builder(
        itemCount: _taskRunners!.length,
        itemBuilder: (context, index) {
          var payload = _taskRunners![index].getPayload();
          var progress = _taskRunners![index].getProgress();
          return RunningTaskItem(
            index: index,
            taskPayload: payload,
            taskRunner: _taskRunners![index],
            itemChanged: itemChaged,
          );
        });
  }

  void itemChaged() {
    List<TaskRunner>? runners = _taskRunnerPool.getTaskRunners();
    if (runners != null) {
      setState(() {
        _taskRunners = runners;
      });
    }
  }

  @override
  void udpData(Datagram? dg) {
    if (dg != null) {
      List<TaskRunner>? runners = _taskRunnerPool.getTaskRunners();
      if (runners != null) {
        setState(() {
          _taskRunners = runners;
        });
      }
    }
  }
}

class RunningTaskItem extends StatefulWidget {
  final int index;
  final TaskPayload? taskPayload;
  final TaskRunner taskRunner;
  final Function itemChanged;

  const RunningTaskItem(
      {Key? key,
      required this.index,
      required this.taskPayload,
      required this.taskRunner,
      required this.itemChanged})
      : super(key: key);

  @override
  State<RunningTaskItem> createState() => _RunningTaskItemState();
}

class _RunningTaskItemState extends State<RunningTaskItem>
    implements TaskListener {
  UdpService udpService = UdpService.instance;
  int index = 0;
  TaskPayload? p;
  TaskRunner? taskRunner;
  double _progress = 0.0;
  DeviceStats? _deviceStats;
  ExpansionTileController _controller = ExpansionTileController();
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  bool manualOpen = false;
  int _instructionIndex = 0;
  UserAction? _userAction;

  @override
  void initState() {
    setState(() {
      index = widget.index;
      p = widget.taskPayload;
      _deviceStats = p?.deviceStats;
      taskRunner = widget.taskRunner;
      taskRunner?.addListeners(this);
    });
    super.initState();
  }

  @override
  void dispose() {
    taskRunner?.removeListeners(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          manualOpen = true;
        });
      },
      child: ExpansionTile(
        controller: _controller,
        children: expandedCard(),
        leading: SizedBox(
          width: 80,
          child: Stack(
            children: [
              Center(
                child: Text("${index + 1}"),
              ),
              Center(
                child: CircularProgressIndicator(
                  value: _progress,
                ),
              )
            ],
          ),
        ),
        title: Text("${_deviceStats?.moduleName}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p?.task.taskName ?? 'No task'),
          ],
        ),
      ),
    );
  }

  List<Widget> expandedCard() {
    if (p == null) return [];

    return [
      Stepper(
        stepIconBuilder: (stepIndex, stepState) {
          if (stepIndex == _instructionIndex) {
            return AvatarGlow(
              child: CircleAvatar(
                child: Text("${stepIndex + 1}"),
              ),
              endRadius: 50,
              glowColor: Colors.red,
            );
          } else
            CircleAvatar(
              child: Text("${stepIndex + 1}"),
            );
          return null;
        },
        controlsBuilder: (BuildContext ctx, ControlsDetails dtl) {
          return p!.operations[dtl.currentStep] is UserActionOperation
              ? ElevatedButton(
            onPressed: () {
              if (_userAction != null) {
                taskRunner?.submitUserRespond(
                    true, _userAction!.currentIndex!);
              }
            },
            child: Text("Continue"),
          )
              : SizedBox();
        },
        currentStep: _instructionIndex,
        steps: p!.operations.map((e) {
          var list = e.toJson().entries.map((e) {
            if (e.key == 'request_id') {
              return SizedBox();
            }
            if (e.key == 'operation') {
              return SizedBox();
            }
            if (e.key == 'recipe_id') {
              return SizedBox();
            }
            if (e.key == 'current_index') {
              return SizedBox();
            }
            if (e.key == 'instruction_size') {
              return SizedBox();
            }
            return Text("${e.key.replaceAll("_", " ")} ${e.value}");
          }).toList();
          return Step(
            title: Text("${e.requestId}"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list,
            ),
          );
        }).toList(),
      )
    ];
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 30,
        initialValue: 0,
        value: _progress,
        axis: GaugeAxis(
            min: 0,
            max: 1,
            degrees: 300,
            style: const GaugeAxisStyle(
              thickness: 5,
              background: Color(0xFFDFE2EC),
              segmentSpacing: 4,
            ),
            progressBar: const GaugeProgressBar.rounded(
              color: Colors.transparent,
            ),
            segments: [
              const GaugeSegment(
                from: 0,
                to: 33.3,
                color: Colors.grey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 33.3,
                to: 50,
                color: Colors.blueGrey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 50,
                to: 80,
                color: Colors.blueAccent,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 80,
                to: 100,
                color: Colors.blue,
                cornerRadius: Radius.zero,
              ),
            ]));
  }

  @override
  void onEvent(String moduleName, message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress,
      required int index,
      UserAction? userAction}) {
    if (moduleName == deviceStats.moduleName) {
      widget.itemChanged();
      temperature.value = (deviceStats.temperature ?? 28) / 200;

      if (busy) {
        // _controller.expand();
      }

      if (userAction != null) {
        setState(() {
          _userAction = userAction;
        });
        _controller.expand();
      }

      setState(() {
        _instructionIndex = index;
        _progress = progress;
        _deviceStats = deviceStats;
        p = taskRunner?.getPayload();
      });
    }
  }

  @override
  void onError(ModuleError error) {
    print(error.error);
  }
}
