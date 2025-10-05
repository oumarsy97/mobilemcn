import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/oeuvre_model.dart';
import '../controllers/favoris_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/oeuvre_controller.dart';
import '../utils/app_color.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OeuvreModel oeuvre = Get.arguments as OeuvreModel;
    final authController = Get.find<AuthController>();
    final favoriController = Get.find<FavorisController>();
    final oeuvreController = Get.find<OeuvreController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(oeuvre, authController, favoriController),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(oeuvre),
                
                if (oeuvre.medias != null && oeuvre.medias!.any((m) => m.type == 'AUDIO'))
                  _buildAudioSection(oeuvre),
                
                if (oeuvre.medias != null && oeuvre.medias!.any((m) => m.type == 'VIDEO'))
                  _buildVideoSection(oeuvre),
                
                _buildDescription(oeuvre, oeuvreController),
                _buildDetailsSection(oeuvre),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(OeuvreModel oeuvre, AuthController authController, FavorisController favoriController) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'oeuvre-${oeuvre.id}',
              child: CachedNetworkImage(
                imageUrl: oeuvre.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Get.back(),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      actions: [
        Obx(() {
          if (!authController.isLoggedIn.value) {
            return const SizedBox.shrink();
          }
          
          final isFav = favoriController.isFavorite(oeuvre.id);
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                ),
                onPressed: () => favoriController.toggleFavorite(oeuvre.id),
                color: isFav ? Colors.red : AppColors.textPrimary,
                padding: EdgeInsets.zero,
              ),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () {
                Get.snackbar(
                  'Partage',
                  'Fonctionnalité de partage',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2),
                );
              },
              color: AppColors.textPrimary,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(OeuvreModel oeuvre) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              oeuvre.categorie.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            oeuvre.titre,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              fontSize: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Artiste',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        oeuvre.artiste,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.event_rounded,
                  label: 'Année',
                  value: oeuvre.annee.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.location_on_rounded,
                  label: 'Étage',
                  value: oeuvre.localisation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBackground,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(OeuvreModel oeuvre) {
    if (oeuvre.medias == null || oeuvre.medias!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    Media? audioMedia;
    try {
      audioMedia = oeuvre.medias!.firstWhere((m) => m.type == 'AUDIO');
    } catch (e) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AudioPlayerWidget(audioUrl: audioMedia.url),
    );
  }

  Widget _buildVideoSection(OeuvreModel oeuvre) {
    if (oeuvre.medias == null || oeuvre.medias!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    Media? videoMedia;
    try {
      videoMedia = oeuvre.medias!.firstWhere((m) => m.type == 'VIDEO');
    } catch (e) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: VideoPlayerWidget(videoUrl: videoMedia.url),
    );
  }

  Widget _buildDescription(OeuvreModel oeuvre, OeuvreController oeuvreController) {
    return Obx(() {
      final description = oeuvre.getDescription(oeuvreController.selectedLangue.value);

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.article_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Description',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.cardBackground,
                  width: 2,
                ),
              ),
              child: Text(
                description.isNotEmpty
                    ? description
                    : 'Aucune description disponible.',
                style: Get.textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailsSection(OeuvreModel oeuvre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Informations',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.cardBackground,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                _buildDetailItem(
                  icon: Icons.category_rounded,
                  label: 'Catégorie',
                  value: oeuvre.categorie,
                ),
                const Divider(height: 28, thickness: 1.5),
                _buildDetailItem(
                  icon: Icons.videocam_rounded,
                  label: 'Médias disponibles',
                  value: (oeuvre.medias == null || oeuvre.medias!.isEmpty)
                      ? 'Aucun'
                      : '${oeuvre.medias!.length} média(s)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 24, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// AudioPlayerWidget
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });

    await _audioPlayer.setSourceUrl(widget.audioUrl);
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.setPlaybackRate(_playbackSpeed);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.audiotrack_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Audio guide',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.cardBackground,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.divider,
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.speed_rounded,
                    onPressed: () => _showSpeedDialog(),
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: Icons.replay_10_rounded,
                    onPressed: () async {
                      final newPosition = _position - const Duration(seconds: 10);
                      await _audioPlayer.seek(
                        newPosition < Duration.zero ? Duration.zero : newPosition,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (_isPlaying) {
                          await _audioPlayer.pause();
                        } else {
                          await _audioPlayer.resume();
                        }
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 36,
                      ),
                      color: Colors.white,
                      iconSize: 36,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: Icons.forward_10_rounded,
                    onPressed: () async {
                      final newPosition = _position + const Duration(seconds: 10);
                      await _audioPlayer.seek(
                        newPosition > _duration ? _duration : newPosition,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildControlButton(
                    icon: _volume > 0.5
                        ? Icons.volume_up_rounded
                        : _volume > 0
                            ? Icons.volume_down_rounded
                            : Icons.volume_off_rounded,
                    onPressed: () => _showVolumeDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await _audioPlayer.stop();
                  setState(() {
                    _position = Duration.zero;
                  });
                },
                icon: const Icon(Icons.stop_rounded, size: 18),
                label: const Text('Arrêter'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.divider,
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: AppColors.textPrimary,
        iconSize: 22,
      ),
    );
  }

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Contrôle du volume',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _volume > 0.5
                      ? Icons.volume_up_rounded
                      : _volume > 0
                          ? Icons.volume_down_rounded
                          : Icons.volume_off_rounded,
                  color: AppColors.primary,
                  size: 56,
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                    onChanged: (value) async {
                      setState(() {
                        _volume = value;
                      });
                      this.setState(() {});
                      await _audioPlayer.setVolume(value);
                    },
                  ),
                ),
                Text(
                  '${(_volume * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Vitesse de lecture',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.speed_rounded,
              color: AppColors.primary,
              size: 56,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                final isSelected = _playbackSpeed == speed;
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    await _audioPlayer.setPlaybackRate(speed);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            )
                          : null,
                      color: isSelected ? null : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// VideoPlayerWidget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      
      await _controller.initialize();
      await _controller.setVolume(_volume);
      
      setState(() {
        _isInitialized = true;
      });
      
      _controller.addListener(() {
        if (mounted) setState(() {});
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && _controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Vidéo',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.cardBackground,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _buildVideoContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return Container(
        height: 220,
        color: AppColors.cardBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 220,
        color: AppColors.cardBackground,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement de la vidéo...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          
          if (_showControls)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          
          if (_showControls)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted && _controller.value.isPlaying) {
                            setState(() {
                              _showControls = false;
                            });
                          }
                        });
                      }
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                  iconSize: 56,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.divider,
                        backgroundColor: Colors.white24,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _buildVideoControlButton(
                          icon: Icons.replay_10_rounded,
                          onPressed: () {
                            final newPosition = _controller.value.position - 
                                const Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition < Duration.zero ? Duration.zero : newPosition,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildVideoControlButton(
                          icon: Icons.forward_10_rounded,
                          onPressed: () {
                            final newPosition = _controller.value.position + 
                                const Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition > _controller.value.duration 
                                  ? _controller.value.duration 
                                  : newPosition,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildVideoControlButton(
                          icon: _volume > 0.5
                              ? Icons.volume_up_rounded
                              : _volume > 0
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_off_rounded,
                          onPressed: () => _showVolumeDialog(),
                        ),
                        const SizedBox(width: 8),
                        _buildVideoControlButton(
                          icon: Icons.fullscreen_rounded,
                          onPressed: () {
                            Get.snackbar(
                              'Plein écran',
                              'Fonctionnalité à venir',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 20,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Volume de la vidéo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _volume > 0.5
                      ? Icons.volume_up_rounded
                      : _volume > 0
                          ? Icons.volume_down_rounded
                          : Icons.volume_off_rounded,
                  color: AppColors.primary,
                  size: 56,
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                    onChanged: (value) async {
                      setState(() {
                        _volume = value;
                      });
                      this.setState(() {});
                      await _controller.setVolume(value);
                    },
                  ),
                ),
                Text(
                  '${(_volume * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickVolumeButton('Muet', 0.0, setState),
                    _buildQuickVolumeButton('50%', 0.5, setState),
                    _buildQuickVolumeButton('100%', 1.0, setState),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickVolumeButton(String label, double value, StateSetter setState) {
    final isSelected = _volume == value;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _volume = value;
        });
        this.setState(() {});
        await _controller.setVolume(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}