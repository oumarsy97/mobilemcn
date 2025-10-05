import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_color.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Obx(() {
              if (authController.isLoggedIn.value) {
                return _buildUserProfile(authController);
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Accueil',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  
                  _buildDrawerItem(
                    icon: Icons.view_in_ar_rounded,
                    title: 'Visite Virtuelle',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/virtual-tour');
                    },
                  ),
                  
                  _buildDrawerItem(
                    icon: Icons.event_rounded,
                    title: 'Événements',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/evenements');
                    },
                  ),
                  
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return _buildDrawerItem(
                        icon: Icons.event_available_rounded,
                        title: 'Mes Inscriptions',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/mes-inscriptions');
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  
                  _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: 'À propos',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/about');
                    },
                  ),
                  
                  const Divider(height: 32, thickness: 1),
                  
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return _buildDrawerItem(
                        icon: Icons.logout_rounded,
                        title: 'Déconnexion',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Get.back();
                          _showLogoutDialog(authController);
                        },
                      );
                    } else {
                      return _buildDrawerItem(
                        icon: Icons.login_rounded,
                        title: 'Connexion',
                        iconColor: AppColors.primary,
                        textColor: AppColors.primary,
                        onTap: () {
                          Get.back();
                          Get.toNamed('/auth');
                        },
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Logo circulaire avec border
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.museum,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'MCN Museum',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Civilisations Noires',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(AuthController authController) {
    final user = authController.currentUser.value;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Utilisateur',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Déconnexion',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Déconnecter',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}