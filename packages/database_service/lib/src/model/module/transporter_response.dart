import 'package:database_service/database_service.dart';

class TransporterResponse extends ModuleResponse {
  List<Coordinate>? coordinates;

  TransporterResponse(super.json);

  @override
  void build(Map<String, dynamic> json) {
    if (json['coordinates'] != null) {
      coordinates = List<Coordinate>.from(json['coordinates'].map((x) => Coordinate.fromJson(x)));
    }
  }
}

class Coordinates {
  String? name;
  double? coordinate;
}

class Coordinate {
  String name;
  double coordinate;

  Coordinate({
    required this.name,
    required this.coordinate,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      name: json['name'],
      coordinate: json['coordinate'] == null ? 0.0 : json['coordinate'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'coordinate': coordinate,
    };
    return data;
  }
}
