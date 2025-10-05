import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_color.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec image
            _buildHeader(),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Notre Histoire',
                    icon: Icons.history_edu,
                    content: 'Le Musée des Civilisations Noires, inauguré en 2018 à Dakar, Sénégal, est un phare culturel dédié à la préservation et à la promotion des contributions des civilisations noires à l\'histoire mondiale. Fruit d\'une collaboration entre le Sénégal et la Chine, ce musée monumental s\'étend sur 14 000 mètres carrés et abrite une collection impressionnante d\'artefacts, d\'œuvres d\'art et de documents historiques provenant d\'Afrique et de sa diaspora.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Notre Mission',
                    icon: Icons.flag,
                    content: 'Le musée s\'engage à éclairer la richesse et la diversité des cultures noires, à encourager le dialogue interculturel et à servir de plateforme pour la recherche et l\'éducation. Il vise à réévaluer les narratifs historiques, à célébrer les réalisations des peuples noirs et à inspirer les générations futures.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Nos Valeurs',
                    icon: Icons.favorite,
                    content: 'Le Musée des Civilisations Noires est guidé par des valeurs fondamentales telles que l\'excellence, l\'inclusivité, le respect de la diversité culturelle et l\'engagement envers la justice sociale. Il s\'efforce de créer un espace où chaque visiteur se sent valorisé et représenté, et où les voix et les perspectives des communautés noires sont amplifiées.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Fondation et Figures Clés',
                    icon: Icons.people,
                    content: 'Le projet du musée a été initié par le président sénégalais Léopold Sédar Senghor, un fervent défenseur de la négritude et de la reconnaissance des cultures africaines. Sa vision a été portée par ses successeurs et a abouti à la création de ce lieu emblématique. Des personnalités telles que le professeur Moustapha Ka, premier directeur du musée, ont joué un rôle crucial dans sa mise en place et son rayonnement.',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Statistiques
                  _buildStatsSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Contact et informations
                  _buildContactSection(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Stack(
        children: [
          // Pattern décoratif
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: AfricanPatternPainter(),
              ),
            ),
          ),
          
          // Contenu
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Musée des Civilisations Noires',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dakar, Sénégal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'En Chiffres',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '14 000',
                label: 'm² d\'espace',
                icon: Icons.straighten,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '2018',
                label: 'Inauguration',
                icon: Icons.calendar_today,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '1000+',
                label: 'Artefacts',
                icon: Icons.inventory_2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '50+',
                label: 'Pays',
                icon: Icons.public,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Pratiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Adresse',
            content: 'Route de l\'Aéroport, Dakar, Sénégal',
          ),
          const Divider(height: 24),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Téléphone',
            content: '+221 33 XXX XX XX',
          ),
          const Divider(height: 24),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            content: 'contact@mcn.sn',
          ),
          const Divider(height: 24),
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Horaires',
            content: 'Mar - Dim : 10h - 18h\nFermé le lundi',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Pattern painter personnalisé pour l'en-tête
class AfricanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 40.0;
    
    // Dessiner un motif géométrique africain simplifié
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Losanges
        final path = Path()
          ..moveTo(x + spacing / 2, y)
          ..lineTo(x + spacing, y + spacing / 2)
          ..lineTo(x + spacing / 2, y + spacing)
          ..lineTo(x, y + spacing / 2)
          ..close();
        
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}