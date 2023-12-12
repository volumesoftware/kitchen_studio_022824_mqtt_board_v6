import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';

class CompletedTasksV2 extends StatefulWidget {
  const CompletedTasksV2({Key? key}) : super(key: key);

  @override
  State<CompletedTasksV2> createState() => _CompletedTasksV2State();
}

class _CompletedTasksV2State extends State<CompletedTasksV2> implements TaskChangedListener{
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  List<Task>? tasks = [];

  @override
  void initState() {
    populateTask();
    taskDataAccess.listen(this);
    super.initState();
  }

  @override
  void dispose() {
    taskDataAccess.removeListener(this);
    super.dispose();
  }

  void populateTask() {
    taskDataAccess.search('status like ? and task_name like ?', whereArgs: ['%Completed%', '%$query%']).then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.done),
        automaticallyImplyLeading: false,
        title: Text("Completed Task"),
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

                          populateTask();
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
            return ListTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text('${tasks![index].recipeName!} ${tasks![index].taskName!}'),
              subtitle: Text("${tasks![index].moduleName!}"),
              trailing: CircularProgressIndicator(
                value: tasks![index].progress ?? 0.0,
              ),
            );
          }),
    );
  }

  @override
  void onChange() {
    populateTask();
  }
}
