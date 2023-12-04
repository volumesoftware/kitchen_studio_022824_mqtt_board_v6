import 'package:flutter/material.dart';

class TransporterUnitsPage extends StatefulWidget {
  const TransporterUnitsPage({Key? key}) : super(key: key);

  @override
  State<TransporterUnitsPage> createState() => _TransporterUnitsPageState();
}

class _TransporterUnitsPageState extends State<TransporterUnitsPage> {
  List<String> units = [
    "Unit 1",
    "Unit 2",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Transporter Unit"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))]),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "192.168.14.186",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "2C:54:91:88:C9:E3",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "Connected",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "Busy",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 100,
                ),
                ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  onTap: () {},
                  title: Text("Start"),
                  trailing: Icon(
                    Icons.play_circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  onTap: () {},
                  title: Text("Stop"),
                  trailing: Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  onTap: () {},
                  title: Text("Disable Transporter"),
                  trailing: Icon(
                    Icons.disabled_by_default,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  tileColor: Theme.of(context).secondaryHeaderColor,
                  onTap: () {},
                  title: Text("Zero Transporter"),
                  trailing:                           Icon(
                    Icons.restart_alt,
                    color: Theme.of(context).hintColor,
                  )
                  ,
                ),
              ],
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.88,
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(),
                    title: Text("1kg, Hot dog"),
                    subtitle: Text("Cooking Unit 1"),
                    trailing: CircularProgressIndicator(
                      value: .8,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
