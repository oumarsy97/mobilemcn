import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/oeuvre_model.dart';
import '../services/oeuvre_service.dart';

class OeuvreController extends GetxController {
  final OeuvreService _oeuvreService = OeuvreService();

  final RxList<OeuvreModel> oeuvres = <OeuvreModel>[].obs;
  final RxList<OeuvreModel> filteredOeuvres = <OeuvreModel>[].obs;
  final Rx<OeuvreModel?> selectedOeuvre = Rx<OeuvreModel?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  
  final RxString selectedLangue = 'FR'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedArtiste = ''.obs;
  final RxString selectedCategorie = ''.obs;
  final RxString selectedMedium = ''.obs;

  // Gestion des favoris (stockés localement pour l'instant)
  final RxList<String> favoriteIds = <String>[].obs;
  final RxBool isUserConnected = false.obs; // Simuler l'état de connexion

  @override
  void onInit() {
    super.onInit();
    loadOeuvres();
    _loadFavorites();
  }

  // Charger les favoris depuis le stockage local (ou API si connecté)
  Future<void> _loadFavorites() async {
    // TODO: Implémenter le chargement depuis SharedPreferences ou API
    // Pour l'instant, liste vide
    favoriteIds.clear();
  }

  // Charger toutes les œuvres
  Future<void> loadOeuvres() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _oeuvreService.getAllOeuvres(langue: selectedLangue.value);
      oeuvres.value = data;
      filteredOeuvres.value = data;
      
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des œuvres: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pull to refresh
  Future<void> refreshOeuvres() async {
    try {
      isRefreshing.value = true;
      final data = await _oeuvreService.getAllOeuvres(langue: selectedLangue.value);
      oeuvres.value = data;
      
      // Réappliquer les filtres ou la recherche si actifs
      if (searchQuery.value.isNotEmpty) {
        await searchOeuvres(searchQuery.value);
      } else if (selectedArtiste.value.isNotEmpty || 
                 selectedCategorie.value.isNotEmpty ||
                 selectedMedium.value.isNotEmpty) {
        applyFilters();
      } else {
        filteredOeuvres.value = data;
      }
      
      Get.snackbar(
        'Succès',
        'Liste actualisée',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'actualiser: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Rechercher des œuvres
  Future<void> searchOeuvres(String query) async {
    try {
      searchQuery.value = query;
      
      if (query.isEmpty) {
        filteredOeuvres.value = oeuvres;
        return;
      }
      
      isSearching.value = true;
      final results = await _oeuvreService.searchOeuvres(query, langue: selectedLangue.value);
      filteredOeuvres.value = results;
      
    } catch (e) {
      errorMessage.value = 'Erreur lors de la recherche: ${e.toString()}';
    } finally {
      isSearching.value = false;
    }
  }

  // Filtrer les œuvres
  void applyFilters() {
    var results = List<OeuvreModel>.from(oeuvres);
    
    if (selectedArtiste.value.isNotEmpty) {
      results = results.where((o) => 
        o.artiste.toLowerCase().contains(selectedArtiste.value.toLowerCase())
      ).toList();
    }
    
    if (selectedCategorie.value.isNotEmpty) {
      results = results.where((o) => 
        o.categorie.toLowerCase() == selectedCategorie.value.toLowerCase()
      ).toList();
    }
    
    filteredOeuvres.value = results;
  }

  // Réinitialiser les filtres
  void resetFilters() {
    selectedArtiste.value = '';
    selectedCategorie.value = '';
    selectedMedium.value = '';
    searchQuery.value = '';
    filteredOeuvres.value = oeuvres;
  }

  // Sélectionner une œuvre
  Future<void> selectOeuvre(String id) async {
    try {
      isLoading.value = true;
      final oeuvre = await _oeuvreService.getOeuvreById(id, langue: selectedLangue.value);
      selectedOeuvre.value = oeuvre;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de l\'œuvre: ${e.toString()}';
      Get.snackbar('Erreur', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Scanner QR Code
  Future<void> scanQrCode(String qrCode) async {
    try {
      isLoading.value = true;
      final oeuvre = await _oeuvreService.getOeuvreByQrCode(qrCode, langue: selectedLangue.value);
      selectedOeuvre.value = oeuvre;
      Get.toNamed('/detail', arguments: oeuvre);
    } catch (e) {
      errorMessage.value = 'Œuvre non trouvée pour ce QR Code';
      Get.snackbar('Erreur', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Changer de langue
  void changeLangue(String langue) {
    selectedLangue.value = langue;
    loadOeuvres();
  }

  // Gestion des favoris
  bool isFavorite(String oeuvreId) {
    return favoriteIds.contains(oeuvreId);
  }

  void toggleFavorite(String oeuvreId) {
    if (!isUserConnected.value) {
      // Afficher dialogue de connexion
      _showLoginDialog();
      return;
    }

    if (favoriteIds.contains(oeuvreId)) {
      favoriteIds.remove(oeuvreId);
      Get.snackbar(
        'Favori',
        'Retiré des favoris',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteIds.add(oeuvreId);
      Get.snackbar(
        'Favori',
        'Ajouté aux favoris',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
    
    // TODO: Synchroniser avec l'API
    _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    // TODO: Sauvegarder dans SharedPreferences ou API
  }

  void _showLoginDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: Get.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connexion requise',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vous devez être connecté pour ajouter des œuvres à vos favoris',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Plus tard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/login'); // Navigation vers page de connexion
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Se connecter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Obtenir les artistes uniques
  List<String> get uniqueArtistes {
    return oeuvres.map((o) => o.artiste).toSet().toList()..sort();
  }

  // Obtenir les catégories uniques
  List<String> get uniqueCategories {
    return oeuvres.map((o) => o.categorie).toSet().toList()..sort();
  }
}