import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';

class TransporterTasksList extends StatefulWidget {
  const TransporterTasksList({Key? key}) : super(key: key);

  @override
  State<TransporterTasksList> createState() => _TransporterTasksListState();
}

class _TransporterTasksListState extends State<TransporterTasksList> {
  TransporterProcessor? transporterProcessor;
  final ThreadPool threadPool = ThreadPool.instance;

  @override
  void initState() {
    final temp = threadPool.pool.whereType<TransporterProcessor>();
    if (temp.isNotEmpty) {
      transporterProcessor = temp.firstOrNull;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const Icon(Icons.list),
        automaticallyImplyLeading: false,
        title: Text("${transporterProcessor?.moduleName()} Task"),
      ),
      body: transporterProcessor != null
          ? StreamBuilder(
              stream: transporterProcessor!.taskStream,
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                return ListView.builder(
                    itemCount: transporterProcessor?.doingBuffer.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(transporterProcessor?.doingBuffer[index]['request_title']),
                      );
                    });
              },
            )
          : Text("Loading..."),
    );
  }
}
