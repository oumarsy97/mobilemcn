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
      
      // ✅ Si non connecté, ne rien charger
      if (userId == null) {
        favoris.clear();
        favoriOeuvreIds.clear();
        return;
      }

      // Charger depuis l'API
      final fetchedFavoris = await _favoriService.getFavoris(userId);
      favoris.value = fetchedFavoris;
      favoriOeuvreIds.value = fetchedFavoris.map((f) => f.oeuvreId).toList();
      
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
    // ✅ Retourner false si non connecté
    if (!authController.isLoggedIn.value) return false;
    return favoriOeuvreIds.contains(oeuvreId);
  }

  // Ajouter/Supprimer un favori (toggle)
  Future<void> toggleFavorite(String oeuvreId) async {
    if (isProcessing.value) return;

    final authController = Get.find<AuthController>();
    
    // ✅ Bloquer l'action si non connecté
    if (!authController.isLoggedIn.value) {
      Get.snackbar(
        'Connexion requise',
        'Veuillez vous connecter pour ajouter des favoris',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isProcessing.value = true;
      
      final userId = authController.getUserId();
      if (userId == null) return;

      // Gestion avec API
      if (isFavorite(oeuvreId)) {
        // Supprimer
        final favori = favoris.firstWhereOrNull((f) => f.oeuvreId == oeuvreId);
        if (favori != null) {
          await _favoriService.supprimerFavori(favori.id);
          favoris.remove(favori);
          favoriOeuvreIds.remove(oeuvreId);
          
          Get.snackbar(
            'Retiré',
            'Retiré des favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        // Ajouter
        final newFavori = await _favoriService.ajouterFavori(
          utilisateurId: userId,
          oeuvreId: oeuvreId,
        );
        favoris.add(newFavori);
        favoriOeuvreIds.add(oeuvreId);
        
        Get.snackbar(
          'Ajouté',
          'Ajouté aux favoris',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier les favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Erreur toggleFavorite: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  // Récupérer les oeuvres favorites
  List<dynamic> getFavoriteOeuvres() {
    final authController = Get.find<AuthController>();
    // ✅ Retourner liste vide si non connecté
    if (!authController.isLoggedIn.value) return [];
    
    final oeuvreController = Get.find<OeuvreController>();
    return oeuvreController.oeuvres
        .where((oeuvre) => favoriOeuvreIds.contains(oeuvre.id))
        .toList();
  }

  // Rafraîchir les favoris
  Future<void> refreshFavoris() async {
    await loadFavoris();
  }

  // ✅ Vider tous les favoris (lors de la déconnexion)
  void clearFavoris() {
    favoris.clear();
    favoriOeuvreIds.clear();
  }
}