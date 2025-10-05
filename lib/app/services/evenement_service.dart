import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/evenement_model.dart';

class EvenementService extends GetConnect {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = 'application/json';
    
    // Intercepteur pour logger les requêtes (optionnel)
    httpClient.addRequestModifier<dynamic>((request) {
      return request;
    });
    
    httpClient.addResponseModifier((request, response) {
      return response;
    });
    
    super.onInit();
  }

  // Récupérer tous les événements avec filtres
  Future<List<EvenementModel>> getAllEvenements({
    int? limit,
    int? page,
    String? type,
    String? statut,
    bool? gratuit,
    bool? populaire,
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (type != null) queryParams['type'] = type;
      if (statut != null) queryParams['statut'] = statut;
      if (gratuit != null) queryParams['gratuit'] = gratuit.toString();
      if (populaire != null) queryParams['populaire'] = populaire.toString();
      if (dateDebut != null) queryParams['dateDebut'] = dateDebut;
      if (dateFin != null) queryParams['dateFin'] = dateFin;

      final response = await get('/evenements', query: queryParams);

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'];
        if (list is List) {
          return list.map((json) => EvenementModel.fromJson(json)).toList();
        }
      } else if (data is List) {
        return data.map((json) => EvenementModel.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur getAllEvenements: $e');
      rethrow;
    }
  }

  // Récupérer un événement par ID
  Future<EvenementModel> getEvenementById(String id) async {
    try {
      final response = await get('/evenements/$id');

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      // Si l'API retourne { "data": {...} }
      if (data is Map && data.containsKey('data')) {
        return EvenementModel.fromJson(data['data']);
      }
      
      // Si l'API retourne directement l'objet
      return EvenementModel.fromJson(data);
    } catch (e) {
      print('Erreur getEvenementById: $e');
      rethrow;
    }
  }

  // Récupérer les statistiques
  Future<Map<String, dynamic>> getStatistiques() async {
    try {
      final response = await get('/evenements/statistiques');

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }
      
      return data;
    } catch (e) {
      print('Erreur getStatistiques: $e');
      rethrow;
    }
  }

  // Inscription à un événement
  // Dans evenement_service.dart
Future<Map<String, dynamic>> inscrire({
  required String evenementId,
  int nombrePlaces = 1,
}) async {
  try {
    final response = await post(
      '/evenements/inscription',
      {
        'evenementId': evenementId,
        'nombrePlaces': nombrePlaces,
      },
    );

    if (response.hasError) {
      final errorMessage = response.body?['message'] ?? 'Erreur lors de l\'inscription';
      throw Exception(errorMessage);
    }

    return response.body;
  } catch (e) {
    print('Erreur inscrire: $e');
    rethrow;
  }
}
  // Désinscription d'un événement
  Future<Map<String, dynamic>> desinscrire({
    required String evenementId,
    required String utilisateurId,
  }) async {
    try {
      final response = await delete(
        '/evenements/$evenementId/inscription',
      );

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      return response.body;
    } catch (e) {
      print('Erreur desinscrire: $e');
      rethrow;
    }
  }

  // Récupérer les inscriptions d'un événement
  Future<List<dynamic>> getInscriptions(String evenementId) async {
    try {
      final response = await get('/evenements/$evenementId/inscriptions');

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else if (data is List) {
        return data;
      }
      
      return [];
    } catch (e) {
      print('Erreur getInscriptions: $e');
      rethrow;
    }
  }

  // Récupérer mes inscriptions
  Future<List<EvenementModel>> getMesInscriptions() async {
    try {
      final response = await get('/evenements/user/mes-inscriptions');

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'];
        if (list is List) {
          return list.map((json) {
            // L'API peut retourner l'événement dans une propriété 'evenement'
            if (json is Map && json.containsKey('evenement')) {
              return EvenementModel.fromJson(json['evenement']);
            }
            return EvenementModel.fromJson(json);
          }).toList();
        }
      } else if (data is List) {
        return data.map((json) {
          if (json is Map && json.containsKey('evenement')) {
            return EvenementModel.fromJson(json['evenement']);
          }
          return EvenementModel.fromJson(json);
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur getMesInscriptions: $e');
      rethrow;
    }
  }

  // Récupérer les événements populaires
  Future<List<EvenementModel>> getEvenementsPopulaires({int limit = 5}) async {
    return getAllEvenements(
      populaire: true,
      limit: limit,
    );
  }

  // Récupérer les événements à venir
  Future<List<EvenementModel>> getEvenementsAVenir({int limit = 10}) async {
    return getAllEvenements(
      statut: 'A_VENIR',
      limit: limit,
    );
  }

  // Récupérer les événements gratuits
  Future<List<EvenementModel>> getEvenementsGratuits({int limit = 10}) async {
    return getAllEvenements(
      gratuit: true,
      limit: limit,
    );
  }

  // Récupérer les événements par type
  Future<List<EvenementModel>> getEvenementsByType(String type, {int limit = 10}) async {
    return getAllEvenements(
      type: type,
      limit: limit,
    );
  }
}