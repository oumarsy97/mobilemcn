import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcn/app/widgets/custom_bottom_nav.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/utils/app_color.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser les locales pour intl
  await initializeDateFormatting('fr_FR', null);
  Get.put(NavigationController()); 
  
  
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MCN Museum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
    );
  }
}