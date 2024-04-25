List<Map<String, dynamic>> _processRepeatObjects(Map<String, dynamic> instruction) {
  if (instruction['request_id'] == 'repeat') {
    int repeat = instruction['repeat'];
    List<Map<String, dynamic>> repeatObjects = List.from(instruction['repeat_objects']);
    List<Map<String, dynamic>> processedInstructions = [];
    for (int i = 0; i < repeat; i++) {
      for (var obj in repeatObjects) {
        processedInstructions.addAll(_processRepeatObjects(Map<String, dynamic>.from(obj)));
      }
    }
    return processedInstructions;
  } else {
    return [instruction];
  }
}

List<Map<String, dynamic>> replaceRepeat(List<Map<String, dynamic>> input) {
  List<Map<String, dynamic>> processedInstructions = [];
  for (var instruction in input) {
    processedInstructions.addAll(_processRepeatObjects(instruction));
  }
  return processedInstructions;
}
