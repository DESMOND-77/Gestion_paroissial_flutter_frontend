import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Avatar circulaire réutilisé dans le drawer et l'écran de profil.
///
/// Affiche la photo distante si [imageUrl] est renseignée, avec repli sur
/// [localImageFile] (copie mise en cache par `FileStorageService` pour
/// l'accès hors ligne) si le réseau échoue, puis sur les initiales de
/// l'utilisateur. Un léger anneau doré ("halo") peut être activé pour
/// accentuer le portrait sur les écrans dédiés au profil.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? localImageFile;
  final String initials;
  final double radius;
  final bool showHalo;
  final Color backgroundColor;
  final Color foregroundColor;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.localImageFile,
    this.radius = 36,
    this.showHalo = false,
    this.backgroundColor = AppTheme.primaryColor,
    this.foregroundColor = Colors.white,
  });

  bool get _hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) || localImageFile != null;

  Widget _fallback() {
    final file = localImageFile;
    if (file != null) {
      final size = radius * 2;
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _Initials(
          initials: initials,
          radius: radius,
          color: foregroundColor,
        ),
      );
    }
    return _Initials(initials: initials, radius: radius, color: foregroundColor);
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: ClipOval(
        child: !_hasImage
            ? _Initials(initials: initials, radius: radius, color: foregroundColor)
            : (imageUrl != null && imageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: size * 0.35,
                        height: size * 0.35,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foregroundColor.withAlpha(180),
                        ),
                      ),
                    ),
                    // Hors ligne / échec réseau : repli sur la copie locale
                    // mise en cache par FileStorageService avant les initiales.
                    errorWidget: (context, url, error) => _fallback(),
                  )
                : _fallback(),
      ),
    );

    if (!showHalo) return avatar;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryColor, Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withAlpha(90),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: avatar,
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final double radius;
  final Color color;

  const _Initials({
    required this.initials,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
