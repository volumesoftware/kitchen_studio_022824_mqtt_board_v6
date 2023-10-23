import 'dart:io';
import 'dart:math' as math; // import this
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
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
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SearchBar(
              trailing: [Icon(Icons.search)],
            ),
          ),
        ),
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
        trailing: Container(
          width: 80,
          height: 70,
          child: Row(
            children: [
              Text("${_deviceStats?.temperature1?.toStringAsFixed(2)} °C",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 14)),
              Container(
                width: 20,
                child: Thermometer(
                  temperature: temperature,
                ),
              ),
            ],
          ),
        ),
        leading: Text("${index + 1}"),
        title: Text("${_deviceStats?.moduleName}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p?.task.taskName ?? 'No task'),
            LinearProgressIndicator(
              value: _progress,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> expandedCard() {
    if(p == null) return [];
    return p!.operations.map((e) => ListTile(
      title: Text("${e.operation}"),
    )).toList();
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 100,
        initialValue: 0,
        value: _progress,
        axis: GaugeAxis(
            min: 0,
            max: 1,
            degrees: 90,
            style: const GaugeAxisStyle(
              thickness: 10,
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

  Widget temperatureGauge() {
    double? temperature = _deviceStats?.temperature1 ?? 23.00;
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 100,
        value: temperature ?? 0.0,
        initialValue: 50,
        axis: GaugeAxis(
            min: 0,
            max: 400,
            degrees: 180,
            style: const GaugeAxisStyle(
              thickness: 20,
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
                color: Colors.green,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 33.3,
                to: 66.6,
                color: Colors.yellow,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 66.6,
                to: 100,
                color: Colors.orange,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 100,
                to: 300,
                color: Colors.deepOrange,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 300,
                to: 400,
                color: Colors.red,
                cornerRadius: Radius.zero,
              )
            ]));
  }

  @override
  void onEvent(String moduleName, message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress}) {
    if (moduleName == deviceStats.moduleName) {
      widget.itemChanged();
      temperature.value = (deviceStats.temperature1 ?? 28) / 200;
      print("${temperature.value} $moduleName");

      if (busy) {
        _controller.expand();
      }

      setState(() {
        _progress = progress;
        _deviceStats = deviceStats;
        p = taskRunner?.getPayload();
      });
    }
  }
}
