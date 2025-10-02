import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/oeuvre_model.dart';

class OeuvreService extends GetConnect {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = 'application/json';
    
    // Intercepteur pour logger les requêtes (optionnel)
    httpClient.addRequestModifier<dynamic>((request) {
      print('REQUEST: ${request.method} ${request.url}');
      return request;
    });
    
    httpClient.addResponseModifier((request, response) {
      print('RESPONSE: ${response.statusCode} - ${response.body.runtimeType}');
      return response;
    });
    
    super.onInit();
  }

  // Récupérer toutes les œuvres
  Future<List<OeuvreModel>> getAllOeuvres({String langue = 'FR'}) async {
    try {
      final response = await get('/oeuvres', query: {
        'langue': langue,
      });

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      // DÉBOGAGE
      print('Type de response.body: ${response.body.runtimeType}');
      print('Contenu de response.body: ${response.body}');

      final data = response.body;
      
      if (data is List) {
        // Si c'est directement une liste
        return data.map((json) => OeuvreModel.fromJson(json)).toList();
      } else if (data is Map) {
        // Si c'est un objet avec une propriété 'data' ou 'oeuvres'
        print('Clés disponibles: ${data.keys}');
        
        final list = data['data'] ?? 
                     data['oeuvres'] ?? 
                     data['results'] ?? 
                     [];
        
        return (list as List)
            .map((json) => OeuvreModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur getAllOeuvres: $e');
      rethrow;
    }
  }

  // Rechercher des œuvres
  Future<List<OeuvreModel>> searchOeuvres(String query, {String langue = 'FR'}) async {
    try {
      final response = await get('/oeuvres/search', query: {
        'q': query,
        'langue': langue,
      });

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is List) {
        return data.map((json) => OeuvreModel.fromJson(json)).toList();
      } else if (data is Map) {
        final list = data['data'] ?? 
                     data['oeuvres'] ?? 
                     data['results'] ?? 
                     [];
        
        return (list as List)
            .map((json) => OeuvreModel.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur searchOeuvres: $e');
      rethrow;
    }
  }

  // Récupérer une œuvre par ID
  Future<OeuvreModel> getOeuvreById(String id, {String langue = 'FR'}) async {
    try {
      final response = await get('/oeuvres/$id', query: {
        'langue': langue,
      });

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      // Si l'API retourne { "data": {...} }
      if (data is Map && data.containsKey('data')) {
        return OeuvreModel.fromJson(data['data']);
      }
      
      // Si l'API retourne directement l'objet
      return OeuvreModel.fromJson(data);
    } catch (e) {
      print('Erreur getOeuvreById: $e');
      rethrow;
    }
  }

  // Récupérer une œuvre par QR Code
  Future<OeuvreModel> getOeuvreByQrCode(String qrCode, {String langue = 'FR'}) async {
    try {
      final response = await get('/oeuvres/qr/$qrCode', query: {
        'langue': langue,
      });

      if (response.hasError) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final data = response.body;
      
      if (data is Map && data.containsKey('data')) {
        return OeuvreModel.fromJson(data['data']);
      }
      
      return OeuvreModel.fromJson(data);
    } catch (e) {
      print('Erreur getOeuvreByQrCode: $e');
      throw Exception('Œuvre non trouvée pour ce QR Code');
    }
  }
}