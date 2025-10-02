import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/favoris_model.dart';
import '../utils/constants.dart';

class FavoriService {
  final GetStorage _storage = GetStorage();

  // Récupérer le token d'authentification
  String? _getToken() {
    return _storage.read(Constants.tokenKey);
  }

  // Headers avec authentification
  Map<String, String> _getHeaders() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Récupérer tous les favoris de l'utilisateur
  Future<List<FavoriModel>> getFavoris(String utilisateurId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/favori/user/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FavoriModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des favoris');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Ajouter un favori
  Future<FavoriModel> ajouterFavori({
    required String utilisateurId,
    required String oeuvreId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/favori'),
        headers: _getHeaders(),
        body: jsonEncode({
          'utilisateurId': utilisateurId,
          'oeuvreId': oeuvreId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return FavoriModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'ajout du favori');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Supprimer un favori
  Future<void> supprimerFavori(String favoriId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/favori/$favoriId'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du favori');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Vérifier si une oeuvre est en favori
  Future<bool> isFavori({
    required String utilisateurId,
    required String oeuvreId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/favori/check/$utilisateurId/$oeuvreId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavori'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sauvegarder les favoris localement (cache)
  Future<void> saveFavorisLocally(List<String> oeuvreIds) async {
    await _storage.write(Constants.favoritesKey, oeuvreIds);
  }

  // Récupérer les favoris locaux
  List<String> getLocalFavoris() {
    final favoris = _storage.read<List>(Constants.favoritesKey);
    if (favoris != null) {
      return favoris.map((e) => e.toString()).toList();
    }
    return [];
  }
}