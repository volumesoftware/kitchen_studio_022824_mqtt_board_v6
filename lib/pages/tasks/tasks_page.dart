import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_unit_card_component.dart';
import 'package:kitchen_studio_10162023/pages/tasks/completed_tasks.dart';
import 'package:kitchen_studio_10162023/pages/tasks/created_tasks.dart';
import 'package:kitchen_studio_10162023/pages/tasks/running_tasks.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> implements UdpListener {
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  TaskRunnerPool taskRunnerPool = TaskRunnerPool.instance;
  List<TaskRunner> taskRunners = [];
  List<Task>? tasks = [];

  @override
  void initState() {
    populateTask();
    taskRunnerPool.addStatsListener(this);
    var temp = taskRunnerPool.getTaskRunners();
    if(temp!=null){
      setState(() {
        taskRunners = temp;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    taskRunnerPool.removeStatsListener(this);
    super.dispose();
  }

  void populateTask() {
    taskDataAccess.findAll().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardSize = ((MediaQuery.of(context).size.width) -
            (MediaQuery.of(context).size.width * 0.26)) /
        3;
    return Scaffold(
      appBar: AppBar(
          title: Text("Tasks"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: cardSize, child: CreatedTasks()),
                Container(width: cardSize, child: RunningTasks()),
                Container(width: cardSize, child: CompletedTasks())
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), //color of shadow
                    spreadRadius: 1, //spread radius
                    blurRadius: 7, // blur radius
                    offset: Offset(0, 2), // changes position of shadow
                    //first paramerter of offset is left-right
                    //second parameter is top to down
                  ),
                  //you can set more BoxShadow() here
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: taskRunners
                  .map((e) => Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: 300,
                        child: CookingUnitCardComponent(
                          backgroundImage: e.getPayload()?.recipe.imageFilePath,
                            deviceStats: e.getDeviceStats()),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  @override
  void udpData(Datagram? dg) {
    if (dg != null) {
      var temp = taskRunnerPool.getTaskRunners();
      if (temp != null) {
        setState(() {
          this.taskRunners = temp;
        });
      }
    }
  }
}
