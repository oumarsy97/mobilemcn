import 'package:get/get.dart';
import 'package:mcn/app/pages/favoris_page.dart';
import '../bindings/evenement_binding.dart';
import '../bindings/favoris_binding.dart';
import '../controllers/virtual_tour_controller.dart';
import '../pages/about_page.dart';
import '../pages/evenement_detail_page.dart';
import '../pages/evenement_page.dart';
import '../pages/home_page.dart';
import '../pages/detail_page.dart';
import '../pages/mes_inscriptions_page.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/auth_page.dart';
import '../bindings/home_binding.dart';
import '../bindings/auth_binding.dart';
import '../pages/splash_page.dart';
import '../pages/virtual_tour_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.AUTH,
      page: () => const AuthPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
      binding: FavorisBinding(),
      transition: Transition.fadeIn,
    ),
    //about
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutPage(),
      transition: Transition.fadeIn,
    ),
     GetPage(
  name: AppRoutes.virtualTour,
  page: () => const VirtualTourPage(),
  binding: BindingsBuilder(() {
    Get.lazyPut<VirtualTourController>(() => VirtualTourController());
  }),
  transition: Transition.fadeIn,
),
GetPage(
      name: AppRoutes.evenements,
      page: () => const EvenementsPage(),
      binding: EvenementBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.evenementDetail,
      page: () => const EvenementDetailPage(),
      binding: EvenementBinding(), // AJOUTEZ CETTE LIGNE
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.mesInscriptions,
      page: () => const MesInscriptionsPage(),
      binding: EvenementBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}