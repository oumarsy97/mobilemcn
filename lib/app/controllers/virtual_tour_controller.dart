import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VirtualTourController extends GetxController {
  final isLoading = true.obs;
  final currentRoomIndex = 0.obs;
  final selectedArtwork = Rxn<Artwork>();
  final hasInteracted = false.obs;
  
  // Contrôle de la rotation panoramique
  final rotationX = 0.0.obs;
  final rotationY = 0.0.obs;

  RxList<MuseumRoom> rooms = <MuseumRoom>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  void loadRooms() {
    isLoading.value = true;
    
    // ✅ URL panorama avec fallback sur image standard
    const String mcnPanoramaUrl = 'https://www.shutterstock.com/image-photo/grodno-belarus-march-2-2017-260nw-788279593.jpg';
    
    rooms.value = [
      MuseumRoom(
        id: 1,
        name: 'Hall Principal MCN',
        description: 'Vue panoramique du hall d\'entrée du Musée des Civilisations Noires',
        thumbnailUrl: 'https://www.shutterstock.com/image-photo/grodno-belarus-march-2-2017-260nw-788279593.jpg',
        panoramaUrl: mcnPanoramaUrl,
        artworks: [
          Artwork(
            id: 1,
            title: 'Sculpture Monumentale',
            artist: 'Artiste Africain',
            description: 'Cette sculpture monumentale accueille les visiteurs à l\'entrée du musée. Elle représente la force et la dignité des civilisations africaines à travers les âges.',
            imageUrl: 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3?w=800',
            year: '2018',
            category: 'Sculpture Contemporaine',
            position: Offset(Get.width * 0.3, Get.height * 0.4), // ✅ Position relative
          ),
          Artwork(
            id: 2,
            title: 'Fresque Historique',
            artist: 'Collectif d\'artistes sénégalais',
            description: 'Cette fresque retrace l\'histoire des grandes civilisations africaines, de l\'Égypte antique aux royaumes d\'Afrique de l\'Ouest.',
            imageUrl: 'https://images.unsplash.com/photo-1580795479225-39b2c559c87d?w=800',
            year: '2018',
            category: 'Art Mural',
            position: Offset(Get.width * 0.65, Get.height * 0.35), // ✅ Position relative
          ),
        ],
      ),
      
      MuseumRoom(
        id: 2,
        name: 'Galerie des Arts Anciens',
        description: 'Collection d\'objets d\'art traditionnels africains',
        thumbnailUrl: 'https://www.au-senegal.com/local/cache-vignettes/L900xH473/b7a36a9827faf05832b63364d9be8b-e4aeb.jpg',
        panoramaUrl: 'https://www.au-senegal.com/local/cache-vignettes/L900xH473/b7a36a9827faf05832b63364d9be8b-e4aeb.jpg',
        artworks: [
          Artwork(
            id: 3,
            title: 'Masques Rituels Dogon',
            artist: 'Artisans Dogon du Mali',
            description: 'Collection de masques sacrés utilisés lors des cérémonies Dama, rituels funéraires essentiels dans la culture Dogon.',
            imageUrl: 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3?w=800',
            year: 'XVIIIe - XIXe siècle',
            category: 'Sculpture Traditionnelle',
            position: const Offset(150, 230),
          ),
          Artwork(
            id: 4,
            title: 'Statuettes Akan',
            artist: 'Royaume Ashanti',
            description: 'Statuettes en bronze représentant les poids à peser l\'or, témoins de la richesse et de la sophistication du royaume Ashanti.',
            imageUrl: 'https://images.unsplash.com/photo-1580795479225-39b2c559c87d?w=800',
            year: 'XVIe - XVIIIe siècle',
            category: 'Art Akan',
            position: const Offset(280, 260),
          ),
        ],
      ),
      
      MuseumRoom(
        id: 3,
        name: 'Salle des Textiles',
        description: 'Tissus et vêtements traditionnels d\'Afrique',
        thumbnailUrl: 'https://images.unsplash.com/photo-1610992015762-45dca7464f11?w=600',
        panoramaUrl: 'https://images.unsplash.com/photo-1578926288207-e2b10a58c546?w=4000&h=2000',
        artworks: [
          Artwork(
            id: 5,
            title: 'Kente Royal Ashanti',
            artist: 'Maîtres tisserands Ashanti',
            description: 'Ce tissu Kente était réservé à la royauté Ashanti. Chaque motif et couleur possède une signification symbolique précise.',
            imageUrl: 'https://images.unsplash.com/photo-1610992015762-45dca7464f11?w=800',
            year: 'XXe siècle',
            category: 'Textile',
            position: const Offset(160, 210),
          ),
          Artwork(
            id: 6,
            title: 'Bogolan Traditionnel',
            artist: 'Artisans Bamana du Mali',
            description: 'Tissu en coton teint avec des boues fermentées selon une technique ancestrale transmise de génération en génération.',
            imageUrl: 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=800',
            year: 'XXIe siècle',
            category: 'Textile',
            position: const Offset(290, 240),
          ),
          Artwork(
            id: 7,
            title: 'Indigo du Sénégal',
            artist: 'Artisanes Sénégalaises',
            description: 'Tissu teint à l\'indigo naturel selon des techniques traditionnelles wolof, symbole de prestige et d\'élégance.',
            imageUrl: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800',
            year: 'XXIe siècle',
            category: 'Textile',
            position: const Offset(220, 280),
          ),
        ],
      ),
      
      MuseumRoom(
        id: 4,
        name: 'Galerie Contemporaine',
        description: 'Art africain contemporain et installations',
        thumbnailUrl: 'https://images.unsplash.com/photo-1549887534-1541e9326642?w=600',
        panoramaUrl: 'https://images.unsplash.com/photo-1577083552792-a0d461cb1dd6?w=4000&h=2000',
        artworks: [
          Artwork(
            id: 8,
            title: 'Renaissance Africaine',
            artist: 'Ousmane Sow',
            description: 'Monument symbolisant le réveil culturel et politique de l\'Afrique moderne, célébrant sa créativité et son innovation.',
            imageUrl: 'https://images.unsplash.com/photo-1549887534-1541e9326642?w=800',
            year: '2010',
            category: 'Sculpture Monumentale',
            position: const Offset(190, 220),
          ),
          Artwork(
            id: 9,
            title: 'Tapisserie Métallique',
            artist: 'El Anatsui',
            description: 'Installation créée à partir de capsules de bouteilles recyclées, transformant les déchets en œuvre d\'art monumentale.',
            imageUrl: 'https://images.unsplash.com/photo-1551847812-4e1e72f3e5fc?w=800',
            year: '2019',
            category: 'Installation',
            position: const Offset(310, 250),
          ),
        ],
      ),
      
      MuseumRoom(
        id: 5,
        name: 'Espace Multimédia',
        description: 'Art numérique et installations interactives',
        thumbnailUrl: 'https://www.missnumerique.com/blog/wp-content/uploads/02-TUTO-PHOTO-360-VENISE.jpg',
        panoramaUrl: 'https://www.missnumerique.com/blog/wp-content/uploads/02-TUTO-PHOTO-360-VENISE.jpg',
        artworks: [
          Artwork(
            id: 10,
            title: 'Projection Interactive',
            artist: 'Collectif Africréa',
            description: 'Installation multimédia explorant le dialogue entre traditions ancestrales et technologies du futur.',
            imageUrl: 'https://images.unsplash.com/photo-1551847812-4e1e72f3e5fc?w=800',
            year: '2024',
            category: 'Art Numérique',
            position: const Offset(200, 240),
          ),
          Artwork(
            id: 11,
            title: 'Afrique 3.0',
            artist: 'Studio Dakar Digital',
            description: 'Œuvre interactive questionnant la place de l\'Afrique dans la révolution numérique mondiale.',
            imageUrl: 'https://images.unsplash.com/photo-1535378917042-10a22c95931a?w=800',
            year: '2023',
            category: 'Installation Interactive',
            position: const Offset(140, 270),
          ),
        ],
      ),
    ];
    
    isLoading.value = false;
  }

  MuseumRoom get currentRoom {
    if (rooms.isEmpty) {
      return MuseumRoom(
        id: 0,
        name: 'Chargement...',
        description: '',
        thumbnailUrl: '',
        panoramaUrl: '',
        artworks: [],
      );
    }
    return rooms[currentRoomIndex.value];
  }

  void selectRoom(int index) {
    if (index >= 0 && index < rooms.length) {
      currentRoomIndex.value = index;
      selectedArtwork.value = null;
      hasInteracted.value = true;
    }
  }

  void nextRoom() {
    if (currentRoomIndex.value < rooms.length - 1) {
      currentRoomIndex.value++;
      selectedArtwork.value = null;
      hasInteracted.value = true;
    }
  }

  void previousRoom() {
    if (currentRoomIndex.value > 0) {
      currentRoomIndex.value--;
      selectedArtwork.value = null;
      hasInteracted.value = true;
    }
  }

  void selectArtwork(int index) {
    if (index >= 0 && index < currentRoom.artworks.length) {
      selectedArtwork.value = currentRoom.artworks[index];
      hasInteracted.value = true;
    }
  }

  void clearSelection() {
    selectedArtwork.value = null;
  }

  void updateRotation(double dx, double dy) {
    rotationX.value += dx;
    rotationY.value += dy;
    hasInteracted.value = true;
  }

  @override
  void onClose() {
    rooms.clear();
    super.onClose();
  }
}

