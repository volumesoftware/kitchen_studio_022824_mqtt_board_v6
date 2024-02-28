import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/recipe_processor_task_timeline.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/transporter_processor_task_timeline.dart';

class TaskBar extends StatefulWidget {
  TaskBar({Key? key}) : super(key: key);

  @override
  State<TaskBar> createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> {
  ThreadPool threadPool = ThreadPool.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: threadPool.stateChanges,
      builder: (context, snapshot) {
        if ((snapshot.data == null) && (threadPool.pool.isEmpty)) {
          return Center(
            child: Text(
              'No module available',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          );
        }
        return ListView(
          children: (snapshot.data ?? threadPool.pool).map((e) {
            if (e is RecipeProcessor) {
              return _getRecipeProcessorTaskTimeline(e);
            } else {
              return _getTransporterProcessor(e);
            }
          }).toList(),
        );
      },
    );
  }


  Widget _getTransporterProcessor(KitchenToolProcessor e) =>
      TransporterProcessorTaskTimeline(transporterProcessor: e as TransporterProcessor);

  Widget _getRecipeProcessorTaskTimeline(KitchenToolProcessor e) =>
      RecipeProcessorTaskTimeline(recipeProcessor: e as RecipeProcessor);
}
