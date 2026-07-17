# Installation

Ce guide décrit l'installation de l'environnement de développement de **Gestion Paroissiale**.

## Prérequis

- **Flutter SDK** ≥ 3.3.0 (canal stable — testé avec Flutter 3.44.x / Dart 3.x)
- **Git**
- Un backend Gestion Paroissiale accessible (Django/DRF)
- Selon la ou les cibles de build :
  - **Android** : Android SDK + un JDK 17
  - **iOS / macOS** : Xcode (macOS uniquement)
  - **Linux desktop** : `clang`, `cmake`, `ninja-build`, `libgtk-3-dev`
  - **Windows desktop** : Visual Studio (charge de travail « Desktop C++ »)
  - **Web** : un navigateur Chromium

Vérifiez votre installation :

```bash
flutter doctor -v
```

## Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend.git
cd Gestion_paroissial_flutter_frontend

# 2. Récupérer les dépendances
flutter pub get

# 3. (Optionnel) Régénérer le code généré (Isar)
dart run build_runner build --delete-conflicting-outputs
```

> Les fichiers générés (`*.g.dart`) sont versionnés : l'étape 3 n'est nécessaire qu'après modification de `lib/core/database/cached_entity.dart` ou `pending_change_entity.dart`.

## Configuration de l'API

Ouvrez `lib/core/constants/api_constants.dart` et assurez-vous qu'**une seule** ligne `baseUrl` est active :

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
```

Adaptez l'adresse à votre backend (sur mobile physique, utilisez l'IP de votre machine sur le réseau local, pas `127.0.0.1`).

## Spécificités Web (Isar WASM)

Sur le Web, le moteur Isar s'exécute en WASM et doit être chargé avant usage. Les fichiers `web/isar_plus.wasm` et `web/isar_plus.js` sont **auto-hébergés** dans le dépôt et doivent correspondre à la version d'`isar_plus` épinglée dans `pubspec.yaml`.

Si vous mettez à jour `isar_plus`, re-téléchargez les deux fichiers depuis `unpkg.com/isar_plus@<version>` et remplacez-les dans `web/`.

## Vérification

```bash
flutter analyze     # aucune erreur attendue
flutter test        # les tests passent
flutter run         # l'application démarre
```

En cas de problème, consultez la section « Common Issues & Solutions » de [`CLAUDE.md`](../CLAUDE.md) et le [journal des correctifs](../fix.md).
