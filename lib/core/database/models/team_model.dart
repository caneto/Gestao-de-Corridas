class TeamModel {
  final int? id;
  final String name;
  final String country;
  final String? logoPath;

  TeamModel({
    this.id,
    required this.name,
    required this.country,
    this.logoPath,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'country': country, 'logo_path': logoPath};
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'],
      name: map['name'],
      country: map['country'],
      logoPath: map['logo_path'],
    );
  }

  TeamModel copyWith({
    int? id,
    String? name,
    String? country,
    String? logoPath,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
