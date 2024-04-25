import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/ingredient_mount_search_delegate.dart';

class TransporterUnitsPage extends StatefulWidget {
  const TransporterUnitsPage({Key? key}) : super(key: key);

  @override
  State<TransporterUnitsPage> createState() => _TransporterUnitsPageState();
}

class _TransporterUnitsPageState extends State<TransporterUnitsPage> {
  final ThreadPool _threadPool = ThreadPool.instance;

  late StreamSubscription<List<KitchenToolProcessor>> _kitchenToolProcessorListener;
  TransporterProcessor? transporter;
  final TextEditingController _xCoordinateTextController = TextEditingController();

  @override
  void initState() {
    assignTransporter();
    _kitchenToolProcessorListener = _threadPool.stateChanges.listen((List<KitchenToolProcessor> event) {
      assignTransporter();
    });
    super.initState();
  }

  void assignTransporter() {
    List<KitchenToolProcessor> transporters = _threadPool.pool.whereType<TransporterProcessor>().toList();
    if (transporters.isNotEmpty && mounted) {
      setState(() {
        transporter = transporters.first as TransporterProcessor;
      });
    }
  }

  @override
  void dispose() {
    _kitchenToolProcessorListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, title: const Text("Transporter Unit"), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))]),
      body: transporter == null
          ? const Center(
              child: Text("loading...."),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder(
                stream: transporter?.hearBeat,
                builder: (BuildContext context, AsyncSnapshot<ModuleResponse> snapshot) {
                  TransporterResponse? data = (snapshot.data ?? transporter?.getModuleResponse()) as TransporterResponse?;
                  var buffer = transporter?.buffer;
                  return Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data?.ipAddress}",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Connected",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "${transporter!.isBusy() ? "Busy" : "Idle"} Buffer Length ${buffer?.length}",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "Uptime ${timeLeft(data?.machineTime ?? 0)}",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ListTile(
                              tileColor: Theme.of(context).secondaryHeaderColor,
                              onTap: () async {
                                transporter?.handleRequest({"operation": 199, "request_title": "Zeroing", "requester_name": "User", "flag": "user"});

                                var dialog = showDialog(
                                  context: context,
                                  builder: (context) => const Dialog(
                                    child: SizedBox(
                                      height: 50,
                                      width: 200,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [Text("moving..."), LinearProgressIndicator()],
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                bool? completed = await transporter?.waitForTaskCompletion();
                                if (completed != null) {
                                  Navigator.of(context).pop();
                                }
                              },
                              title: const Text("Zero Transporter"),
                              trailing: Icon(
                                Icons.restart_alt,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _xCoordinateTextController,
                                      decoration: const InputDecoration(
                                        suffixText: '(mm)',
                                        hintText: 'Coordinate...',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  FilledButton(
                                    onPressed: () async {
                                      int xCoordinate = int.tryParse(_xCoordinateTextController.text) ?? 0;
                                      transporter?.handleRequest({
                                        "operation": 20,
                                        "request_id": "manual_move",
                                        "coordinate_x": xCoordinate,
                                        "request_title": "User Move X",
                                        "requester_name": "User",
                                        "flag": "user"
                                      });
                                      var dialog = showDialog(
                                        context: context,
                                        builder: (context) => const Dialog(
                                          child: SizedBox(
                                            height: 50,
                                            width: 200,
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [Text("moving..."), LinearProgressIndicator()],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );

                                      bool? completed = await transporter?.waitForTaskCompletion();
                                      if (completed != null) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text(data?.requestId == 'idle' ? 'Move X' : 'Moving'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Row(),
                      ),
                      Expanded(
                        flex: 12,
                        child: GridView.builder(
                          itemCount: data?.coordinates?.length ?? 0,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                          itemBuilder: (context, index) {
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text("${data?.coordinates?[index].name}"),
                                      TextButton(
                                        onPressed: () async {
                                          transporter?.handleRequest({
                                            "operation": 20,
                                            "coordinate_x": data?.coordinates?[index].coordinate,
                                            "request_title": "User Move X",
                                            "requester_name": "User",
                                            "flag": "user"
                                          });

                                          var dialog = showDialog(
                                            context: context,
                                            builder: (context) => const Dialog(
                                              child: SizedBox(
                                                height: 50,
                                                width: 200,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [Text("moving..."), LinearProgressIndicator()],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );

                                          bool? completed = await transporter?.waitForTaskCompletion();
                                          if (completed != null) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text("${data?.coordinates?[index].coordinate} mm"),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      FilledButton(
                                        onPressed: () async {
                                          Ingredient? result = await showSearch<Ingredient?>(
                                            context: context,
                                            delegate: IngredientMountSearchDelegate(),
                                          );
                                          if (result != null) {
                                            result.coordinateX = data!.coordinates![index].coordinate;
                                            await IngredientDataAccess.instance.updateById(result.id!, result);
                                          }
                                        },
                                        child: const Text('mount'),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Row(),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  String timeLeft(int milliseconds) {
    double seconds = milliseconds / 1000;

    String eta = "";
    if (seconds >= 60) {
      eta = (seconds / 60).toStringAsFixed(2);
      return "$eta minutes";
    } else if (seconds >= 3600) {
      eta = (seconds / (60 * 60)).toStringAsFixed(2);
      return "$eta hours";
    } else {
      return "$seconds seconds";
    }
  }
}

/**
    Add my letter to chatGPT and how he would respond,
    would DOG respond the same way? My death is justified.
 */
/**
 * Life as we know it, is so unfair
 * Life is define your journey
 * It affect your decision making
 * It create who you are
 * Random as we know it, it does exits
 * It's outcome cannot be calculated, yet can be determined and can be controlled
 * That is how life look like
 * Math cannot deny that you have free will,
 * But it is true that the way your life end, can be predetermined according to how it started
 * Life sucks, unfair and  injustice.
 * Whoever ends their life without finishing the whole game is the winner
 * Life a present should never recieve
 * A drug should never exist
 * God they say is loving, fair and just
 * SHiT i would say he is a DUMBass and ASS hole
 * The journey he gave me is unnecessarily fucked up until now.
 * Haven't i work as hard as other people?
 * Haven't i make things work?
 * Haven't i stitch everything together?
 * What else do you expect? Make the world spin? Ass hole really is you are!
 * If that is what you want? The you should worship me too! Call me satan if you want,
 * You are the one who did this to me.
 * I PRAY WAR WILL HAPPEN IN MY LIFE TIME, or at least i will end my life my self,
 * as a token on how fucked up HE REALLY IS and how noob designer he really is.
 * AMEN, PRAISE THE ....."
 * **/
