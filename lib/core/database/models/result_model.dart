class ResultModel {
  final int? id;
  final int raceId;
  final int driverId;
  final int teamId;
  final int position;
  final int gridPosition;
  final bool fastestLap;
  final bool dnf;
  final int pointsAwarded;

  ResultModel({
    this.id,
    required this.raceId,
    required this.driverId,
    required this.teamId,
    required this.position,
    required this.gridPosition,
    this.fastestLap = false,
    this.dnf = false,
    required this.pointsAwarded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'race_id': raceId,
      'driver_id': driverId,
      'team_id': teamId,
      'position': position,
      'grid_position': gridPosition,
      'fastest_lap': fastestLap ? 1 : 0,
      'dnf': dnf ? 1 : 0,
      'points_awarded': pointsAwarded,
    };
  }

  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      id: map['id'],
      raceId: map['race_id'],
      driverId: map['driver_id'],
      teamId: map['team_id'],
      position: map['position'],
      gridPosition: map['grid_position'],
      fastestLap: map['fastest_lap'] == 1,
      dnf: map['dnf'] == 1,
      pointsAwarded: map['points_awarded'],
    );
  }

  ResultModel copyWith({
    int? id,
    int? raceId,
    int? driverId,
    int? teamId,
    int? position,
    int? gridPosition,
    bool? fastestLap,
    bool? dnf,
    int? pointsAwarded,
  }) {
    return ResultModel(
      id: id ?? this.id,
      raceId: raceId ?? this.raceId,
      driverId: driverId ?? this.driverId,
      teamId: teamId ?? this.teamId,
      position: position ?? this.position,
      gridPosition: gridPosition ?? this.gridPosition,
      fastestLap: fastestLap ?? this.fastestLap,
      dnf: dnf ?? this.dnf,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }
}
