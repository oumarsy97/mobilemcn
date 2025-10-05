import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/evenement_controller.dart';
import '../models/evenement_model.dart';
import '../utils/app_color.dart';
import '../widgets/custom_bottom_nav.dart';

class MesInscriptionsPage extends StatefulWidget {
  const MesInscriptionsPage({super.key});

  @override
  State<MesInscriptionsPage> createState() => _MesInscriptionsPageState();
}

class _MesInscriptionsPageState extends State<MesInscriptionsPage> {
  final controller = Get.find<EvenementController>();

  @override
  void initState() {
    super.initState();
    controller.loadMesInscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Mes Inscriptions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadMesInscriptions(),
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value && controller.mesInscriptions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            );
          }

          if (controller.mesInscriptions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.mesInscriptions.length,
            itemBuilder: (context, index) {
              final evenement = controller.mesInscriptions[index];
              return _buildInscriptionCard(evenement);
            },
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
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
            child: Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune inscription',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'êtes inscrit à aucun événement',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed('/evenements'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Découvrir les événements'),
          ),
        ],
      ),
    );
  }

  Widget _buildInscriptionCard(EvenementModel evenement) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image et badge inscrit
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: evenement.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: evenement.imageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.cardBackground,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.cardBackground,
                          child: const Icon(Icons.event, size: 50, color: AppColors.textTertiary),
                        ),
                      )
                    : Container(
                        height: 140,
                        color: AppColors.cardBackground,
                        child: const Icon(Icons.event, size: 50, color: AppColors.textTertiary),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Inscrit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      evenement.dateFormatee,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  evenement.titre,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        evenement.lieu,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${evenement.heureDebut} - ${evenement.heureFin}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(
                          '/evenement-detail',
                          arguments: evenement.id,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Voir détails'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showCancelDialog(evenement),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(EvenementModel evenement) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Annuler l\'inscription',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Voulez-vous vraiment annuler votre inscription à "${evenement.titre}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Non',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              // TODO: Implémenter la désinscription
              // Pour l'instant, on utilise un ID utilisateur temporaire
              final success = await controller.desinscrire(
                evenementId: evenement.id,
                utilisateurId: 'temp-user-id',
              );

              if (success) {
                Get.snackbar(
                  'Succès',
                  'Votre inscription a été annulée',
                  snackPosition: SnackPosition.BOTTOM,
                );
                controller.loadMesInscriptions();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
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
      default:
        return type;
    }
  }
}