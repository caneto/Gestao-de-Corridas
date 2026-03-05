class DriverModel {
  final int? id;
  final String name;
  final int number;
  final int teamId;
  final String nationality;
  final int pointsTotal;

  DriverModel({
    this.id,
    required this.name,
    required this.number,
    required this.teamId,
    required this.nationality,
    this.pointsTotal = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'team_id': teamId,
      'nationality': nationality,
      'points_total': pointsTotal,
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      id: map['id'],
      name: map['name'],
      number: map['number'],
      teamId: map['team_id'],
      nationality: map['nationality'],
      pointsTotal: map['points_total'],
    );
  }

  DriverModel copyWith({
    int? id,
    String? name,
    int? number,
    int? teamId,
    String? nationality,
    int? pointsTotal,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      teamId: teamId ?? this.teamId,
      nationality: nationality ?? this.nationality,
      pointsTotal: pointsTotal ?? this.pointsTotal,
    );
  }
}
