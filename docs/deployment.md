# Déploiement

Ce document décrit la construction et le déploiement de **Gestion Paroissiale** pour chaque plateforme cible.

## Prérequis communs

```bash
flutter pub get
flutter analyze
flutter test
```

Assurez-vous que `baseUrl` dans `lib/core/constants/api_constants.dart` pointe vers l'API de **production**.

## Android

```bash
# APK (distribution directe)
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

- Artefacts : `build/app/outputs/flutter-apk/app-release.apk` et `build/app/outputs/bundle/release/app-release.aab`.
- **Signature** : configurez `android/key.properties` et un keystore (non versionnés). Voir la [documentation Flutter sur la signature Android](https://docs.flutter.dev/deployment/android#signing-the-app).

## iOS

```bash
flutter build ios --release
```

- Nécessite macOS + Xcode et un compte développeur Apple.
- Finalisez l'archivage et la distribution via Xcode / Transporter.

## Web

```bash
flutter build web --release
```

- Sortie : `build/web/`. À servir derrière n'importe quel serveur statique (Nginx, Firebase Hosting, GitHub Pages, etc.).
- **Important** : les fichiers `isar_plus.wasm` et `isar_plus.js` doivent être servis avec le reste de l'application (ils sont déjà présents dans `web/` et copiés dans le build).

## Desktop

```bash
flutter build linux --release      # build/linux/x64/release/bundle/
flutter build macos --release      # build/macos/Build/Products/Release/
flutter build windows --release    # build/windows/x64/runner/Release/
```

## Publication automatisée (GitHub Actions)

Le workflow [`release.yml`](../.github/workflows/release.yml) construit les artefacts et crée une **Release GitHub** lorsqu'un tag `vX.Y.Z` est poussé :

```bash
# 1. Mettre à jour la version dans pubspec.yaml et CHANGELOG.md
# 2. Créer et pousser le tag
git tag v1.0.0
git push origin v1.0.0
```

La Release publie automatiquement l'APK, l'App Bundle et l'archive Web, avec des notes de version générées.

## Checklist de release

- [ ] Version mise à jour dans `pubspec.yaml` (`version: X.Y.Z+N`)
- [ ] `CHANGELOG.md` complété
- [ ] `baseUrl` de production vérifiée
- [ ] `flutter analyze` et `flutter test` au vert
- [ ] Tag `vX.Y.Z` poussé
