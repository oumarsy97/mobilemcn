import 'package:get/get.dart';
import '../models/utilisateur_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<UtilisateurModel?> currentUser = Rx<UtilisateurModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Vérifier si l'utilisateur est connecté au démarrage
  Future<void> checkLoginStatus() async {
    try {
      final localUser = await _authService.getLocalUser();
      if (localUser != null) {
        currentUser.value = localUser;
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Erreur checkLoginStatus: $e');
    }
  }

  // Inscription
  Future<bool> register({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    String languePreferee = 'FR',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: motDePasse,
        languePreferee: languePreferee,
      );

      currentUser.value = user;
      isLoggedIn.value = true;

      Get.snackbar(
        'Succès',
        'Compte créé avec succès !',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Get.theme.colorScheme.surface,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surface,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Connexion
  Future<bool> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.login(
        email: email,
        motDePasse: motDePasse,
      );

      currentUser.value = user;
      isLoggedIn.value = true;

      Get.snackbar(
        'Succès',
        'Connexion réussie !',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.surface,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surface,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;

      Get.snackbar(
        'Déconnexion',
        'Vous avez été déconnecté',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.surface,
      );

      // Retourner à l'accueil
      Get.offAllNamed('/home');
    } catch (e) {
      print('Erreur logout: $e');
    }
  }

  // Obtenir l'ID utilisateur
  String? getUserId() {
    return currentUser.value?.id;
  }
}