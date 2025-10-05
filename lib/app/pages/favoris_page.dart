import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/favoris_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_color.dart';
import '../widgets/custom_bottom_nav.dart';

class FavoritesPage extends GetView<FavorisController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Obx(() {
            final user = authController.currentUser.value;
            if (user != null) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          user.prenom,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshFavoris,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                strokeWidth: 3,
              ),
            );
          }

          final favoriteOeuvres = controller.getFavoriteOeuvres();

          if (favoriteOeuvres.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Statistiques
              _buildStatsCard(favoriteOeuvres.length),
              const SizedBox(height: 24),

              // Grille des favoris
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favoriteOeuvres.length,
                itemBuilder: (context, index) {
                  final oeuvre = favoriteOeuvres[index];
                  return _buildOeuvreCard(oeuvre);
                },
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildStatsCard(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Œuvre${count > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dans vos favoris',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun favori',
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Explorez les œuvres et ajoutez-les à vos favoris en appuyant sur le cœur',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.explore),
            label: const Text('Explorer les œuvres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOeuvreCard(dynamic oeuvre) {
    return GestureDetector(
      onTap: () => Get.toNamed('/detail', arguments: oeuvre),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Hero(
                      tag: 'oeuvre-${oeuvre.id}',
                      child: CachedNetworkImage(
                        imageUrl: oeuvre.imageUrl ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.cardBackground,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.cardBackground,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.toggleFavorite(oeuvre.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oeuvre.titre ?? 'Sans titre',
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          oeuvre.artiste ?? 'Artiste inconnu',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}