import 'package:get/get.dart';
import 'package:mcn/app/controllers/favoris_controller.dart';
import '../controllers/oeuvre_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../services/favoris_service.dart';
import '../services/oeuvre_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialiser AuthService et AuthController en premier
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      // Puis OeuvreService
    Get.lazyPut<OeuvreService>(() => OeuvreService());
    //favoriservice
    Get.lazyPut<FavorisController>(() => FavorisController());
    // Puis OeuvreController
    Get.lazyPut<OeuvreController>(() => OeuvreController());
  }
}