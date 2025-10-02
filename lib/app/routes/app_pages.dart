import 'package:get/get.dart';
import 'package:mcn/app/pages/favoris_page.dart';
import '../bindings/favoris_binding.dart';
import '../pages/home_page.dart';
import '../pages/detail_page.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/auth_page.dart';
import '../bindings/home_binding.dart';
import '../bindings/auth_binding.dart';
import '../pages/splash_page.dart';
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
  ];
}