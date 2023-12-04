import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
import 'package:kitchen_studio_10162023/dao/operation_data_access.dart';
import 'package:kitchen_studio_10162023/dao/recipe_data_access.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/pages/tasks/recipe_search_delegate.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';

class CreatedTasks extends StatefulWidget {
  const CreatedTasks({Key? key}) : super(key: key);

  @override
  State<CreatedTasks> createState() => _CreatedTasksState();
}

class _CreatedTasksState extends State<CreatedTasks>
    implements TaskChangedListener {
  final TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  final BaseOperationDataAccess operationDataAccess =
      BaseOperationDataAccess.instance;
  final RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  final DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;

  final TextEditingController _searchController = TextEditingController();
  String query = '';

  List<Task>? tasks = [];

  void populateTask() {
    taskDataAccess.search('status like ? AND task_name like ?',
        whereArgs: ['%Created%', '%$query%']).then((value) {
      if (value != null) {
        setState(() {
          tasks = value;
        });
      }
    });
  }

  @override
  void dispose() {
    taskDataAccess.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    taskDataAccess.listen(this);
    populateTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.create),
          automaticallyImplyLeading: false,
          title: Text("Created Tasks"),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  var result = await showSearch<Task?>(
                    context: context,
                    delegate: RecipeSearchDelegate(),
                  );
                  populateTask();
                },
                child: Row(
                  children: [Text("Add task"), Icon(Icons.add)],
                ))
          ],
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                  populateTask();
                },
                trailing: [
                  query == ""
                      ? Icon(Icons.search)
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              query = '';
                            });
                            _searchController.clear();
                          },
                          icon: Icon(Icons.close))
                ],
              ),
            ),
          ),
        ),
        body: ListView.builder(
            itemCount: tasks!.length,
            itemBuilder: (context, index) {
              var taskRunner = TaskRunnerPool.instance
                  .getTaskRunner(tasks![index].moduleName!);
              if (taskRunner == null) return Row();
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(
                    '${tasks![index].recipeName} (${tasks![index].taskName})'),
                subtitle: Text("${tasks![index].moduleName!}"),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      taskRunner.isBusy()
                          ? IconButton(
                              icon: Icon(
                                Icons.play_for_work_outlined,
                                color: Theme.of(context).disabledColor,
                              ),
                              onPressed: () async {},
                            )
                          : IconButton(
                              icon: Icon(Icons.play_for_work_outlined),
                              onPressed: () async {
                                var recipe = (await recipeDataAccess.search(
                                        'id = ?',
                                        whereArgs: [tasks![index].recipeId!]))
                                    ?.first;
                                var operations = await operationDataAccess
                                    .search("recipe_id = ?",
                                        whereArgs: [tasks![index].recipeId!]);
                                var selectedDevice = (await deviceDataAccess
                                        .search('name = ?', whereArgs: [
                                  tasks![index].moduleName!
                                ]))
                                    ?.first;
                                if ((recipe != null) && (operations != null)) {
                                  await taskRunner.submitTask(TaskPayload(
                                      recipe,
                                      operations,
                                      selectedDevice!,
                                      tasks![index]));
                                }
                              },
                            ),
                      IconButton(
                          onPressed: () async {
                            await taskDataAccess.delete(tasks![index].id!);
                            populateTask();
                          },
                          icon: Icon(Icons.delete))
                    ],
                  ),
                ),
              );
            }));
  }

  @override
  void onChange() {
    populateTask();
  }
}
