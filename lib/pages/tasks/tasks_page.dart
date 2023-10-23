import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/pages/tasks/completed_tasks.dart';
import 'package:kitchen_studio_10162023/pages/tasks/created_tasks.dart';
import 'package:kitchen_studio_10162023/pages/tasks/running_tasks.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;

  List<Task>? tasks = [];

  @override
  void initState() {
    populateTask();
    super.initState();
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: cardSize, child: CreatedTasks()),
          Container(width: cardSize, child: RunningTasks()),
          Container(width: cardSize, child: CompletedTasks())
        ],
      ),
    );
  }
}
