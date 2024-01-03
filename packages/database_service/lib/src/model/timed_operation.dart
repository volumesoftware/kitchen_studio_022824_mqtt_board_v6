import 'models.dart';

abstract class TimedOperation extends BaseOperation {
  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  int? _duration;
  @override
  String? presetName;

  int? get duration => _duration ?? 0;

  set duration(int? value) {
    _duration = value;
  }
}
