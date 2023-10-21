import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'package:window_manager/window_manager.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initialize();
  await UdpService.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      onGenerateRoute: AppRouter.allRoutes,
      initialRoute: AppRouter.appShellScreen,
    );
  }
}
