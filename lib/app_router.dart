import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/app_shell.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/create_recipe_page.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/tasks_pagev2.dart';
import 'package:kitchen_module/kitchen_module.dart';

class AppRouter {
  static const String appShellScreen = "/appShellScreen";
  static const String createRecipePage = "/createRecipePage";
  static const String taskScreen = "/taskScreen";

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
          return MaterialPageRoute(
              builder: (_) => CreateRecipePage(
                    recipe: args as Recipe,
                  ));
        }
      case taskScreen:
        {
          return MaterialPageRoute(builder: (_) => const TasksPageV2());
        }
    }

    return MaterialPageRoute(
        builder: (_) => const Scaffold(
              body: Text("Page not found"),
            ));
  }
}
