class OeuvreModel {
  final String id;
  final String titre;
  final String qrCode;
  final String categorie;
  final String artiste;
  final String localisation;
  final int annee;
  final String? imageUrl;
  final List<Media>? medias;
  final List<Description>? descriptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  OeuvreModel({
    required this.id,
    required this.titre,
    required this.qrCode,
    required this.categorie,
    required this.artiste,
    required this.localisation,
    required this.annee,
    this.imageUrl,
    this.medias,
    this.descriptions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OeuvreModel.fromJson(Map<String, dynamic> json) {
    return OeuvreModel(
      id: json['id'] ?? '',
      titre: json['titre'] ?? '',
      qrCode: json['qrCode'] ?? '',
      categorie: json['categorie'] ?? '',
      artiste: json['artiste'] ?? '',
      localisation: json['localisation'] ?? '',
      annee: json['annee'] ?? 0,
      imageUrl: json['imageUrl'],
      medias: json['medias'] != null 
          ? (json['medias'] as List)
              .map((m) => Media.fromJson(m))
              .toList()
          : null,
      descriptions: json['descriptions'] != null
          ? (json['descriptions'] as List)
              .map((d) => Description.fromJson(d))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'qrCode': qrCode,
      'categorie': categorie,
      'artiste': artiste,
      'localisation': localisation,
      'annee': annee,
      'imageUrl': imageUrl,
      'medias': medias?.map((m) => m.toJson()).toList(),
      'descriptions': descriptions?.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getDescription(String langue) {
    if (descriptions == null || descriptions!.isEmpty) return '';
    
    final desc = descriptions!.firstWhere(
      (d) => d.langue == langue,
      orElse: () => descriptions!.first,
    );
    
    return desc.texte;
  }

  // Getters pour compatibilité
  String? get image => imageUrl;
  List<String>? get mediaUrls => medias?.map((m) => m.url).toList();
}

class Media {
  final String id;
  final String oeuvreId;
  final String type;
  final String url;

  Media({
    required this.id,
    required this.oeuvreId,
    required this.type,
    required this.url,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      oeuvreId: json['oeuvreId'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oeuvreId': oeuvreId,
      'type': type,
      'url': url,
    };
  }
}

class Description {
  final String id;
  final String oeuvreId;
  final String langue;
  final String texte;

  Description({
    required this.id,
    required this.oeuvreId,
    required this.langue,
    required this.texte,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      id: json['id'] ?? '',
      oeuvreId: json['oeuvreId'] ?? '',
      langue: json['langue'] ?? 'FR',
      texte: json['texte'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oeuvreId': oeuvreId,
      'langue': langue,
      'texte': texte,
    };
  }
}