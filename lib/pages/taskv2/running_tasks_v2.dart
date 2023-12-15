import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/running_task_timeline.dart';


class RunningTasksV2 extends StatefulWidget {
   RunningTasksV2({Key? key}) : super(key: key);

  @override
  State<RunningTasksV2> createState() => _RunningTasksV2State();
}

class _RunningTasksV2State extends State<RunningTasksV2> {
  ThreadPool threadPool = ThreadPool.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Task Timeline"),
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if ((snapshot.data == null) && (threadPool.pool.isEmpty)) {
            return Center(
              child: Text('No module available', style: Theme.of(context).textTheme.displaySmall,),
            );
          }
          return ListView(
            children: (snapshot.data ?? threadPool.pool)
                .map((e) => RunningTaskTimelineWidget(recipeProcessor: e))
                .toList(),
          );
        },
        stream: threadPool.stateChanges,
      ),
    );
  }
}
