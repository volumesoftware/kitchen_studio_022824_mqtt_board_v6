import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';

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
          automaticallyImplyLeading: false,
          title: Text("Tasks"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: Row(
        children: [
          Container(
              width: cardSize,
              child: Scaffold(
                appBar: AppBar(
                  leading: Icon(Icons.play_for_work_outlined),
                  automaticallyImplyLeading: false,
                  title: Text("Created Tasks"),
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 50),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SearchBar(
                        trailing: [Icon(Icons.search)],
                      ),
                    ),
                  ),
                ),

                body: ListView.builder(
                    itemCount: tasks!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(tasks![index].recipeName!),
                        subtitle: Text("${tasks![index].moduleName!}"),
                        trailing: CircularProgressIndicator(
                          value: tasks![index].progress ?? 0.0,
                        ),
                      );
                    }),
                floatingActionButton: FloatingActionButton.extended(onPressed: () {

                }, label: Row(children: [
                  Text("Add Task"),
                  Icon(Icons.add)
                ],

                )),
              )),
          Container(
              width: cardSize,
              child: Scaffold(
                appBar: AppBar(
                  leading: Icon(Icons.play_for_work_outlined),
                  automaticallyImplyLeading: false,
                  title: Text("Running Task"),
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 50),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SearchBar(
                        trailing: [Icon(Icons.search)],
                      ),
                    ),
                  ),
                ),
                body: ListView.builder(
                    itemCount: tasks!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(tasks![index].recipeName!),
                        subtitle: Text("${tasks![index].moduleName!}"),
                        trailing: CircularProgressIndicator(
                          value: tasks![index].progress ?? 0.0,
                        ),
                      );
                    }),
              )),
          Container(
              width: cardSize,
              child: Scaffold(
                appBar: AppBar(
                  leading: Icon(Icons.play_for_work_outlined),
                  automaticallyImplyLeading: false,
                  title: Text("Completed Task"),
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 50),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SearchBar(
                        trailing: [Icon(Icons.search)],
                      ),
                    ),
                  ),
                ),
                body: ListView.builder(
                    itemCount: tasks!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(tasks![index].recipeName!),
                        subtitle: Text("${tasks![index].moduleName!}"),
                        trailing: CircularProgressIndicator(
                          value: tasks![index].progress ?? 0.0,
                        ),
                      );
                    }),
              ))
        ],
      ),
    );
  }
}
