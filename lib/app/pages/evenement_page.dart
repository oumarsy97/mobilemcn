import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/evenement_controller.dart';
import '../models/evenement_model.dart';
import '../utils/app_color.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class EvenementsPage extends StatefulWidget {
  const EvenementsPage({super.key});

  @override
  State<EvenementsPage> createState() => _EvenementsPageState();
}

class _EvenementsPageState extends State<EvenementsPage> {
  final controller = Get.put(EvenementController());
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // CORRECTION: Charger les événements au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.evenements.isEmpty) {
        controller.loadEvenements();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildFilters(),
              _buildEvenementsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildAppBar() {
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
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Événements',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Obx(() => Text(
                    '${controller.totalEvenements} événement${controller.totalEvenements > 1 ? 's' : ''}',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                controller.resetFilters();
                searchController.clear();
              },
              icon: const Icon(Icons.filter_alt_off, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un événement...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filtres horizontaux
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Obx(() => _buildFilterChip(
                      'Gratuits',
                      controller.showGratuitOnly.value,
                      controller.toggleGratuit,
                      Icons.money_off,
                    )),
                const SizedBox(width: 8),
                _buildTypeDropdown(),
                const SizedBox(width: 8),
                _buildStatutDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Obx(() => PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: controller.selectedType.value != 'TOUS' 
              ? AppColors.primary 
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.selectedType.value != 'TOUS'
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: controller.selectedType.value != 'TOUS'
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              controller.selectedType.value == 'TOUS' 
                  ? 'Type' 
                  : _getTypeLabel(controller.selectedType.value),
              style: TextStyle(
                color: controller.selectedType.value != 'TOUS'
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onSelected: (value) => controller.filterByType(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'TOUS', child: Text('Tous')),
        const PopupMenuItem(value: 'SPECTACLE', child: Text('Spectacle')),
        const PopupMenuItem(value: 'ATELIER', child: Text('Atelier')),
        const PopupMenuItem(value: 'CONFERENCE', child: Text('Conférence')),
        const PopupMenuItem(value: 'VISITE_GUIDEE', child: Text('Visite guidée')),
        const PopupMenuItem(value: 'EXPOSITION', child: Text('Exposition')),
        const PopupMenuItem(value: 'AUTRE', child: Text('Autre')),
      ],
    ));
  }

  Widget _buildStatutDropdown() {
    return Obx(() => PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: controller.selectedStatut.value != 'TOUS'
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.selectedStatut.value != 'TOUS'
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info,
              size: 16,
              color: controller.selectedStatut.value != 'TOUS'
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              controller.selectedStatut.value == 'TOUS'
                  ? 'Statut'
                  : _getStatutLabel(controller.selectedStatut.value),
              style: TextStyle(
                color: controller.selectedStatut.value != 'TOUS'
                    ? Colors.white
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onSelected: (value) => controller.filterByStatut(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'TOUS', child: Text('Tous')),
        const PopupMenuItem(value: 'A_VENIR', child: Text('À venir')),
        const PopupMenuItem(value: 'EN_COURS', child: Text('En cours')),
        const PopupMenuItem(value: 'TERMINE', child: Text('Terminé')),
        const PopupMenuItem(value: 'ANNULE', child: Text('Annulé')),
      ],
    ));
  }

  Widget _buildEvenementsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.evenements.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      }

      if (controller.evenements.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun événement trouvé',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == controller.evenements.length) {
                if (controller.hasMore.value && !controller.isLoadingMore.value) {
                  controller.loadMore();
                }
                if (controller.isLoadingMore.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final evenement = controller.evenements[index];
              return _buildEvenementCard(evenement);
            },
            childCount: controller.evenements.length + 1,
          ),
        ),
      );
    });
  }

  Widget _buildEvenementCard(EvenementModel evenement) {
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return GestureDetector(
      onTap: () => Get.toNamed('/evenement-detail', arguments: evenement.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: evenement.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: evenement.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.cardBackground,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.cardBackground,
                            child: const Icon(Icons.event, size: 60, color: AppColors.textTertiary),
                          ),
                        )
                      : Container(
                          height: 180,
                          color: AppColors.cardBackground,
                          child: const Icon(Icons.event, size: 60, color: AppColors.textTertiary),
                        ),
                ),
                if (evenement.estPopulaire)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Populaire', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatutColor(evenement.statut),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatutLabel(evenement.statut),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getTypeLabel(evenement.type),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Titre
                  Text(
                    evenement.titre,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Date et heure
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        evenement.dateFormatee,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        evenement.heureDebut,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          evenement.lieu,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // Footer
                  Row(
                    children: [
                      // Prix
                      Text(
                        evenement.prixFormate,
                        style: TextStyle(
                          color: evenement.gratuit ? Colors.green : AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Capacité
                      Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${evenement.nombreInscriptions}/${evenement.capaciteMax}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
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

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'A_VENIR':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.green;
      case 'TERMINE':
        return Colors.grey;
      case 'ANNULE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatutLabel(String statut) {
    switch (statut) {
      case 'A_VENIR':
        return 'À venir';
      case 'EN_COURS':
        return 'En cours';
      case 'TERMINE':
        return 'Terminé';
      case 'ANNULE':
        return 'Annulé';
      default:
        return statut;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'SPECTACLE':
        return 'Spectacle';
      case 'ATELIER':
        return 'Atelier';
      case 'CONFERENCE':
        return 'Conférence';
      case 'VISITE_GUIDEE':
        return 'Visite guidée';
      case 'EXPOSITION':
        return 'Exposition';
      case 'AUTRE':
        return 'Autre';
      case 'TOUS':
        return 'Tous';
      default:
        return type;
    }
  }
}