import 'package:flutter/material.dart';
import 'app_router.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:dummy_module/dummy_udp_server.dart';

import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

// Middleware to remove cache headers from the response
shelf.Middleware removeCacheHeaders() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      final response = await innerHandler(request);
      return response.change(headers: {'cache-control': 'no-cache'}); // Remove cache headers
    };
  };
}

Future<void> serveEditor() async {
  // Configure a pipeline that serves static files from the 'web' directory.
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(createStaticHandler('web', defaultDocument: 'index.html'));

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a port to listen on (defaults to 8080).
  final port = 8081;

  // Serve the handler on the given IP and port.
  final shelfServer = await shelf_io.serve(handler, ip, port);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<DummyUdpServer> data = [];
  // for dummy purpose
  await DatabasePackage.instance.initialize();
  serveEditor();
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
