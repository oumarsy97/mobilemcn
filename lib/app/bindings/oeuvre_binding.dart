// bindings/oeuvre_binding.dart
import 'package:get/get.dart';
import '../controllers/oeuvre_controller.dart';
import '../services/oeuvre_service.dart';

class OeuvreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OeuvreService>(() => OeuvreService());
    Get.lazyPut<OeuvreController>(() => OeuvreController());
  }
}
