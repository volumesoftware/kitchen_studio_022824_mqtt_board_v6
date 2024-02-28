import 'dart:io';
import 'dart:math' as math; // import this
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/widgets/thermometers.dart';
import 'package:kitchen_module/kitchen_module.dart';

class UnitMonitoringCardComponent extends StatefulWidget {
  final RecipeProcessor recipeProcessor;
  final Function onTestRecipe;

  const UnitMonitoringCardComponent(
      {Key? key, required this.recipeProcessor, required this.onTestRecipe})
      : super(key: key);

  @override
  State<UnitMonitoringCardComponent> createState() =>
      _UnitMonitoringCardComponentState();
}

class _UnitMonitoringCardComponentState
    extends State<UnitMonitoringCardComponent> {
  UdpService udpService = UdpService.instance;

  ThreadPool threadPool = ThreadPool.instance;
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  double _progress = 0.0;
  bool _busy = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: StreamBuilder(
        stream: widget.recipeProcessor.hearBeat,
        builder: (BuildContext context, AsyncSnapshot<ModuleResponse> snapshot) {

          ModuleResponse moduleResponse = snapshot.data ?? widget.recipeProcessor.getModuleResponse();

          return Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${moduleResponse.moduleName}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    PopupMenuButton<String>(
                      enabled: moduleResponse.requestId == 'idle',
                      icon: Icon(Icons.filter_list),
                      onSelected: (String result) {
                        switch (result) {
                          case 'zero':
                            String jsonData =
                                '{"operation":"199","request_id":"zeroing"}';
                            udpService.send(
                                jsonData.codeUnits,
                                InternetAddress(moduleResponse.ipAddress!),
                                8888);
                            break;
                          case 'heat_until':
                            String jsonData =
                                '{"operation":"212","target_temperature":40,"duration":120000,"request_id":"heat_until"}';
                            udpService.send(
                                jsonData.codeUnits,
                                InternetAddress(moduleResponse.ipAddress!),
                                8888);
                            break;
                          case 'filter2':
                            print('filter 2 clicked');
                            break;
                          case 'clearFilters':
                            print('Clear filters');
                            break;
                          default:
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'zero',
                          child: Text('Reset (Zero)'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'wash',
                          child: Text('Wash'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'dispense',
                          child: Text('Dispense'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'cooling',
                          child: Text('Cooling'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'heat_until',
                          child: Text('Heat Until'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'shutdown',
                          child: Text('Shutdown'),
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 135,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        child: Thermometer(
                          temperature: temperature,
                        ),
                      ),
                      (moduleResponse is StirFryResponse) ? Text(
                          "${moduleResponse.temperature?.toStringAsFixed(2)} °C",
                          style: Theme.of(context).textTheme.titleMedium) : Row(),
                      Positioned(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child:
                            RotatedBox(quarterTurns: 2, child: progressGauge()),
                          ),
                          bottom: 0),
                    ],
                  ),
                ),
                Text(
                  "${moduleResponse.requestId}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "${moduleResponse.ipAddress}:${moduleResponse.port}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "${moduleResponse.type}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "${(moduleResponse.machineTime)} up time",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ElevatedButton(
                    onPressed: () {
                      widget.onTestRecipe();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [Text("Run Test"), Icon(Icons.play_circle)],
                    ))
              ],
            ),
          );
        },
      ),
    );
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 66,
        initialValue: 0,
        value: _progress ?? 0.0,
        axis: GaugeAxis(
            min: 0,
            max: 1,
            degrees: 280,
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
                to: 0.33,
                color: Colors.grey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.33,
                to: 0.5,
                color: Colors.blueGrey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.5,
                to: 0.8,
                color: Colors.blueAccent,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.8,
                to: 1,
                color: Colors.blue,
                cornerRadius: Radius.zero,
              ),
            ]));
  }
}
