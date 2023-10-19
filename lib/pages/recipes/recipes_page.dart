import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:kitchen_studio_10162023/app_router.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({Key? key}) : super(key: key);

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<String> units = [
    "Nasi Goreng Ayam",
    "Recipe 2",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Recipes"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))]),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.8,
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
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'view',
                            child: Text('View'),
                          ),
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
                                "https://th.bing.com/th/id/R.5c199d0cae62e5eef5e7a9cf1971459e?rik=zLs%2fqdsjAwjnWw&riu=http%3a%2f%2fimg.jakpost.net%2fc%2f2016%2f06%2f17%2f2016_06_17_6690_1466138968._large.jpg&ehk=bv4u0ES4kJpTXMNmr55xh%2ftnsgGh%2bfNY%2fJemwMzRdJc%3d&risl=&pid=ImgRaw&r=0"))),
                  ),
                  Text(
                    "Cook Count, 10",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Duration 15 minutes",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Author : Chef Asim ",
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
            Navigator.of(context).pushNamed(AppRouter.createRecipePage);
          },
          label: Row(
            children: [Text("Add Recipe"), Icon(Icons.add)],
          )),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new recipe'),
          content: Container(
            height: 250 ,
            width: 450,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Recipe Name',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Author',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Handler',
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
