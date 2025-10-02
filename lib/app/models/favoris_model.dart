class FavoriModel {
  final String id;
  final String utilisateurId;
  final String oeuvreId;
  final DateTime createdAt;

  FavoriModel({
    required this.id,
    required this.utilisateurId,
    required this.oeuvreId,
    required this.createdAt,
  });

  factory FavoriModel.fromJson(Map<String, dynamic> json) {
    return FavoriModel(
      id: json['id'] ?? '',
      utilisateurId: json['utilisateurId'] ?? '',
      oeuvreId: json['oeuvreId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
      'oeuvreId': oeuvreId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}