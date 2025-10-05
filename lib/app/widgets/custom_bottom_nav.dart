import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_color.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  // Liste des items de navigation
  static const List<NavItem> navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Accueil', route: '/home'),
    NavItem(icon: Icons.favorite_rounded, label: 'Favoris', route: '/favorites'),
    NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner', route: '/qr-scanner'),
    NavItem(icon: Icons.event_rounded, label: 'Événements', route: '/evenements'),
    NavItem(icon: Icons.person_rounded, label: 'Profil', route: '/profile'),
  ];

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (!authController.isLoggedIn.value) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                navItems.length,
                (index) => _buildNavItem(
                  icon: navItems[index].icon,
                  label: navItems[index].label,
                  route: navItems[index].route,
                  index: index,
                  isSelected: currentIndex == index,
                  isCenter: index == 2,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required int index,
    required bool isSelected,
    bool isCenter = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Éviter la navigation si déjà sur la page
        if (index == currentIndex) return;
        
        // Navigation selon l'index
        if (index == 0) {
          // Accueil - remplace tout
          Get.offAllNamed(route);
        } else {
          // Autres pages - navigation normale
          Get.toNamed(route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: isCenter && isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                )
              : isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isCenter && isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCenter && isSelected
                  ? Colors.white
                  : isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
              size: isCenter ? 26 : 22,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isCenter ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Controller pour gérer la navigation (OPTIONNEL)
class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    if (currentIndex.value == index) return;
    
    currentIndex.value = index;
    
    if (index < CustomBottomNav.navItems.length) {
      final route = CustomBottomNav.navItems[index].route;
      
      if (index == 0) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
    }
  }
}