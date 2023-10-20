import 'dart:io';
import 'dart:math' as math; // import this
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';

class UnitMonitoringCardComponent extends StatefulWidget {
  final DeviceStats deviceStats;
  final RawDatagramSocket udpSocket;

  const UnitMonitoringCardComponent(
      {Key? key, required this.deviceStats, required this.udpSocket})
      : super(key: key);

  @override
  State<UnitMonitoringCardComponent> createState() =>
      _UnitMonitoringCardComponentState();
}

class _UnitMonitoringCardComponentState extends State<UnitMonitoringCardComponent> {
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
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.deviceStats.moduleName}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                PopupMenuButton<String>(
                  enabled: widget.deviceStats.requestId == 'idle',
                  icon: Icon(Icons.filter_list),
                  onSelected: (String result) {
                    switch (result) {
                      case 'zero':
                        String jsonData =
                            '{"operation":"199","request_id":"zeroing"}';
                        widget.udpSocket.send(
                            jsonData.codeUnits,
                            InternetAddress(widget.deviceStats.ipAddress!),
                            8888);
                        break;
                      case 'heat_until':
                        String jsonData =
                            '{"operation":"212","target_temperature":40,"duration":120000,"request_id":"heat_until"}';
                        widget.udpSocket.send(
                            jsonData.codeUnits,
                            InternetAddress(widget.deviceStats.ipAddress!),
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
            )),
            Container(
              width: double.infinity,
              height: 200,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Positioned(child: temperatureGauge(), top: 0),
                  Positioned(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: RotatedBox(
                            quarterTurns: 2, child: progressGauge()),
                      ),
                      bottom: 0),
                  Text("${widget.deviceStats.temperature1}",
                      style: Theme.of(context).textTheme.displaySmall)
                ],
              ),
            ),
            Text(
              "${widget.deviceStats.requestId}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "${widget.deviceStats.ipAddress}:${widget.deviceStats.port}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "${widget.deviceStats.type}",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              "${widget.deviceStats.memoryUsage} bytes",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              "${(widget.deviceStats.machineTime)} uptime",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 100,
        initialValue: 50,
        value: widget.deviceStats.progress ?? 0.0,
        axis: GaugeAxis(
            min: 0,
            max: 100,
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

    double? temperature = double.tryParse(widget.deviceStats.temperature1!.toStringAsFixed(2));
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
}
