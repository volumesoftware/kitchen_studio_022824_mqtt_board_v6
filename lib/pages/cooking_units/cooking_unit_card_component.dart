import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';

class CookingUnitCardComponent extends StatefulWidget {
  final DeviceStats deviceStats;
  final RawDatagramSocket udpSocket;

  const CookingUnitCardComponent(
      {Key? key, required this.deviceStats, required this.udpSocket})
      : super(key: key);

  @override
  State<CookingUnitCardComponent> createState() =>
      _CookingUnitCardComponentState();
}

class _CookingUnitCardComponentState extends State<CookingUnitCardComponent> {
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
                        String jsonData = '{"operation":"199","request_id":"zeroing"}';
                        widget.udpSocket.send(
                            jsonData.codeUnits,
                            InternetAddress(widget.deviceStats.ipAddress!),
                            8888);
                        break;
                      case 'heat_until':
                        String jsonData = '{"operation":"212","target_temperature":80,"duration":300000,"request_id":"heat_until"}';
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
            SizedBox(
              height: 10,
            ),
            LinearProgressIndicator(
              value: widget.deviceStats.progress,
            ),
            SizedBox(
              height: 10,
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      children: [Text("Add Task"), Icon(Icons.add)],
                    )),
                IconButton(
                    onPressed: () async {},
                    icon: Icon(
                      Icons.play_circle_outlined,
                      color: Colors.green,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.red,
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget temperatureGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 1),
        curve: Curves.elasticOut,
        radius: 100,
        value: widget.deviceStats.temperature1 ?? 0.0,
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
