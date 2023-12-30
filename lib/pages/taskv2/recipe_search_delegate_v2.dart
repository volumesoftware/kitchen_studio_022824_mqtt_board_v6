import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/taskv2/recipe_search_result_page_v2.dart';
import 'package:kitchen_studio_10162023/widget/cursor.dart';

class RecipeSearchDelegateV2 extends SearchDelegate<Task?> {
  final RecipeProcessor recipeProcessor;
  List<Recipe>? allRecipe = [];
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;

  RecipeSearchDelegateV2(this.recipeProcessor) {
    recipeDataAccess.findAll().then((value) => allRecipe = value);
  }

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
    final List<Recipe> searchResults = allRecipe!.where((item) {
      if (item.recipeName == null) return false;
      return item.recipeName!.contains(query.toLowerCase());
    }).toList();

    print(searchResults);

    if (searchResults.isEmpty)
      return Center(
        child: Text(
          'no recipe available',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );

    return Stack(
      children: [
        RecipeSearchResultV2(
          recipes: searchResults,
          key: Key('buildSuggestion'),
          namedKey: 'buildSuggestionK',
          recipeProcessor: recipeProcessor,
          query: "%" + query + "%",
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (allRecipe == null || allRecipe!.isEmpty)
      return Center(
        child: Text(
          'no recipe available',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );

    final List<Recipe>? suggestionList = query.isEmpty
        ? allRecipe
        : allRecipe
            ?.where((item) => item.recipeName!.contains(query.toLowerCase()))
            .toList();

    return RecipeSearchResultV2(
      recipes: suggestionList!,
      key: Key('buildSuggestion'),
      namedKey: 'buildSuggestionK',
      recipeProcessor: recipeProcessor,
      query: "%" + query + "%",
    );
  }
}
