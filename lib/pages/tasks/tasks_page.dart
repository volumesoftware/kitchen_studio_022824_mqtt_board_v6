import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<String> tasks = ["Nasi Goreng Ayam", "Ikan Kaloi Masak Ayam"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Tasks"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text(tasks[index]),
              subtitle: Text("Cooking Unit 1"),
              trailing: CircularProgressIndicator(value: .8,),
            );
          }),
    );
  }
}
