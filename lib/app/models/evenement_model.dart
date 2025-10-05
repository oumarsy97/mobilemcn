class EvenementModel {
  final String id;
  final String titre;
  final String type;
  final String statut;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String heureDebut;
  final String heureFin;
  final String lieu;
  final String organisateur;
  final String? intervenant;
  final String? imageUrl;
  final int capaciteMax;
  final String prix;
  final bool gratuit;
  final String? lienInscription;
  final String? lienBillet;
  final bool estPopulaire;
  final List<String> tags;
  final String? oeuvreId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int nombreInscriptions;

  EvenementModel({
    required this.id,
    required this.titre,
    required this.type,
    required this.statut,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.heureDebut,
    required this.heureFin,
    required this.lieu,
    required this.organisateur,
    this.intervenant,
    this.imageUrl,
    required this.capaciteMax,
    required this.prix,
    required this.gratuit,
    this.lienInscription,
    this.lienBillet,
    required this.estPopulaire,
    required this.tags,
    this.oeuvreId,
    required this.createdAt,
    required this.updatedAt,
    this.nombreInscriptions = 0,
  });

  factory EvenementModel.fromJson(Map<String, dynamic> json) {
    return EvenementModel(
      id: json['id'] ?? '',
      titre: json['titre'] ?? '',
      type: json['type'] ?? '',
      statut: json['statut'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      heureDebut: json['heureDebut'] ?? '',
      heureFin: json['heureFin'] ?? '',
      lieu: json['lieu'] ?? '',
      organisateur: json['organisateur'] ?? '',
      intervenant: json['intervenant'],
      imageUrl: json['imageUrl'],
      capaciteMax: json['capaciteMax'] ?? 0,
      prix: json['prix'] ?? '0',
      gratuit: json['gratuit'] ?? false,
      lienInscription: json['lienInscription'],
      lienBillet: json['lienBillet'],
      estPopulaire: json['estPopulaire'] ?? false,
      tags: _parseTags(json['tags']),
      oeuvreId: json['oeuvreId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      nombreInscriptions: json['_count']?['inscriptions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'type': type,
      'statut': statut,
      'description': description,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'lieu': lieu,
      'organisateur': organisateur,
      'intervenant': intervenant,
      'imageUrl': imageUrl,
      'capaciteMax': capaciteMax,
      'prix': prix,
      'gratuit': gratuit,
      'lienInscription': lienInscription,
      'lienBillet': lienBillet,
      'estPopulaire': estPopulaire,
      'tags': tags,
      'oeuvreId': oeuvreId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    
    if (tags is List) {
      return tags.map((tag) {
        if (tag is String) {
          // Si le tag contient des virgules, on le split
          if (tag.contains(',')) {
            return tag.split(',').map((t) => t.trim()).toList();
          }
          return [tag];
        }
        return [tag.toString()];
      }).expand((element) => element).toList();
    }
    
    return [];
  }

  // Getters utiles
  bool get estPasse => DateTime.now().isAfter(dateFin);
  bool get estEnCours => DateTime.now().isAfter(dateDebut) && DateTime.now().isBefore(dateFin);
  bool get estAVenir => DateTime.now().isBefore(dateDebut);
  bool get estComplet => nombreInscriptions >= capaciteMax;
  
  String get dateFormatee {
    final mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${dateDebut.day} ${mois[dateDebut.month]} ${dateDebut.year}';
  }

  String get prixFormate {
    if (gratuit) return 'Gratuit';
    return '$prix FCFA';
  }
}

// Enum pour les types d'événements
enum TypeEvenement {
  SPECTACLE,
  ATELIER,
  CONFERENCE,
  VISITE_GUIDEE,
  EXPOSITION,
  AUTRE
}

// Enum pour les statuts
enum StatutEvenement {
  A_VENIR,
  EN_COURS,
  TERMINE,
  ANNULE
}

// Extensions pour faciliter l'utilisation
extension TypeEvenementExtension on TypeEvenement {
  String get label {
    switch (this) {
      case TypeEvenement.SPECTACLE:
        return 'Spectacle';
      case TypeEvenement.ATELIER:
        return 'Atelier';
      case TypeEvenement.CONFERENCE:
        return 'Conférence';
      case TypeEvenement.VISITE_GUIDEE:
        return 'Visite guidée';
      case TypeEvenement.EXPOSITION:
        return 'Exposition';
      case TypeEvenement.AUTRE:
        return 'Autre';
    }
  }
}

extension StatutEvenementExtension on StatutEvenement {
  String get label {
    switch (this) {
      case StatutEvenement.A_VENIR:
        return 'À venir';
      case StatutEvenement.EN_COURS:
        return 'En cours';
      case StatutEvenement.TERMINE:
        return 'Terminé';
      case StatutEvenement.ANNULE:
        return 'Annulé';
    }
  }
}