// ============================================
// MODÈLES DE DONNÉES
// ============================================

class MuseumRoom {
  final int id;
  final String name;
  final String description;
  final String thumbnailUrl;
  final String panoramaUrl;
  final List<Artwork> artworks;

  MuseumRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.panoramaUrl,
    required this.artworks,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'panoramaUrl': panoramaUrl,
    'artworks': artworks.map((a) => a.toJson()).toList(),
  };

  factory MuseumRoom.fromJson(Map<String, dynamic> json) => MuseumRoom(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    thumbnailUrl: json['thumbnailUrl'] ?? '',
    panoramaUrl: json['panoramaUrl'] ?? '',
    artworks: (json['artworks'] as List?)
        ?.map((a) => Artwork.fromJson(a))
        .toList() ?? [],
  );
}

class Artwork {
  final int id;
  final String title;
  final String artist;
  final String description;
  final String imageUrl;
  final String year;
  final String category;
  final Offset position;

  Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.imageUrl,
    required this.year,
    required this.category,
    required this.position,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'description': description,
    'imageUrl': imageUrl,
    'year': year,
    'category': category,
    'positionX': position.dx,
    'positionY': position.dy,
  };

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    artist: json['artist'] ?? '',
    description: json['description'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    year: json['year'] ?? '',
    category: json['category'] ?? '',
    position: Offset(
      (json['positionX'] ?? 0.0).toDouble(),
      (json['positionY'] ?? 0.0).toDouble(),
    ),
  );
}