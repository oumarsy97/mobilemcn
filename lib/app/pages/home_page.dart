import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/oeuvre_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favoris_controller.dart';
import '../utils/app_color.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final oeuvreController = Get.find<OeuvreController>();
    final authController = Get.find<AuthController>();
    final favoriController = Get.find<FavorisController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(authController),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await oeuvreController.refreshOeuvres();
            await favoriController.refreshFavoris();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(oeuvreController),
              _buildHeroSection(authController),
              _buildExpositionsSection(oeuvreController),
              _buildOeuvresGrid(oeuvreController, favoriController),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Méthode pour récupérer le titre selon la langue
  String _getTitre(dynamic oeuvre, String langue) {
    switch (langue) {
      case 'FR':
        return oeuvre.titreFr ?? oeuvre.titre ?? 'Sans titre';
      case 'EN':
        return oeuvre.titreEn ?? oeuvre.titre ?? 'Untitled';
      case 'WO':
        return oeuvre.titreWo ?? oeuvre.titre ?? 'Ñuul tuddu';
      default:
        return oeuvre.titre ?? 'Sans titre';
    }
  }

  // ✅ Méthode pour récupérer la description selon la langue
  String _getDescription(dynamic oeuvre, String langue) {
    switch (langue) {
      case 'FR':
        return oeuvre.descriptionFr ?? oeuvre.description ?? '';
      case 'EN':
        return oeuvre.descriptionEn ?? oeuvre.description ?? '';
      case 'WO':
        return oeuvre.descriptionWo ?? oeuvre.description ?? '';
      default:
        return oeuvre.description ?? '';
    }
  }

  Widget _buildDrawer(AuthController authController) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.museum,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MCN Museum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Civilisations Noires',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Obx(() {
              if (authController.isLoggedIn.value) {
                final user = authController.currentUser.value;
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Utilisateur',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
              return const SizedBox.shrink();
            }),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Accueil',
                    onTap: () {
                      Get.back();
                    },
                  ),
                  // ✅ Afficher "Mes Favoris" seulement si connecté
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return _buildDrawerItem(
                        icon: Icons.favorite,
                        title: 'Mes Favoris',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/favorites');
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner,
                    title: 'Scanner QR',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/qr-scanner');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Paramètres',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/settings');
                    },
                  ),
                  const Divider(height: 32),
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return _buildDrawerItem(
                        icon: Icons.logout,
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
                        icon: Icons.login,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(OeuvreController oeuvreController) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Builder(
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.museum,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MCN',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Civilisations Noires',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildLanguageSelector(oeuvreController),
            const SizedBox(width: 8),
            _buildQRButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(OeuvreController oeuvreController) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: oeuvreController.selectedLangue.value,
          icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
          isDense: true,
          items: const [
            DropdownMenuItem(value: 'FR', child: Text('FR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'EN', child: Text('EN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'WO', child: Text('WO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
          onChanged: (value) {
            if (value != null) oeuvreController.changeLangue(value);
          },
        ),
      ),
    ));
  }

  Widget _buildQRButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => Get.toNamed('/qr-scanner'),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildHeroSection(AuthController authController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() {
                      if (authController.isLoggedIn.value) {
                        final user = authController.currentUser.value;
                        return Text(
                          'Bienvenue ${user?.prenom ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return const Text(
                        'Bienvenue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Découvrez\nL\'Art Africain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorez les trésors du Musée des Civilisations Noires',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpositionsSection(OeuvreController oeuvreController) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Expositions Actuelles',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => oeuvreController.searchOeuvres(value),
              decoration: InputDecoration(
                hintText: 'Rechercher œuvres, artistes...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Obx(() => oeuvreController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => oeuvreController.searchOeuvres(''),
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOeuvresGrid(OeuvreController oeuvreController, FavorisController favoriController) {
    return Obx(() {
      if (oeuvreController.isLoading.value && oeuvreController.filteredOeuvres.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
        );
      }

      if (oeuvreController.filteredOeuvres.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.art_track,
                    size: 60,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Aucune œuvre trouvée',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tirez pour actualiser',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final oeuvre = oeuvreController.filteredOeuvres[index];
              return _buildOeuvreCard(oeuvre, favoriController, oeuvreController);
            },
            childCount: oeuvreController.filteredOeuvres.length,
          ),
        ),
      );
    });
  }

  // ✅ Modifié pour utiliser la langue sélectionnée
  Widget _buildOeuvreCard(dynamic oeuvre, FavorisController favoriController, OeuvreController oeuvreController) {
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
                          child: const Icon(Icons.image_not_supported, size: 40, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  ),
                  // ✅ Bouton favori visible seulement si connecté
                  Obx(() {
                    final authController = Get.find<AuthController>();
                    if (!authController.isLoggedIn.value) {
                      return const SizedBox.shrink();
                    }
                    
                    final isFav = favoriController.isFavorite(oeuvre.id);
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => favoriController.toggleFavorite(oeuvre.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Titre multilingue
                  Obx(() {
                    final titre = _getTitre(oeuvre, oeuvreController.selectedLangue.value);
                    return Text(
                      titre,
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
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