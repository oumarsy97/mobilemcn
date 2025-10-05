import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/app_color.dart';
import '../controllers/virtual_tour_controller.dart';

class VirtualTourPage extends StatefulWidget {
  const VirtualTourPage({super.key});

  @override
  State<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends State<VirtualTourPage> {
  final controller = Get.put(VirtualTourController(), permanent: false);
  InAppWebViewController? webViewController;
  bool isWebViewReady = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        return Stack(
          children: [
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _buildRoomSelector(),
                ),
                Expanded(
                  child: _buildThreeJsView(),
                ),
              ],
            ),
            
            if (controller.selectedArtwork.value != null)
              _buildArtworkPanel(),
            
            _buildNavigationControls(),
            
            if (!controller.hasInteracted.value && isWebViewReady)
              _buildInstructions(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () {
          Get.delete<VirtualTourController>();
          Get.back();
        },
      ),
      title: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                controller.currentRoom.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      )),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Initialisation de la vue 3D...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chargement de Three.js',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSelector() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 70, bottom: 12),
      child: Obx(() {
        if (controller.rooms.isEmpty) return const SizedBox.shrink();
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.rooms.length,
          itemBuilder: (context, index) {
            final room = controller.rooms[index];
            final isSelected = controller.currentRoomIndex.value == index;
            
            return GestureDetector(
              onTap: () {
                controller.selectRoom(index);
                _changePanorama(room.panoramaUrl);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 145 : 105,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ] : [],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: room.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[900],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.museum, color: Colors.white38),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSelected ? 13 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.art_track, color: AppColors.primary, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${room.artworks.length} œuvres',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.check, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildThreeJsView() {
    return Obx(() {
      final currentRoom = controller.currentRoom;
      
      return Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _getThreeJsHtml(currentRoom.panoramaUrl),
              baseUrl: WebUri('https://localhost'),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                domStorageEnabled: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              
              controller.addJavaScriptHandler(
                handlerName: 'messageHandler',
                callback: (args) {
                  _handleWebViewMessage(args[0]);
                },
              );
            },
            onLoadStop: (controller, url) {
              setState(() {
                isWebViewReady = true;
              });
              this.controller.isLoading.value = false;
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('WebView Console: ${consoleMessage.message}');
            },
          ),
          
          // Hotspots overlay
          ...currentRoom.artworks.asMap().entries.map((entry) {
            final index = entry.key;
            final artwork = entry.value;
            
            return Positioned(
              left: artwork.position.dx,
              top: artwork.position.dy,
              child: _AnimatedHotspot(
                artwork: artwork,
                onTap: () => controller.selectArtwork(index),
              ),
            );
          }),
        ],
      );
    });
  }

  String _getThreeJsHtml(String panoramaUrl) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { width: 100%; height: 100vh; overflow: hidden; background: #000; touch-action: none; }
        #canvas-container { width: 100%; height: 100%; position: relative; }
        .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #daa520;
            text-align: center;
        }
        .spinner {
            width: 50px;
            height: 50px;
            border: 3px solid rgba(218, 165, 32, 0.2);
            border-top-color: #daa520;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div id="canvas-container"></div>
    <div class="loading" id="loading">
        <div class="spinner"></div>
        <div>Chargement 3D...</div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        let scene, camera, renderer, sphere;
        let isUserInteracting = false;
        let onPointerDownMouseX = 0, onPointerDownMouseY = 0;
        let lon = 0, onPointerDownLon = 0;
        let lat = 0, onPointerDownLat = 0;

        function init() {
            const container = document.getElementById('canvas-container');
            
            scene = new THREE.Scene();
            camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.set(0, 0, 0.1);
            
            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            container.appendChild(renderer.domElement);
            
            const geometry = new THREE.SphereGeometry(500, 60, 40);
            geometry.scale(-1, 1, 1);
            
            const loader = new THREE.TextureLoader();
            loader.crossOrigin = 'anonymous';
            
            loader.load(
                '$panoramaUrl',
                function(texture) {
                    const material = new THREE.MeshBasicMaterial({ map: texture });
                    sphere = new THREE.Mesh(geometry, material);
                    scene.add(sphere);
                    document.getElementById('loading').style.display = 'none';
                    sendMessage('onPanoramaLoaded', { success: true });
                },
                undefined,
                function(error) {
                    document.getElementById('loading').innerHTML = '<div style="color: #ff4444;">Erreur de chargement</div>';
                }
            );
            
            container.addEventListener('pointerdown', onPointerDown);
            container.addEventListener('pointermove', onPointerMove);
            container.addEventListener('pointerup', onPointerUp);
            window.addEventListener('resize', onWindowResize);
            
            animate();
        }

        function onPointerDown(event) {
            isUserInteracting = true;
            onPointerDownMouseX = event.clientX;
            onPointerDownMouseY = event.clientY;
            onPointerDownLon = lon;
            onPointerDownLat = lat;
        }

        function onPointerMove(event) {
            if (isUserInteracting) {
                lon = (onPointerDownMouseX - event.clientX) * 0.1 + onPointerDownLon;
                lat = (event.clientY - onPointerDownMouseY) * 0.1 + onPointerDownLat;
                lat = Math.max(-85, Math.min(85, lat));
                sendMessage('onRotation', { lon: lon, lat: lat });
            }
        }

        function onPointerUp() {
            isUserInteracting = false;
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        function animate() {
            requestAnimationFrame(animate);
            update();
        }

        function update() {
            lat = Math.max(-85, Math.min(85, lat));
            const phi = THREE.MathUtils.degToRad(90 - lat);
            const theta = THREE.MathUtils.degToRad(lon);
            
            camera.target = new THREE.Vector3(
                500 * Math.sin(phi) * Math.cos(theta),
                500 * Math.cos(phi),
                500 * Math.sin(phi) * Math.sin(theta)
            );
            
            camera.lookAt(camera.target);
            renderer.render(scene, camera);
        }

        function sendMessage(type, data) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('messageHandler', JSON.stringify({ type, data }));
            }
        }

        window.addEventListener('load', init);
    </script>
