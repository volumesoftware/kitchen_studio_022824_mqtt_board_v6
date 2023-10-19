abstract interface class BaseInstructions<T> {
  int? operation;
  int? currentIndex;
  int? instructionSize;
  double? targetTemperature;

  BaseInstructions(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  Map<String, dynamic> toJson();
}

class ScanOperation implements BaseInstructions {

  static int CODE = 300;

  @override
  int? operation = 300;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  ScanOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  ScanOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}

class SetupOperation implements BaseInstructions {
  static int CODE = 1000;
  @override
  int? operation = 1000;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  SetupOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  SetupOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}

class ZeroingOperation implements BaseInstructions {
  static int CODE = 199;

  @override
  int? operation = 199;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  ZeroingOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  ZeroingOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}

class WashOperation implements BaseInstructions {
  static int CODE = 202;
  @override
  int? operation = 202;
  int? duration;
  int? cycle;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  WashOperation(
      {this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration,
      this.cycle});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['duration'] = duration;
    data['cycle'] = cycle;
    return data;
  }

  WashOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    duration = json['duration'];
    targetTemperature = json['target_temperature'];
  }
}

class DispenseOperation implements BaseInstructions {

  static int CODE = 203;

  @override
  int? operation = 203;
  int? cycle;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  DispenseOperation(this.currentIndex, this.instructionSize,
      this.targetTemperature, this.cycle);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['cycle'] = cycle;
    return data;
  }

  DispenseOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    targetTemperature = json['target_temperature'];
  }
}

class DockIngredientOperation implements BaseInstructions {
  static int CODE = 206;

  @override
  int? operation = 206;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  DockIngredientOperation(
      this.currentIndex, this.instructionSize, this.targetTemperature);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  DockIngredientOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}

class DropIngredientOperation implements BaseInstructions {
  static int CODE = 207;

  int? cycle;

  @override
  int? operation = 207;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  DropIngredientOperation(
      {this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.cycle});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['cycle'] = cycle;
    return data;
  }

  DropIngredientOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    targetTemperature = json['target_temperature'];
  }
}

class HeatUntilTemperatureOperation implements BaseInstructions {
  static int CODE = 208;

  @override
  int? operation = 208;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  HeatUntilTemperatureOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    return data;
  }

  HeatUntilTemperatureOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}

class HeatForOperation implements BaseInstructions {
  static int CODE = 212;

  @override
  int? operation = 212;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  HeatForOperation(
      {this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['duration'] = duration;
    return data;
  }

  HeatForOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    duration = json['duration'];
    targetTemperature = json['target_temperature'];
  }
}

class PumpOilOperation implements BaseInstructions {
  static int CODE = 209;

  @override
  int? operation = 209;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  PumpOilOperation(this.currentIndex, this.instructionSize, this.targetTemperature,
      this.duration);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['duration'] = duration;
    return data;
  }

  PumpOilOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    duration = json['duration'];
    targetTemperature = json['target_temperature'];
  }
}

class PumpWaterOperation implements BaseInstructions {
  static int CODE = 210;

  @override
  int? operation = 210;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  PumpWaterOperation(this.currentIndex, this.instructionSize, this.targetTemperature,
      this.duration);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['duration'] = duration;
    return data;
  }

  PumpWaterOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    targetTemperature = json['target_temperature'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    duration = json['duration'];
  }
}

class FlipOperation implements BaseInstructions {
  static int CODE = 213;

  @override
  int? operation = 213;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? cycle;
  int? interval;

  FlipOperation({
    this.currentIndex,
    this.instructionSize,
    this.targetTemperature,
    this.cycle,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operation'] = operation;
    data['targetTemperature'] = targetTemperature;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['cycle'] = cycle;
    data['interval'] = interval;
    return data;
  }

  FlipOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    targetTemperature = json['target_temperature'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    interval = json['interval'];
  }
}
