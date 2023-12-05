import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'app_router.dart';
import 'service/task_runner_pool.dart';
import 'package:kitchen_module/kitchen_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initialize();
  await DatabasePackage.instance.initialize();

  // await UdpService.instance.initialize();
  TaskRunnerPool.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final TaskRunnerPool taskRunnerPool = TaskRunnerPool.instance;


  @override
  void initState() {

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Studio 10162023',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      onGenerateRoute: AppRouter.allRoutes,
      initialRoute: AppRouter.appShellScreen,
    );
  }
}
