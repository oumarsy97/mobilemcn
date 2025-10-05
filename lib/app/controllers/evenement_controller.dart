import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/evenement_model.dart';
import '../services/evenement_service.dart';

class EvenementController extends GetxController {
  final EvenementService _evenementService = EvenementService();

  // Observable lists
  final RxList<EvenementModel> evenements = <EvenementModel>[].obs;
  final RxList<EvenementModel> evenementsPopulaires = <EvenementModel>[].obs;
  final RxList<EvenementModel> mesInscriptions = <EvenementModel>[].obs;
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<EvenementModel?> selectedEvenement = Rx<EvenementModel?>(null);
  
  // Statistiques
  final RxMap<String, dynamic> statistiques = <String, dynamic>{}.obs;
  
  // Filtres
  final RxString selectedType = 'TOUS'.obs;
  final RxString selectedStatut = 'TOUS'.obs;
  final RxBool showGratuitOnly = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvenements();
    loadEvenementsPopulaires();
  }

  // Charger tous les événements
  Future<void> loadEvenements({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
      }
      
      isLoading.value = true;
      errorMessage.value = '';

      final List<EvenementModel> result = await _evenementService.getAllEvenements(
        page: currentPage.value,
        limit: 10,
        type: selectedType.value != 'TOUS' ? selectedType.value : null,
        statut: selectedStatut.value != 'TOUS' ? selectedStatut.value : null,
        gratuit: showGratuitOnly.value ? true : null,
      );

      if (refresh) {
        evenements.value = result;
      } else {
        evenements.addAll(result);
      }

      hasMore.value = result.length >= 10;
      
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des événements: $e';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger plus d'événements (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await loadEvenements();
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Charger les événements populaires
  Future<void> loadEvenementsPopulaires() async {
    try {
      final result = await _evenementService.getEvenementsPopulaires(limit: 5);
      evenementsPopulaires.value = result;
    } catch (e) {
      print('Erreur lors du chargement des événements populaires: $e');
    }
  }

  // Charger un événement par ID
  Future<void> loadEvenementById(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _evenementService.getEvenementById(id);
      selectedEvenement.value = result;
      
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de l\'événement: $e';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les statistiques
  Future<void> loadStatistiques() async {
    try {
      final result = await _evenementService.getStatistiques();
      statistiques.value = result;
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }
  }

  // Inscription à un événement
  // Dans evenement_controller.dart
Future<bool> inscrire({
  required String evenementId,
  int nombrePlaces = 1,
}) async {
  try {
    isLoading.value = true;
    
    await _evenementService.inscrire(
      evenementId: evenementId,
      nombrePlaces: nombrePlaces,
    );

    Get.snackbar(
      'Succès',
      'Inscription réussie !',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Recharger l'événement
    await loadEvenementById(evenementId);
    
    return true;
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Erreur lors de l\'inscription: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  } finally {
    isLoading.value = false;
  }
}
  // Charger mes inscriptions
  Future<void> loadMesInscriptions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _evenementService.getMesInscriptions();
      mesInscriptions.value = result;
      
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de vos inscriptions: $e';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Désinscription d'un événement
  Future<bool> desinscrire({
    required String evenementId,
    required String utilisateurId,
  }) async {
    try {
      isLoading.value = true;
      
      await _evenementService.desinscrire(
        evenementId: evenementId,
        utilisateurId: utilisateurId,
      );

      // Retirer l'événement de la liste des inscriptions
      mesInscriptions.removeWhere((e) => e.id == evenementId);
      
      // Mettre à jour l'événement dans la liste principale si présent
      final index = evenements.indexWhere((e) => e.id == evenementId);
      if (index != -1) {
        await loadEvenementById(evenementId);
      }
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la désinscription: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer par type
  void filterByType(String type) {
    selectedType.value = type;
    loadEvenements(refresh: true);
  }

  // Filtrer par statut
  void filterByStatut(String statut) {
    selectedStatut.value = statut;
    loadEvenements(refresh: true);
  }

  // Toggle gratuit
  void toggleGratuit() {
    showGratuitOnly.value = !showGratuitOnly.value;
    loadEvenements(refresh: true);
  }

  // Réinitialiser les filtres
  void resetFilters() {
    selectedType.value = 'TOUS';
    selectedStatut.value = 'TOUS';
    showGratuitOnly.value = false;
    loadEvenements(refresh: true);
  }

  // Rafraîchir
  Future<void> refresh() async {
    await loadEvenements(refresh: true);
    await loadEvenementsPopulaires();
  }

  // Getters utiles
  List<EvenementModel> get evenementsAVenir {
    return evenements.where((e) => e.estAVenir).toList();
  }

  List<EvenementModel> get evenementsEnCours {
    return evenements.where((e) => e.estEnCours).toList();
  }

  List<EvenementModel> get evenementsGratuits {
    return evenements.where((e) => e.gratuit).toList();
  }

  List<EvenementModel> get evenementsByType {
    if (selectedType.value == 'TOUS') return evenements;
    return evenements.where((e) => e.type == selectedType.value).toList();
  }

  int get totalEvenements => evenements.length;
  
  bool get hasEvenements => evenements.isNotEmpty;
  
  bool get hasEvenementsPopulaires => evenementsPopulaires.isNotEmpty;
  
  bool get hasMesInscriptions => mesInscriptions.isNotEmpty;
}