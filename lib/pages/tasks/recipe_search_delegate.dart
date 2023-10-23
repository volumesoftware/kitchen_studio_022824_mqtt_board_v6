import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/ingredient_data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/pages/tasks/recipe_search_result_page.dart';

class RecipeSearchDelegate extends SearchDelegate<Task?> {
  IngredientDataAccess ingredientDataAccess = IngredientDataAccess.instance;

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return RecipeSearchResult(query: "%" + query + "%",);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return RecipeSearchResult(query: "%" + query + "%",);
  }
}
