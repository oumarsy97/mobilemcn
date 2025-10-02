// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe de configuration centralisée pour gérer les variables d'environnement
class EnvConfig {
  // ==================== API Configuration ====================
  
  /// URL de base de l'API
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:2000';
  }
  
  /// Timeout pour les requêtes API (en secondes)
  static int get apiTimeout {
    final timeout = dotenv.env['API_TIMEOUT'];
    return timeout != null ? int.tryParse(timeout) ?? 30 : 30;
  }

  /// Duration pour les requêtes API
  static Duration get apiTimeoutDuration {
    return Duration(seconds: apiTimeout);
  }
  
  // ==================== Environment ====================
  
  /// Nom de l'environnement (development, staging, production)
  static String get envName {
    return dotenv.env['ENV_NAME'] ?? 'development';
  }
  
  /// Vérifie si on est en production
  static bool get isProduction {
    return envName.toLowerCase() == 'production';
  }
  
  /// Vérifie si on est en développement
  static bool get isDevelopment {
    return envName.toLowerCase() == 'development';
  }

  /// Vérifie si on est en staging
  static bool get isStaging {
    return envName.toLowerCase() == 'staging';
  }
  
  // ==================== Debug Configuration ====================
  
  /// Active les logs détaillés
  static bool get enableDebugLogs {
    final value = dotenv.env['ENABLE_DEBUG_LOGS'];
    return value?.toLowerCase() == 'true' || isDevelopment;
  }

  /// Active les logs API
  static bool get enableApiLogs {
    final value = dotenv.env['ENABLE_API_LOGS'];
    return value?.toLowerCase() == 'true' || isDevelopment;
  }
  
  // ==================== Optional Features ====================
  
  /// Clé API (si nécessaire)
  static String? get apiKey {
    return dotenv.env['API_KEY'];
  }

  /// Version de l'API
  static String get apiVersion {
    return dotenv.env['API_VERSION'] ?? 'v1';
  }

  /// Nombre de tentatives en cas d'échec
  static int get maxRetries {
    final retries = dotenv.env['MAX_RETRIES'];
    return retries != null ? int.tryParse(retries) ?? 3 : 3;
  }

  /// Délai entre les tentatives (en millisecondes)
  static int get retryDelay {
    final delay = dotenv.env['RETRY_DELAY'];
    return delay != null ? int.tryParse(delay) ?? 1000 : 1000;
  }
  
  // ==================== Utility Methods ====================
  
  /// Affiche la configuration actuelle (uniquement en mode debug)
  static void printConfig() {
    if (!isProduction) {
      print('');
      print('╔═══════════════════════════════════════╗');
      print('║       CONFIGURATION APP               ║');
      print('╠═══════════════════════════════════════╣');
      print('║ Environment: ${envName.padRight(23)}║');
      print('║ API Base URL: ${_truncate(apiBaseUrl, 21)}║');
      print('║ API Timeout: ${apiTimeout}s${' ' * (24 - apiTimeout.toString().length)}║');
      print('║ API Version: ${apiVersion.padRight(23)}║');
      print('║ Debug Logs: ${(enableDebugLogs ? 'ON' : 'OFF').padRight(24)}║');
      print('║ API Logs: ${(enableApiLogs ? 'ON' : 'OFF').padRight(26)}║');
      print('║ Max Retries: ${maxRetries.toString().padRight(23)}║');
      print('╚═══════════════════════════════════════╝');
      print('');
    }
  }

  /// Tronque une chaîne si elle est trop longue
  static String _truncate(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str.padRight(maxLength);
    }
    return '${str.substring(0, maxLength - 3)}...';
  }

  /// Valide la configuration
  static bool validate() {
    final errors = <String>[];

    // Vérifier l'URL de l'API
    if (apiBaseUrl.isEmpty) {
      errors.add('API_BASE_URL is empty');
    }

    // Vérifier que l'URL est valide
    try {
      Uri.parse(apiBaseUrl);
    } catch (e) {
      errors.add('API_BASE_URL is not a valid URL');
    }

    // Vérifier le timeout
    if (apiTimeout <= 0) {
      errors.add('API_TIMEOUT must be positive');
    }

    // Afficher les erreurs
    if (errors.isNotEmpty) {
      print('❌ Configuration errors:');
      for (final error in errors) {
        print('   - $error');
      }
      return false;
    }

    if (!isProduction) {
      print('✅ Configuration validated successfully');
    }
    return true;
  }

  /// Construit une URL complète
  static String buildUrl(String endpoint) {
    // Enlever le slash initial de l'endpoint s'il existe
    final cleanEndpoint = endpoint.startsWith('/') 
        ? endpoint.substring(1) 
        : endpoint;
    
    // Enlever le slash final de baseUrl s'il existe
    final cleanBaseUrl = apiBaseUrl.endsWith('/') 
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) 
        : apiBaseUrl;
    
    return '$cleanBaseUrl/$cleanEndpoint';
  }

  /// Récupère une valeur custom de l'environnement
  static String? getCustomValue(String key, {String? defaultValue}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Récupère une valeur booléenne custom
  static bool getCustomBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Récupère une valeur entière custom
  static int getCustomInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
}

/// Extension pour faciliter l'utilisation
extension EnvConfigExtension on String {
  /// Construit une URL complète à partir d'un endpoint
  String toFullUrl() => EnvConfig.buildUrl(this);
}

/// Exemple d'utilisation:
/// 
/// ```dart
/// // Dans main.dart
/// await dotenv.load(fileName: ".env");
/// EnvConfig.printConfig();
/// EnvConfig.validate();
/// 
/// // Dans un service
/// final url = EnvConfig.buildUrl('/ressources/uidt');
/// // ou
/// final url = '/ressources/uidt'.toFullUrl();
/// 
/// final response = await http.get(
///   Uri.parse(url),
/// ).timeout(EnvConfig.apiTimeoutDuration);
/// 
/// // Logs conditionnels
/// if (EnvConfig.enableDebugLogs) {
///   print('Debug: $response');
/// }
/// ```