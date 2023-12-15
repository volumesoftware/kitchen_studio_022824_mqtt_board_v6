import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/completed_tasks_v2.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/running_tasks_v2.dart';

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
  FocusScopeNode focusScopeNode = FocusScopeNode();

  void populateTask() {
    taskDataAccess.findAll().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  void dispose() {
    focusScopeNode.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  @override
  void initState() {
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    super.initState();
  }

  bool _onKey(KeyEvent event) {
    if (mounted) {
      final key = event.logicalKey.keyLabel;
      if (event is KeyDownEvent) {
        print(" task page"
            " Key down: $key");
        if (key == 'Numpad 8' || key == 'Arrow Up') {
          focusScopeNode.previousFocus();
        } else if (key == 'Numpad 2' || key == 'Arrow Down') {
          focusScopeNode.nextFocus();
        }
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        node: focusScopeNode,
        child: Scaffold(
          key: _key,
          endDrawer: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: CompletedTasksV2()),
          appBar: AppBar(title: Text("Tasks"), actions: [
            IconButton(
                onPressed: () {
                  _key.currentState?.openEndDrawer();
                },
                icon: Icon(Icons.arrow_back))
          ]),
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: RunningTasksV2(),
          ),
        ));
  }
}
