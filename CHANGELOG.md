# Journal des modifications

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À venir

- Support hors ligne de l'inscription aux événements et de l'édition du profil personnel
- Couverture de tests étendue (widgets et `blocTest`)

## [1.0.0] - 2026-07-17

### Ajouté

- Authentification JWT complète : connexion, inscription, déconnexion, rafraîchissement automatique des jetons.
- Vérification d'e-mail obligatoire et réinitialisation de mot de passe (dialogues persistants et messages sécurisés).
- Contrôle d'accès basé sur les rôles (fidèle, secrétaire, trésorier, responsable, prêtre, admin) via `AppPermissions`, aligné sur le backend.
- Gestion des **membres** (fiches, sacrements, profil personnel).
- Gestion des **groupes** avec affectation multi-responsables et gestion des membres.
- Gestion des **événements** (inscriptions, participations).
- Gestion des **finances** (transactions, dons par membre, rapports).
- **Librairie** paroissiale (articles, alertes de stock, ventes).
- **Tableau de bord** statistique avec graphiques (`fl_chart`).
- **Cache local hors ligne** via Isar (`isar_plus`) et synchronisation bidirectionnelle push/pull toutes les 5 minutes.
- Écritures hors ligne avec file d'attente (outbox) et UUID générés côté client.
- Cache des fichiers (photos de profil) sur disque via `FileStorageService`.
- Support des six plateformes Flutter : Android, iOS, Web, Linux, macOS, Windows.
- Interface responsive (`responsive_framework`) et localisation française (`fr_FR`).
- Thème clair/sombre adaptatif (`ThemeMode.system`).
- Icônes et écran de démarrage natifs générés (`flutter_launcher_icons`, `flutter_native_splash`).

[Non publié]: https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/releases/tag/v1.0.0
