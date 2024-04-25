import 'dart:async' show Future;
import 'dart:convert';
import 'package:database_service/src/data_access/system_settings_data_access.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:database_service/database_service.dart';

class ApiService {
  Handler get handler {
    final router = Router();
    router.mount('/api/recipe/', RecipeApi().router);
    router.mount('/api/ingredient/', IngredientApi().router);
    router.mount('/api/system-settings/', SystemSettingsApi().router);
    return router;
  }
}

class RecipeApi {
  final RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;

  Future<Response> _getRecipeById(Request request, String recipeId) async {
    try {
      Recipe? selectedRecipe =
          await recipeDataAccess.getById(int.tryParse(recipeId) ?? 0);
      if (selectedRecipe == null) return Response.notFound('recipe not found');
      return Response.ok(jsonEncode(selectedRecipe.toJson()));
    } catch (e) {
      return Response.notFound('recipe not found');
    }
  }

  Future<Response> _updateRecipeWorkSpace(
      Request request, String recipeId) async {
    var id = int.tryParse(recipeId) ?? 0;
    Recipe? selectedRecipe = await recipeDataAccess.getById(id);
    if (selectedRecipe == null) {
      return Response.notFound('recipe not found');
    }
    try {
      final payload = await request.readAsString();
      final data = json.decode(payload);
      selectedRecipe.workSpaceData = jsonEncode(data['workspace']);
      selectedRecipe.v6Instruction = jsonEncode(data['data']);
      recipeDataAccess.updateById(id, selectedRecipe);
      return Response.ok(json.encode({'message': 'recipe workspace updated!'}));
    } catch (e) {
      return Response.internalServerError(body: 'Invalid JSON format');
    }
  }

  Router get router {
    final router = Router();
    router.get('/recipe/<id>/', _getRecipeById);
    router.post('/recipe/<id>/', _updateRecipeWorkSpace);
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}

class IngredientApi {
  final IngredientDataAccess ingredientDataAccess =
      IngredientDataAccess.instance;

  Future<Response> _getIngredients(Request request) async {
    List<Ingredient>? findAll = await ingredientDataAccess.findAll();
    if (findAll == null) return Response.notFound('no ingredients available');
    var respond = [];
    findAll.forEach((element) {
      respond.add(element.toJson());
    });
    return Response.ok(jsonEncode(respond));
  }

  Router get router {
    final router = Router();
    router.get('/ingredients/', _getIngredients);
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}

class SystemSettingsApi {
  final SystemSettingsDataAccess systemSettingsDataAccess =
      SystemSettingsDataAccess.instance;

  Future<SystemSettings?> getOrCreate(String value) async {
    try {
      SystemSettings? backpack =
          await systemSettingsDataAccess.getByKey('backpack');
      if (backpack == null) {
        await systemSettingsDataAccess.create(new SystemSettings(
            key: 'backpack', label: 'Backpack Content', value: value));
        return await systemSettingsDataAccess.getByKey('backpack');
      }
      return backpack;
    } catch (e) {
      await systemSettingsDataAccess.create(new SystemSettings(key: 'backpack', label: 'Backpack Content', value: value));
      return await systemSettingsDataAccess.getByKey('backpack');
    }
  }

  Future<Response> _getBackPackContent(Request request) async {
    SystemSettings? backpack = await getOrCreate('');
    return Response.ok(jsonEncode(backpack));
  }


  Future<Response> _updateBackPackContent(Request request) async {
    try {
      final String payload = await request.readAsString();
      final data = json.decode(payload);
      SystemSettings? backpack = await getOrCreate(payload);
      backpack?.value = payload;
      await systemSettingsDataAccess.updateById(backpack!.id!, backpack);
      return Response.ok(json.encode({'message': 'recipe workspace updated!'}));
    } catch (e) {
      print(e);
      return Response.internalServerError(body: 'Invalid JSON format');
    }
  }

  Router get router {
    final router = Router();
    router.post('/backpack/', _updateBackPackContent);
    router.get('/backpack/', _getBackPackContent);
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}
