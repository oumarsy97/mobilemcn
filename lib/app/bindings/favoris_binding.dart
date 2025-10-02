// bindings/favoris_binding.dart
import 'package:get/get.dart';
import '../controllers/favoris_controller.dart';
import '../services/favoris_service.dart';

class FavorisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriService>(() => FavoriService());
    Get.lazyPut<FavorisController>(() => FavorisController());
  }
}
