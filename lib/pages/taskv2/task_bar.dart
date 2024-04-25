import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/completed_tasks_v2.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/recipe_processor_task_timeline.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/transporter_processor_task_timeline.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/transporter_tasks_list.dart';

class TaskBar extends StatefulWidget {
  TaskBar({Key? key}) : super(key: key);

  @override
  State<TaskBar> createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> {
  ThreadPool threadPool = ThreadPool.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 4,
            child: StreamBuilder(
              stream: threadPool.stateChanges,
              builder: (context, snapshot) {
                if ((snapshot.data == null) && (threadPool.pool.isEmpty)) {
                  return Center(
                    child: Text(
                      'Loading modules...',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  );
                }
                return ListView(
                  children: (snapshot.data ?? threadPool.pool).map((e) {
                    if (e is RecipeProcessor) {
                      return _getRecipeProcessorTaskTimeline(e);
                    } else {
                      return Row();
                    }
                  }).toList(),
                );
              },
            ),
          ),
          const Expanded(
            flex: 1,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 1,
                  child: CompletedTasksV2(),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Card(
                //     elevation: 1,
                //     child: TransporterTasksList(),
                //   ),
                // )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getTransporterProcessor(KitchenToolProcessor e) => TransporterProcessorTaskTimeline(transporterProcessor: e as TransporterProcessor);

  Widget _getRecipeProcessorTaskTimeline(KitchenToolProcessor e) => RecipeProcessorTaskTimeline(recipeProcessor: e as RecipeProcessor);
}
