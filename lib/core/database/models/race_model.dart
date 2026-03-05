class RaceModel {
  final int? id;
  final String name;
  final String locationTitle;
  final double positionLat;
  final double positionLng;
  final DateTime date;
  final double expectedDistance;
  final double completedDistance;
  final bool isSprint;

  RaceModel({
    this.id,
    required this.name,
    required this.locationTitle,
    required this.positionLat,
    required this.positionLng,
    required this.date,
    required this.expectedDistance,
    required this.completedDistance,
    this.isSprint = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location_title': locationTitle,
      'position_lat': positionLat,
      'position_lng': positionLng,
      'date': date.toIso8601String(),
      'expected_distance': expectedDistance,
      'completed_distance': completedDistance,
      'is_sprint': isSprint ? 1 : 0,
    };
  }

  factory RaceModel.fromMap(Map<String, dynamic> map) {
    return RaceModel(
      id: map['id'],
      name: map['name'],
      locationTitle: map['location_title'],
      positionLat: map['position_lat'],
      positionLng: map['position_lng'],
      date: DateTime.parse(map['date']),
      expectedDistance: map['expected_distance'],
      completedDistance: map['completed_distance'],
      isSprint: map['is_sprint'] == 1,
    );
  }

  RaceModel copyWith({
    int? id,
    String? name,
    String? locationTitle,
    double? positionLat,
    double? positionLng,
    DateTime? date,
    double? expectedDistance,
    double? completedDistance,
    bool? isSprint,
  }) {
    return RaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      locationTitle: locationTitle ?? this.locationTitle,
      positionLat: positionLat ?? this.positionLat,
      positionLng: positionLng ?? this.positionLng,
      date: date ?? this.date,
      expectedDistance: expectedDistance ?? this.expectedDistance,
      completedDistance: completedDistance ?? this.completedDistance,
      isSprint: isSprint ?? this.isSprint,
    );
  }
}
