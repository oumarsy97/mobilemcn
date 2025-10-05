import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/oeuvre_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favoris_controller.dart';
import '../utils/app_color.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/app_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final oeuvreController = Get.find<OeuvreController>();
    final authController = Get.find<AuthController>();
    final favoriController = Get.find<FavorisController>();
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await oeuvreController.refreshOeuvres();
            await favoriController.refreshFavoris();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(scaffoldKey, oeuvreController),
              _buildHeroSection(authController),
              _buildVirtualTourButton(),
              _buildSearchSection(oeuvreController),
              _buildOeuvresGrid(oeuvreController, favoriController),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildAppBar(GlobalKey<ScaffoldState> scaffoldKey, OeuvreController oeuvreController) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Bouton Menu
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: IconButton(
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                padding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(width: 12),
            
            // Logo circulaire
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.museum,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Texte MCN
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
            
            // Sélecteur de langue
            _buildLanguageSelector(oeuvreController),
            const SizedBox(width: 8),
            
            // Bouton QR Scanner
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
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.85),
              AppColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Cercles décoratifs
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge bienvenue
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(() {
                      if (authController.isLoggedIn.value) {
                        final user = authController.currentUser.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.waving_hand,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bienvenue ${user?.prenom ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Bienvenue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titre principal
                  const Text(
                    'Explorez l\'Héritage\nAfricain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    'Découvrez les trésors et l\'histoire des Civilisations Noires',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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

  Widget _buildVirtualTourButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed('/virtual-tour'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.view_in_ar,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visite Virtuelle 360°',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explorez le musée depuis chez vous',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(OeuvreController oeuvreController) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Nos Œuvres',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => oeuvreController.searchOeuvres(value),
              decoration: InputDecoration(
                hintText: 'Rechercher une œuvre...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 24),
                suffixIcon: Obx(() => oeuvreController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 22),
                        onPressed: () => oeuvreController.searchOeuvres(''),
                      )
                    : const SizedBox.shrink()),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOeuvresGrid(OeuvreController oeuvreController, FavorisController favoriController) {
    return Obx(() {
      if (oeuvreController.isLoading.value && oeuvreController.filteredOeuvres.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.art_track,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune œuvre trouvée',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tirez vers le bas pour actualiser',
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
            childAspectRatio: 0.68,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
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

  Widget _buildOeuvreCard(dynamic oeuvre, FavorisController favoriController, OeuvreController oeuvreController) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Get.toNamed('/detail', arguments: oeuvre),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Hero(
                        tag: 'oeuvre-${oeuvre.id}',
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
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
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Obx(() {
                      final isFav = favoriController.isFavorite(oeuvre.id);
                      return GestureDetector(
                        onTap: () => favoriController.toggleFavorite(oeuvre.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oeuvre.titre ?? 'Sans titre',
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            oeuvre.artiste ?? 'Artiste inconnu',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final description = oeuvre.getDescription(oeuvreController.selectedLangue.value);
                      if (description.isEmpty) return const SizedBox.shrink();
                      
                      return Expanded(
                        child: Text(
                          description,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 6,
                            height: 1.4,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}