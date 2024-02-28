import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';

class TransporterUnitsPage extends StatefulWidget {
  const TransporterUnitsPage({Key? key}) : super(key: key);

  @override
  State<TransporterUnitsPage> createState() => _TransporterUnitsPageState();
}

class _TransporterUnitsPageState extends State<TransporterUnitsPage> {
  ThreadPool _threadPool = ThreadPool.instance;

  late StreamSubscription<List<KitchenToolProcessor>>
      _kitchenToolProcessorListener;

  TransporterProcessor? transporter;

  @override
  void initState() {
    assignTransporter();
    _kitchenToolProcessorListener =
        _threadPool.stateChanges.listen((List<KitchenToolProcessor> event) {
      assignTransporter();
    });
    super.initState();
  }

  void assignTransporter() {
    List<KitchenToolProcessor> _transporters =
        _threadPool.pool.whereType<TransporterProcessor>().toList();
    if (_transporters.isNotEmpty && mounted) {
      setState(() {
        transporter = _transporters.first as TransporterProcessor;
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
          automaticallyImplyLeading: false,
          title: Text("Transporter Unit"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))]),
      body: transporter == null
          ? Center(
              child: Text("loading...."),
            )
          : StreamBuilder(
              stream: transporter?.hearBeat,
              builder: (BuildContext context,
                  AsyncSnapshot<ModuleResponse> snapshot) {
                var data = snapshot.data ?? transporter?.getModuleResponse();

                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
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
                            "${transporter!.isBusy() ? "Busy" : "Idle"}",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            "Uptime ${timeLeft(data?.machineTime ?? 0)}",
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
                            trailing: Icon(
                              Icons.restart_alt,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      flex: 4,
                    ),
                    Expanded(
                      child: Row(),
                      flex: 2,
                    ),
                    Expanded(
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
                      flex: 12,
                    ),
                    Expanded(
                      child: Row(),
                      flex: 1,
                    ),
                  ],
                );
              },
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
