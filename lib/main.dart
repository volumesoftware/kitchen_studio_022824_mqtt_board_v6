import 'package:flutter/material.dart';
import 'app_router.dart';
import 'package:kitchen_module/kitchen_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabasePackage.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Kitchen Studio 10162023

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Studio',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        focusColor: Colors.orangeAccent,
        highlightColor: Colors.orangeAccent,
        hintColor: Colors.orangeAccent,
        splashColor: Colors.orangeAccent,
        indicatorColor: Colors.orangeAccent,
        hoverColor: Colors.orangeAccent,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      onGenerateRoute: AppRouter.allRoutes,
      initialRoute: AppRouter.appShellScreen,
    );
  }
}
