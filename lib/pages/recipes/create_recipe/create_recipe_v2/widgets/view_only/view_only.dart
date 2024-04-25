import 'package:flutter/material.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/advance_control_editor/advanced_control_editor_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_page/recipe_widgets/recipe_widget.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_v2/widgets/view_only/value_editor.dart';

class ViewOnly extends StatefulWidget {
  final BaseOperation operation;
  final RecipeWidgetActions recipeWidgetActions;

  const ViewOnly(
      {Key? key, required this.operation, required this.recipeWidgetActions})
      : super(key: key);

  @override
  State<ViewOnly> createState() => _ViewOnlyState();
}

class _ViewOnlyState extends State<ViewOnly> {
  late BaseOperation _operation;
  late Map<String, dynamic> json;

  @override
  void initState() {
    _operation = widget.operation;
    mapToType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: buildList(context),
        ),
      ),
      bottomNavigationBar: ButtonBar(
        children: [
          TextButton(onPressed: () {}, child: Text("Delete")),
          FilledButton(
              onPressed: () {
                if (_operation.operation == AdvancedOperation.CODE) {
                  _showAdvancedControl();
                } else {
                  _showValueEditor();
                }
              },
              child: Text("Edit"))
        ],
      ),
    );
  }

  List<Padding> buildList(BuildContext context) {
    return json.entries.map((e) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${e.key.toString().toUpperCase().replaceAll("_", " ")}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: e.value != null ? Colors.black87 : Colors.red),
            ),
            Text("${e.value}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: e.value != null ? Colors.black87 : Colors.red)),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _showValueEditor() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('${_operation.requestId ?? _operation.presetName}'),
          content: ValueEditorDialog(
            operation: _operation,
            json: json,
            valueChanged: (Map<String, dynamic> value) {
              BaseOperation updateValue = _operation.updateValue(value);
              setState(() {
                _operation = updateValue;
              });
              widget.recipeWidgetActions.onValueUpdate(updateValue);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showAdvancedControl() {
    var operation = (_operation as AdvancedOperation);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('${operation.title ?? 'Advanced Control Editor'}'),
          content: AdvanceControlWidget(
            advancedOperation: operation,
            onSaved: (AdvancedOperation value) {
              setState(() {
                operation = value;
              });
              widget.recipeWidgetActions.onValueUpdate(operation);
            },
          ),
        );
      },
    );
  }

  void mapToType() {
    switch (widget.operation.operation) {
      case DispenseOperation.CODE:
        {
          json = (widget.operation as DispenseOperation).toJson();
          break;
        }
      case DockIngredientOperation.CODE:
        {
          json = (widget.operation as DockIngredientOperation).toJson();
          break;
        }
      case DropIngredientOperation.CODE:
        {
          json = (widget.operation as DropIngredientOperation).toJson();
          break;
        }
      case FlipOperation.CODE:
        {
          json = (widget.operation as FlipOperation).toJson();
          break;
        }
      case HeatForOperation.CODE:
        {
          json = (widget.operation as HeatForOperation).toJson();
          break;
        }

      case HeatUntilTemperatureOperation.CODE:
        {
          json = (widget.operation as HeatUntilTemperatureOperation).toJson();
          break;
        }

      case PumpOilOperation.CODE:
        {
          json = (widget.operation as PumpOilOperation).toJson();
          break;
        }
      case PumpWaterOperation.CODE:
        {
          json = (widget.operation as PumpWaterOperation).toJson();
          break;
        }
      case ScanOperation.CODE:
        {
          json = (widget.operation as ScanOperation).toJson();
          break;
        }
      case SetupOperation.CODE:
        {
          json = (widget.operation as SetupOperation).toJson();
          break;
        }
      case WashOperation.CODE:
        {
          json = (widget.operation as WashOperation).toJson();
          break;
        }
      case ZeroingOperation.CODE:
        {
          json = (widget.operation as ZeroingOperation).toJson();
          break;
        }
      case StirOperation.CODE:
        {
          json = (widget.operation as StirOperation).toJson();
          break;
        }
      case UserActionOperation.CODE:
        {
          json = (widget.operation as UserActionOperation).toJson();
          break;
        }
      case HotMixOperation.CODE:
        {
          json = (widget.operation as HotMixOperation).toJson();
          break;
        }
      case ColdMixOperation.CODE:
        {
          json = (widget.operation as ColdMixOperation).toJson();
          break;
        }
      case RepeatOperation.CODE:
        {
          json = (widget.operation as RepeatOperation).toJson();
          break;
        }
      case AdvancedOperation.CODE:
        {
          json = (widget.operation as AdvancedOperation).toJson();
          break;
        }
    }
    json.remove('request_id');
    json.remove('operation');
    json.remove('recipe_id');
    json.remove('current_index');
    json.remove('preset_name');
    json.remove('instruction_size');
    json.remove('is_closing');
    json.remove('interval');
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: Container(
        child: Center(
          child: Text("${widget.operation.currentIndex! + 1}"),
        ),
      ),
      title: Text(
        "${_operation.presetName ?? _operation.requestId}",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      automaticallyImplyLeading: false,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.filter_list),
          onSelected: (String result) {
            switch (result) {
              case 'delete':
                widget.recipeWidgetActions.onDelete(widget.operation);
                break;
              case 'save preset':
                widget.recipeWidgetActions.onPresetSave(widget.operation);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
            const PopupMenuItem<String>(
              value: 'save preset',
              child: Text('Save as preset'),
            ),
          ],
        )
      ],
    );
  }
}
