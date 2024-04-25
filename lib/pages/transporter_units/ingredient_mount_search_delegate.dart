import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/transporter_units/ingredient_mount_search_result_page.dart';

class IngredientMountSearchDelegate extends SearchDelegate<Ingredient?> {
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
    return IngredientMountSearchResult(query: "%" + query + "%",);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return IngredientMountSearchResult(query: "%" + query + "%",);
  }
}
