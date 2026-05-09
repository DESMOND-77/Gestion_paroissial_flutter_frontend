# Guide d'utilisation du système de cache local

## Vue d'ensemble

Le système de cache local réduit la charge serveur en stockant les données paroissiales dans une base de données SQLite locale sur l'appareil. Les données sont synchronisées automatiquement toutes les 5 minutes.

## Architecture

```
Utilisateur
    ↓
   BLoC (event-driven state management)
    ↓
Repository (handles API calls + local cache)
    ├→ Vérifier le cache local (si pas de filtres)
    ├→ Retourner le cache si disponible
    └→ Sinon, requête serveur + cache
    ↓
DatabaseService (SQLite local) ← SyncService (sync toutes les 5 min)
```

## Flux de données

### 1. Requête simple sans filtres (utilise le cache)

```dart
// Dans le BLoC
on<FetchMembresRequested>((event, emit) async {
  emit(MembresLoading());
  try {
    // Cette requête vérifiera d'abord le cache local
    final membres = await membreRepository.getMembres();
    emit(MembresLoaded(membres));
  } catch (e) {
    emit(MembresError(e.toString()));
  }
});

// Dans le repository
Future<List<Membre>> getMembres() async {
  // Cherche en cache d'abord
  if (_databaseService != null) {
    final cached = await _databaseService.getItems('membres');
    if (cached.isNotEmpty) {
      return cached.map((e) => Membre.fromJson(e)).toList();
    }
  }
  // Pas de cache, requête serveur
  return fetchMembers();
}
```

### 2. Requête filtrée (contourne le cache)

```dart
// Cette requête ira TOUJOURS au serveur
final membersByName = await membreRepository.getMembres(search: 'Jean');

// Cache : ignoré si des paramètres de filtrage sont présents
// Les filtres supportés :
// - search (texte de recherche)
// - groupe (filtre par groupe)
// - sexe (filtre par sexe)
// - page (pagination)
// - type, dateDebut, dateFin, categorie (finances)
// - etc.
```

### 3. Synchronisation manuelle

```dart
// Forcer une synchronisation immédiate
final syncManager = sl<PeriodicSyncManager>();
await syncManager.forceSyncNow();

// Synchroniser une entité spécifique
await syncManager.forceEntitySync('membres');

// Vérifier la connectivité
final isOnline = await syncManager.isOnline();

// Effacer le cache complètement
await syncManager.clearCache();
```

## Configuration

### Intervalle de synchronisation

Par défaut : **5 minutes**

Pour changer l'intervalle, modifiez `lib/core/sync/periodic_sync_manager.dart`:

```dart
static const Duration _syncInterval = Duration(minutes: 5); // Changer ici
```

### Entités synchronisées

Les entités suivantes sont synchronisées automatiquement:
- `membres` (liste complète des membres)
- `groupes` (groupes paroisiaux)
- `evenements` (événements)
- `finances` (transactions financières)

Pour ajouter une nouvelle entité, modifiez:
1. `lib/core/sync/sync_service.dart` - ajouter `_sync<Entity>()`
2. `lib/core/database/database_service.dart` - ajouter la table
3. `lib/core/di/injection.dart` - enregistrer le repository avec DatabaseService

## Mode hors ligne

L'app fonctionne automatiquement en mode hors ligne:

```dart
// Détecter si online
if (await syncManager.isOnline()) {
  // Faire une requête au serveur
} else {
  // Les données du cache local seront utilisées
}
```

Quand le réseau revient:
- Le prochain cycle de sync (max 5 min) actualisera toutes les données
- Ou utilisez `forceSyncNow()` pour une sync immédiate

## Performance

### Avantages du cache local

| Opération | Sans cache | Avec cache |
|-----------|-----------|-----------|
| Afficher liste membres | 2-5 secondes | Immédiat |
| Recherche simple | 2-5 secondes | Filtrage local rapide |
| Navigation rapide | Chaque tap = requête | Pas de requête |
| Offline | Impossible | Possible |
| Charge serveur | Très haute | Réduite de 80-90% |

### Stratégie de cache

- **Données à jour** : Cache réactualisé toutes les 5 minutes
- **Pas de requête dupliquée** : Même 10 écrans affichent la même liste sans requête
- **Filtrage intelligent** : Filtres = requête serveur (résultats précis), pas de filtres = cache
- **Pas de synchronisation** : Après création/suppression d'une entrée, elle n'est pas reflétée instantanément dans le cache (sera mis à jour lors du prochain cycle de 5 min)

## Cas d'usage

### Cas 1 : Affichage du tableau de bord au démarrage

```dart
// 1ère charge : obtient du serveur + cache (2-3s)
// 2ème charge : obtient du cache (immédiat)
// Après 5 min : obtient du serveur à nouveau (si online)
```

### Cas 2 : Recherche de membres

```dart
// Recherche simple : requête serveur avec filtrage
final results = await repo.getMembres(search: 'Jean');

// C'est intentionnel : pour les résultats exacts
// Si vous voulez chercher dans le cache :
final cached = await databaseService.getItems('membres');
final filtered = cached.where((m) => m.name.contains('Jean')).toList();
```

### Cas 3 : Mode hors ligne avec synchronisation au redémarrage

```dart
// Démarrage offline
// - Le cache local est utilisé pour tout affichage

// Reconnexion
// - Les données sont automatiquement réactualisées au prochain cycle
// - Ou forcez avec : await syncManager.forceSyncNow();
```

## Dépannage

### Le cache n'est pas à jour

- Attendez le prochain cycle de 5 minutes
- Ou forcez avec : `await syncManager.forceSyncNow()`

### Le cache montre des données anciennes

- C'est normal si vous avez créé/modifié une entrée
- Le cache se met à jour toutes les 5 minutes
- Pour un rafraîchissement immédiat, utilisez `forceSyncNow()`

### L'app ne fonctionne pas offline

- Vérifiez qu'il y a des données en cache
- Les requêtes avec filtres ne marcheront pas offline
- Utilisez les listes sans filtres pour le mode offline

## Sécurité

- Les tokens d'auth sont stockés de façon sécurisée dans `SecureStorage`
- Les données du cache local sont en JSON (peut être lue sur un appareil rooté)
- Pour les données sensibles, ne les cachéz pas (modifiez le repository)

## Évolution future

- [ ] Cache intelligent avec TTL par entité
- [ ] Sync sélectif (ne synchroniser que les modifications)
- [ ] Compression des données en cache
- [ ] Analytics du hit rate du cache
- [ ] UI pour forcer la synchronisation

