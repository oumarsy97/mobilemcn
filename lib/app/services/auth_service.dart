import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/utilisateur_model.dart';
import '../utils/constants.dart';

class AuthService {
  final GetStorage _storage = GetStorage();
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Sauvegarder l'utilisateur localement
  Future<void> saveUser(UtilisateurModel user, String? token) async {
    await _storage.write(_userKey, user.toJson());
    if (token != null) {
      await _storage.write(_tokenKey, token);
    }
  }

  // Récupérer l'utilisateur local
  Future<UtilisateurModel?> getLocalUser() async {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return UtilisateurModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  // Récupérer le token
  String? getToken() {
    return _storage.read(_tokenKey);
  }

  // Inscription
  Future<UtilisateurModel> register({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    String languePreferee = 'FR',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/utilisateurs/inscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'motDePasse': motDePasse,
          'languePreferee': languePreferee,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // ✅ CORRECTION : L'API retourne les données dans 'data'
        final data = responseData['data'];
        final user = UtilisateurModel.fromJson(data);
        final token = data['access_token']; // ✅ Le token s'appelle 'access_token'
        
        // Sauvegarder localement
        await saveUser(user, token);
        
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Connexion
  Future<UtilisateurModel> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/utilisateurs/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'motDePasse': motDePasse,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response complète: $responseData');
        
        // ✅ CORRECTION : L'API retourne les données dans 'data'
        final data = responseData['data'];
        final user = UtilisateurModel.fromJson(data);
        final token = data['access_token']; // ✅ Le token s'appelle 'access_token'
        
        // Sauvegarder localement
        await saveUser(user, token);
        
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Email ou mot de passe incorrect');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _storage.remove(_userKey);
    await _storage.remove(_tokenKey);
  }

  // Vérifier si connecté
  bool isLoggedIn() {
    return _storage.hasData(_userKey);
  }
}