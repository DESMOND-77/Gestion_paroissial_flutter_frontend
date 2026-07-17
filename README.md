<div align="center">

<img src="assets/images/logo.svg" alt="Logo Gestion Paroissiale" width="140" />

# Gestion Paroissiale

**Plateforme de gestion complète pour paroisses — membres, groupes, événements, finances et librairie.**

Application Flutter multiplateforme (Android · iOS · Web · Linux · macOS · Windows), pensée _offline-first_.

[![CI](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/actions/workflows/ci.yml/badge.svg)](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/actions/workflows/ci.yml)

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![Licence](https://img.shields.io/github/license/DESMOND-77/Gestion_paroissial_flutter_frontend)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Stars](https://img.shields.io/github/stars/DESMOND-77/Gestion_paroissial_flutter_frontend?style=social)](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/stargazers)
[![Forks](https://img.shields.io/github/forks/DESMOND-77/Gestion_paroissial_flutter_frontend?style=social)](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/network/members)
[![Issues](https://img.shields.io/github/issues/DESMOND-77/Gestion_paroissial_flutter_frontend)](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/issues)

</div>

---

## Table des matières

- [Gestion Paroissiale](#gestion-paroissiale)
  - [Table des matières](#table-des-matières)
  - [À propos](#à-propos)
  - [Fonctionnalités](#fonctionnalités)
  - [Architecture](#architecture)
  - [Technologies utilisées](#technologies-utilisées)
  - [Prérequis](#prérequis)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Variables d'environnement](#variables-denvironnement)
  - [Lancement en développement](#lancement-en-développement)
  - [Lancement en production](#lancement-en-production)
  - [Commandes utiles](#commandes-utiles)
  - [Exemples d'utilisation](#exemples-dutilisation)
  - [Captures d'écran](#captures-décran)
  - [Structure du projet](#structure-du-projet)
  - [Documentation](#documentation)
  - [Roadmap](#roadmap)
  - [FAQ](#faq)
  - [Contribution](#contribution)
  - [Sécurité](#sécurité)
  - [Licence](#licence)
  - [Auteurs](#auteurs)
  - [Remerciements](#remerciements)

---

## À propos

**Gestion Paroissiale** est une application de gestion destinée aux paroisses francophones. Elle centralise la gestion des **membres**, des **groupes**, des **événements**, des **finances** et d'une **librairie paroissiale**, avec un tableau de bord statistique.

L'application est **multiplateforme** (les six cibles Flutter sont configurées) et **_offline-first_** : les données sont mises en cache localement via une base NoSQL Isar, et les écritures effectuées hors ligne sont synchronisées automatiquement au retour de la connexion.

Elle communique avec un backend **Django / DRF** (dépôt séparé) via une API REST versionnée sous `/api/v1/`.

---

## Fonctionnalités

- 🔐 **Authentification & sécurité** — connexion JWT, rafraîchissement automatique des jetons, vérification d'e-mail obligatoire, réinitialisation de mot de passe.
- 👥 **Gestion des membres** — fiches détaillées, sacrements, profil personnel.
- 🧑‍🤝‍🧑 **Groupes** — création, affectation multi-responsables, gestion des membres.
- 📅 **Événements** — calendrier, inscriptions et participations.
- 💰 **Finances** — transactions, dons par membre, rapports financiers.
- 📚 **Librairie** — articles, stocks avec alertes, ventes.
- 📊 **Tableau de bord** — statistiques et graphiques (fl_chart).
- 🛡️ **Contrôle d'accès par rôle** — UI et routes gardées selon la hiérarchie de rôles (fidèle, secrétaire, trésorier, responsable, prêtre, admin).
- 📴 **Mode hors ligne** — cache local (Isar), synchronisation bidirectionnelle push/pull, écritures optimistes.
- 🌍 **Multiplateforme & responsive** — Android, iOS, Web, Linux, macOS, Windows.
- 🇫🇷 **Interface en français** — localisation `fr_FR`.

---

## Architecture

Le projet suit une **Clean Architecture** à trois couches :

```
lib/
├── core/          # Infrastructure : DI, réseau, routage, thème, base locale, sync
├── data/          # Modèles JSON et repositories (accès API)
└── presentation/  # BLoCs, écrans et widgets réutilisables
```

- **State management** : pattern **BLoC** (`flutter_bloc`) événementiel avec `Equatable`.
- **Navigation** : **GoRouter** avec routes imbriquées et gardes d'authentification / de rôle.
- **Injection de dépendances** : **GetIt** (`lib/core/di/injection.dart`).
- **Cache local** : base **Isar (`isar_plus`)** + synchronisation périodique (5 min).

Voir [`docs/architecture.md`](docs/architecture.md) pour le détail.

---

## Technologies utilisées

| Domaine | Outils |
| --- | --- |
| Langage / SDK | Dart, Flutter (min SDK 3.3.0) |
| State management | `flutter_bloc`, `equatable` |
| Navigation | `go_router` |
| Réseau | `dio` |
| DI | `get_it` |
| Stockage local | `isar_plus`, `flutter_secure_storage`, `shared_preferences`, `path_provider` |
| Connectivité | `connectivity_plus` |
| UI / responsive | `responsive_framework`, `fl_chart`, `data_table_2`, `sidebarx`, `flutter_svg`, `lottie`, `cached_network_image`, `auto_size_text` |
| i18n | `intl` (`fr_FR`) |
| Qualité de code | `flutter_lints`, `analyzer` |

---

## Prérequis

- **Flutter SDK** ≥ 3.3.0 (canal stable recommandé — testé avec Flutter 3.44.x / Dart 3.x)
- **Dart SDK** (fourni avec Flutter)
- Un backend **Gestion Paroissiale** accessible (voir [Configuration](#configuration))
- Selon la cible : Android SDK / Xcode / toolchain desktop / navigateur

Vérifiez votre environnement :

```bash
flutter doctor
```

---

## Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend.git
cd Gestion_paroissial_flutter_frontend

# 2. Installer les dépendances
flutter pub get

# 3. (Web uniquement) le moteur Isar WASM est déjà présent sous web/isar_plus.{wasm,js}

# 4. Lancer l'application
flutter run
```

---

## Configuration

L'URL de l'API se configure dans [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart). Plusieurs URLs de développement/production y sont conservées en commentaire ; **une seule doit rester active** :

```dart
class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  // ...
}
```

> **Note** — L'API est versionnée sous `/api/v1/`. Chaque endpoint renvoie une enveloppe `{ success, data, error?, message? }`.

---

## Variables d'environnement

Cette application Flutter **n'utilise pas de fichier `.env`** : la configuration réseau est centralisée dans `api_constants.dart` (voir ci-dessus). Les données sensibles (jetons JWT) sont stockées via `flutter_secure_storage` et ne transitent jamais par des variables d'environnement en clair.

Si vous introduisez une configuration par environnement, l'approche recommandée est `--dart-define` :

```bash
flutter run --dart-define=API_BASE_URL=https://api.exemple.org/api/v1
```

> TODO: Compléter si une gestion `--dart-define` est mise en place dans le code.

---

## Lancement en développement

```bash
# Appareil par défaut
flutter run

# Cible spécifique
flutter run -d chrome        # Web
flutter run -d linux         # Desktop Linux
flutter devices              # Lister les appareils disponibles
```

Raccourcis dans l'app en cours d'exécution : `r` (hot reload), `R` (redémarrage complet).

---

## Lancement en production

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

Voir [`docs/deployment.md`](docs/deployment.md).

---

## Commandes utiles

```bash
flutter pub get                                             # Installer les dépendances
flutter analyze                                             # Analyse statique
dart format lib                                             # Formatage
flutter test                                                # Tests
dart run build_runner build --delete-conflicting-outputs   # Régénérer le code (Isar)
dart run flutter_launcher_icons                            # Régénérer les icônes
dart run flutter_native_splash:create                      # Régénérer le splash
```

---

## Exemples d'utilisation

Récupération de données via un repository (le cache est utilisé automatiquement) :

```dart
// Requête sans filtre → utilise le cache local si valide (< 5 min)
final membres = await membreRepository.getMembres();

// Requête filtrée → toujours envoyée au serveur
final resultats = await membreRepository.getMembres(search: 'Jean');
```

Forcer une synchronisation immédiate :

```dart
final syncManager = sl<PeriodicSyncManager>();
await syncManager.forceSyncNow();
```

---

## Captures d'écran

> TODO: Ajouter des captures d'écran de l'application.

| Connexion | Tableau de bord | Membres |
| --- | --- | --- |
| _(placeholder)_ | _(placeholder)_ | _(placeholder)_ |

---

## Structure du projet

```
.
├── lib/
│   ├── core/            # DI, réseau, routage, thème, base locale, sync, auth
│   ├── data/            # models/ et repositories/
│   ├── presentation/    # blocs/, screens/, widgets/
│   ├── app.dart         # MultiBlocProvider + MaterialApp.router
│   └── main.dart        # Point d'entrée et initialisation
├── assets/              # images/ (logo, favicon) et lotties/
├── test/                # Tests
├── docs/                # Documentation technique
├── web/ android/ ios/ linux/ macos/ windows/   # Cibles de plateforme
├── pubspec.yaml         # Dépendances et configuration Flutter
└── api_endpoints.json   # Spécification Swagger (référence)
```

---

## Documentation

- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Développement](docs/development.md)
- [Déploiement](docs/deployment.md)
- [API](docs/api.md)
- [Base de données & cache](docs/database.md)
- [Guide du cache (pratique)](CACHE_USAGE_GUIDE.md)
- [Journal des correctifs](fix.md)

---

## Roadmap

- [ ] Support hors ligne de l'inscription aux événements et de l'édition du profil personnel
- [ ] Tests widgets et `blocTest` sur l'ensemble des BLoCs
- [ ] Internationalisation multilingue (au-delà de `fr_FR`)
- [ ] Notifications push
- [ ] Export des rapports financiers (PDF/CSV)
- [ ] Pipeline de publication automatisé (stores)

Proposez vos idées via les [Issues](https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend/issues).

---

## FAQ

**L'application fonctionne-t-elle hors ligne ?**
Oui. Les données consultées sont mises en cache (Isar) et les écritures hors ligne sont mises en file d'attente puis synchronisées au retour de la connexion. Les requêtes **filtrées** (recherche, pagination) nécessitent toutefois le serveur.

**Pourquoi je vois d'anciennes données après une modification ?**
Le cache se rafraîchit par cycles de 5 minutes. Utilisez `forceSyncNow()` pour un rafraîchissement immédiat.

**Comment configurer l'URL du backend ?**
Dans `lib/core/constants/api_constants.dart` (voir [Configuration](#configuration)).

**Quelles plateformes sont supportées ?**
Android, iOS, Web, Linux, macOS et Windows.

---

## Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](CONTRIBUTING.md) et le [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) avant de commencer.

1. Forkez le dépôt
2. Créez une branche (`git checkout -b feat/ma-fonctionnalite`)
3. Committez selon la convention [Conventional Commits](https://www.conventionalcommits.org/)
4. Ouvrez une Pull Request

---

## Sécurité

Pour signaler une vulnérabilité, **n'ouvrez pas d'Issue publique**. Suivez la procédure décrite dans [SECURITY.md](SECURITY.md).

---

## Licence

Distribué sous licence **MIT**. Voir [LICENSE](LICENSE).

---

## Auteurs

- **DESMOND-77** — Auteur et mainteneur principal — [@DESMOND-77](https://github.com/DESMOND-77)

Projet réalisé dans le cadre d'un **PFE (Projet de Fin d'Études)**.

---

## Remerciements

- L'équipe [Flutter](https://flutter.dev) et l'écosystème Dart
- Les mainteneurs des paquets open source utilisés (voir [`pubspec.yaml`](pubspec.yaml))
- La communauté [`isar_plus`](https://pub.dev/packages/isar_plus)
