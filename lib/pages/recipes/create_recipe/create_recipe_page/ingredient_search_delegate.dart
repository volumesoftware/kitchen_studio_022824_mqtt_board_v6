import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/ingredient_search_result_page.dart';

class IngredientSearchDelegate extends SearchDelegate<IngredientItem?> {
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
    return IngredientSearchResult(query: "%" + query + "%",);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return IngredientSearchResult(query: "%" + query + "%",);
  }
}
