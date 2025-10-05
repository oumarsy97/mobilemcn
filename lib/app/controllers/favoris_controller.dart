import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/favoris_model.dart';
import '../services/favoris_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/oeuvre_controller.dart';

class FavorisController extends GetxController {
  final FavoriService _favoriService = FavoriService();
  
  final RxList<FavoriModel> favoris = <FavoriModel>[].obs;
  final RxList<String> favoriOeuvreIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavoris();
  }

  // Charger les favoris de l'utilisateur connecté
  Future<void> loadFavoris() async {
    try {
      isLoading.value = true;
      
      final authController = Get.find<AuthController>();
      final userId = authController.getUserId();
      
      if (userId == null) {
        favoris.clear();
        favoriOeuvreIds.clear();
        return;
      }

      final fetchedFavoris = await _favoriService.getFavoris(userId);
      favoris.assignAll(fetchedFavoris); // ✅ Utiliser assignAll au lieu de value
      favoriOeuvreIds.assignAll(fetchedFavoris.map((f) => f.oeuvreId).toList());
      
    } catch (e) {
      print('Erreur loadFavoris: $e');
      favoris.clear();
      favoriOeuvreIds.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Vérifier si une oeuvre est en favori
  bool isFavorite(String oeuvreId) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) return false;
    return favoriOeuvreIds.contains(oeuvreId);
  }

  // Ajouter/Supprimer un favori (toggle)
  Future<void> toggleFavorite(String oeuvreId) async {
    if (isProcessing.value) return;

    final authController = Get.find<AuthController>();
    
    if (!authController.isLoggedIn.value) {
      Get.snackbar(
        'Connexion requise',
        'Veuillez vous connecter pour ajouter des favoris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.lock, color: Colors.white),
      );
      return;
    }

    try {
      isProcessing.value = true;
      
      final userId = authController.getUserId();
      if (userId == null) return;

      if (isFavorite(oeuvreId)) {
        // ✅ SUPPRESSION
        final favori = favoris.firstWhereOrNull((f) => f.oeuvreId == oeuvreId);
        if (favori != null) {
          // Appel API d'abord
          await _favoriService.supprimerFavori(favori.id);
          
          // ✅ Mise à jour UI après succès API
          favoris.removeWhere((f) => f.oeuvreId == oeuvreId);
          favoriOeuvreIds.remove(oeuvreId);
          
          // ✅ Force la mise à jour
          update();
          
          Get.snackbar(
            'Retiré',
            'Œuvre retirée de vos favoris',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.favorite_border, color: Colors.white),
          );
        }
      } else {
        // ✅ AJOUT
        final newFavori = await _favoriService.ajouterFavori(
          utilisateurId: userId,
          oeuvreId: oeuvreId,
        );
        
        favoris.add(newFavori);
        favoriOeuvreIds.add(oeuvreId);
        
        // ✅ Force la mise à jour
        update();
        
        Get.snackbar(
          'Ajouté',
          'Œuvre ajoutée à vos favoris',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.favorite, color: Colors.white),
        );
      }
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier les favoris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      print('Erreur toggleFavorite: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  // Récupérer les oeuvres favorites
  List<dynamic> getFavoriteOeuvres() {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) return [];
    
    try {
      final oeuvreController = Get.find<OeuvreController>();
      return oeuvreController.oeuvres
          .where((oeuvre) => favoriOeuvreIds.contains(oeuvre.id))
          .toList();
    } catch (e) {
      print('Erreur getFavoriteOeuvres: $e');
      return [];
    }
  }

  // Rafraîchir les favoris
  Future<void> refreshFavoris() async {
    await loadFavoris();
  }

  // Vider tous les favoris (lors de la déconnexion)
  void clearFavoris() {
    favoris.clear();
    favoriOeuvreIds.clear();
    update();
  }
}