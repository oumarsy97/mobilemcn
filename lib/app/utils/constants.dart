class Constants {
  // URL de base de votre API
  static const String baseUrl = 'https://josefine-housekeeperlike-arlinda.ngrok-free.dev';
  
  // Clés de stockage
  static const String userKey = 'current_user';
  static const String tokenKey = 'auth_token';
  static const String languageKey = 'language';
  static const String favoritesKey = 'favorites';
  
  // Langues disponibles
  static const List<String> availableLanguages = ['FR', 'EN', 'WO'];
  static const String defaultLanguage = 'FR';
}