</body>
</html>
    ''';
  }

  void _changePanorama(String url) {
    webViewController?.evaluateJavascript(source: '''
      if (sphere && sphere.material) {
        const loader = new THREE.TextureLoader();
        loader.crossOrigin = 'anonymous';
        loader.load('$url', function(texture) {
          sphere.material.map = texture;
          sphere.material.needsUpdate = true;
        });
      }
    ''');
  }

  void _handleWebViewMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      
      switch (type) {
        case 'onPanoramaLoaded':
          controller.hasInteracted.value = true;
          break;
        case 'onRotation':
          controller.updateRotation(
            data['data']['lon'] ?? 0.0,
            data['data']['lat'] ?? 0.0,
          );
          controller.hasInteracted.value = true;
          break;
      }
    } catch (e) {
      print('Error handling webview message: $e');
    }
  }

  Widget _buildArtworkPanel() {
    final artwork = controller.selectedArtwork.value!;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            controller.clearSelection();
          }
        },
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.65),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artwork.title,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        artwork.artist,
                                        style: Get.textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => controller.clearSelection(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: artwork.imageUrl,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 240,
                            color: AppColors.cardBackground,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildInfoChip(Icons.calendar_today, artwork.year),
                          _buildInfoChip(Icons.category, artwork.category),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.description,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Description',
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              artwork.description,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Obx(() => Column(
        children: [
          _buildControlButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () {
              controller.previousRoom();
              _changePanorama(controller.currentRoom.panoramaUrl);
            },
            enabled: controller.currentRoomIndex.value > 0,
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.arrow_forward_ios,
            onPressed: () {
              controller.nextRoom();
              _changePanorama(controller.currentRoom.panoramaUrl);
            },
            enabled: controller.currentRoomIndex.value < controller.rooms.length - 1,
          ),
        ],
      )),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : Colors.grey.shade700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (enabled ? AppColors.primary : Colors.grey).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: enabled ? onPressed : null,
        iconSize: 20,
        padding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      top: 180,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.95),
              AppColors.primaryLight.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.view_in_ar, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Visite Virtuelle 3D',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildInstructionRow(Icons.swipe, 'Glissez pour explorer à 360°'),
            const SizedBox(height: 12),
            _buildInstructionRow(Icons.auto_awesome, 'Touchez les points pour les œuvres'),
            const SizedBox(height: 12),
            _buildInstructionRow(Icons.arrow_forward, 'Naviguez entre les salles'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.view_in_ar, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Visite 3D avec Three.js')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✨ Technologie Three.js pour une expérience 3D immersive'),
            SizedBox(height: 12),
            Text('👆 Touchez et glissez pour explorer'),
            SizedBox(height: 12),
            Text('🎨 Découvrez les œuvres en interaction'),
            SizedBox(height: 12),
            Text('➡️ Naviguez entre plusieurs salles du musée'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    webViewController = null;
    Get.delete<VirtualTourController>();
    super.dispose();
  }
}

class _AnimatedHotspot extends StatefulWidget {
  final Artwork artwork;
  final VoidCallback onTap;
  
  const _AnimatedHotspot({required this.artwork, required this.onTap});

  @override
  State<_AnimatedHotspot> createState() => _AnimatedHotspotState();
}

class _AnimatedHotspotState extends State<_AnimatedHotspot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Cercle pulsant externe PLUS VISIBLE
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.4 * _pulseAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Cercle principal PLUS GRAND
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}