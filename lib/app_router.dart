import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/app_shell.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/create_recipe_page.dart';

class AppRouter {
  static const String appShellScreen = "/appShellScreen";
  static const String createRecipePage = "/createRecipePage";

  static Route<dynamic> allRoutes(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name;

    switch (name) {
      case appShellScreen:
        {
          return MaterialPageRoute(builder: (_) => const AppShellScreen());
        }
      case createRecipePage:
        {
          return MaterialPageRoute(builder: (_) => const CreateRecipePage());
        }
    }

    return MaterialPageRoute(
        builder: (_) => Scaffold(
              body: Text("Page not found"),
            ));
  }
}
