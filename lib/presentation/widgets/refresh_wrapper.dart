import 'package:flutter/material.dart';

/// Rend un contenu non défilable (ex: un état vide centré) compatible avec
/// le pull-to-refresh : il l'enveloppe dans une zone défilable qui occupe
/// toute la hauteur disponible afin que le geste de tirage soit toujours
/// disponible, même quand il n'y a aucune donnée à afficher.
///
/// À utiliser comme enfant direct d'un [RefreshIndicator].
class RefreshableEmpty extends StatelessWidget {
  final Widget child;

  const RefreshableEmpty({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
