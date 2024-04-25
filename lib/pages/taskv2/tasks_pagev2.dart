import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/task_bar.dart';

class TasksPageV2 extends StatefulWidget {
  const TasksPageV2({Key? key}) : super(key: key);

  @override
  State<TasksPageV2> createState() => _TasksPageV2State();
}

class _TasksPageV2State extends State<TasksPageV2> {
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  List<Task>? tasks = [];
  ThreadPool threadPool = ThreadPool.instance;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  void populateTask() {
    taskDataAccess.findAll().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

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
    return Scaffold(
      key: _key,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Tasks"),
      ),
      body: TaskBar(),
    );
  }
}
