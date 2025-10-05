import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/evenement_controller.dart';
import '../utils/app_color.dart';

class EvenementDetailPage extends StatefulWidget {
  const EvenementDetailPage({super.key});

  @override
  State<EvenementDetailPage> createState() => _EvenementDetailPageState();
}

class _EvenementDetailPageState extends State<EvenementDetailPage> {
  final controller = Get.find<EvenementController>();
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? id = Get.arguments as String?;
      
      if (id != null && id.isNotEmpty) {
        controller.loadEvenementById(id);
      } else {
        Get.back();
        Get.snackbar('Erreur', 'ID événement manquant');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        }

        if (controller.selectedEvenement.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Événement non trouvé', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          );
        }

        final evenement = controller.selectedEvenement.value!;
        
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildAppBar(evenement),
                _buildContent(evenement),
              ],
            ),
            // Bouton d'inscription flottant
            _buildInscriptionButton(evenement),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(evenement) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: evenement.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: evenement.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.event, size: 80),
                ),
              )
            : Container(
                color: AppColors.cardBackground,
                child: const Icon(Icons.event, size: 80),
              ),
      ),
    );
  }

  Widget _buildContent(evenement) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatutColor(evenement.statut),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatutLabel(evenement.statut),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            
            // Titre
            Text(
              evenement.titre,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Type
            Row(
              children: [
                Icon(Icons.category, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  _getTypeLabel(evenement.type),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Date et heure
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(evenement.dateFormatee),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(evenement.heureDebut),
              ],
            ),
            const SizedBox(height: 12),
            
            // Lieu
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(evenement.lieu)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Description
            Text(
              'Description',
              style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              evenement.description ?? 'Aucune description disponible',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Informations supplémentaires
            _buildInfoCard(evenement),
            
            const SizedBox(height: 100), // Espace pour le bouton
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(evenement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Prix', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                evenement.prixFormate,
                style: TextStyle(
                  color: evenement.gratuit ? Colors.green : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Places disponibles', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                '${evenement.capaciteMax - evenement.nombreInscriptions}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inscrits', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                '${evenement.nombreInscriptions}/${evenement.capaciteMax}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInscriptionButton(evenement) {
    final bool isComplet = evenement.nombreInscriptions >= evenement.capaciteMax;
    final bool isTermine = evenement.statut == 'TERMINE';
    final bool isAnnule = evenement.statut == 'ANNULE';
    
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (isComplet || isTermine || isAnnule) 
              ? null 
              : () => _showInscriptionDialog(evenement),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isComplet 
                ? 'Complet' 
                : isTermine 
                    ? 'Terminé' 
                    : isAnnule 
                        ? 'Annulé' 
                        : 'S\'inscrire',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showInscriptionDialog(evenement) {
  final nombrePlacesController = TextEditingController(text: '1');
  
  Get.dialog(
    AlertDialog(
      title: const Text('Inscription'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Voulez-vous vous inscrire à cet événement ?'),
          const SizedBox(height: 16),
          TextField(
            controller: nombrePlacesController,
            decoration: const InputDecoration(
              labelText: 'Nombre de places',
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: () async {
            final nombrePlaces = int.tryParse(nombrePlacesController.text) ?? 1;
            
            Get.back();
            
            final success = await controller.inscrire(
              evenementId: evenement.id,
              nombrePlaces: nombrePlaces,
            );
            
            if (success) {
              // L'événement sera rechargé automatiquement
            }
          },
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
}
  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'A_VENIR': return Colors.blue;
      case 'EN_COURS': return Colors.green;
      case 'TERMINE': return Colors.grey;
      case 'ANNULE': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatutLabel(String statut) {
    switch (statut) {
      case 'A_VENIR': return 'À venir';
      case 'EN_COURS': return 'En cours';
      case 'TERMINE': return 'Terminé';
      case 'ANNULE': return 'Annulé';
      default: return statut;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'SPECTACLE': return 'Spectacle';
      case 'ATELIER': return 'Atelier';
      case 'CONFERENCE': return 'Conférence';
      case 'VISITE_GUIDEE': return 'Visite guidée';
      case 'EXPOSITION': return 'Exposition';
      case 'AUTRE': return 'Autre';
      default: return type;
    }
  }
}