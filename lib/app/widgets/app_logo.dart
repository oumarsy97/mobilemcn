import 'package:flutter/material.dart';
import '../utils/app_color.dart';

/// Widget réutilisable pour afficher le logo MCN
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBackground;
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 48,
    this.showShadow = false,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoImage = ClipOval(
      child: Image.asset(
        'assets/images/logo.jpeg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback vers l'icône si l'image ne charge pas
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.museum,
              size: size * 0.55,
              color: Colors.white,
            ),
          );
        },
      ),
    );

    if (showBackground) {
      logoImage = Container(
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: logoImage,
      );
    } else if (showShadow) {
      logoImage = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: logoImage,
      );
    }

    return logoImage;
  }
}

/// Widget pour l'en-tête avec logo et texte
class AppLogoHeader extends StatelessWidget {
  final double logoSize;
  final bool showSubtitle;
  final Color? textColor;

  const AppLogoHeader({
    super.key,
    this.logoSize = 44,
    this.showSubtitle = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          showShadow: true,
        ),
        SizedBox(width: logoSize * 0.3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MCN',
              style: TextStyle(
                fontSize: logoSize * 0.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            if (showSubtitle)
              Text(
                'Civilisations Noires',
                style: TextStyle(
                  fontSize: logoSize * 0.27,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Widget pour écran de chargement avec logo
class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(
              size: 100,
              showShadow: true,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}