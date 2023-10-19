import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({Key? key}) : super(key: key);

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<String> units = [
    "Ikan",
    "Ayam",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Ingredients"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.85,
            crossAxisCount: 6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: units.length,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        units[index],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (String result) {
                          switch (result) {
                            case 'filter1':
                              print('filter 1 clicked');
                              break;
                            case 'filter2':
                              print('filter 2 clicked');
                              break;
                            case 'clearFilters':
                              print('Clear filters');
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Refilled',
                            child: Text('Refilled'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'disable',
                            child: Text('Disable'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          )
                        ],
                      )
                    ],
                  )),
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                "https://asset-a.grid.id/crop/0x0:1383x857/x/photo/2020/06/24/2690456462.jpg"))),
                  ),
                  Text(
                    "Stock, Low",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Location, (100, 140, 120)",
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _displayTextInputDialog(context);
          },
          label: Row(
            children: [Text("Add Ingredient"), Icon(Icons.add)],
          )),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new ingredient'),
          content: Container(
            height: 450,
            width: 450,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Ingredient Name',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Stock Status',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Type',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Coordinate X',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Coordinate Y',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Coordinate Z',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
