# API

L'application communique avec un backend **Django / DRF** (dépôt séparé) via une API REST.

> La source de vérité est le backend. Le fichier [`../api_endpoints.json`](../api_endpoints.json) (spécification Swagger/OpenAPI) sert de référence mais peut être en retard sur le backend.

## Base

- **URL de base** : configurée dans [`lib/core/constants/api_constants.dart`](../lib/core/constants/api_constants.dart), versionnée sous **`/api/v1/`**.
  - Exemple : `http://127.0.0.1:8000/api/v1`
- **Client** : `DioClient` (`lib/core/network/dio_client.dart`).

## Enveloppe de réponse

Chaque endpoint renvoie :

```json
{
  "success": true,
  "data": { },
  "error": null,
  "message": null
}
```

- Les repositories lisent `response.data["data"]`.
- Pour le texte utilisateur, utilisez `messageOf(e)` (`api_exception.dart`) — jamais `e.toString()`.

## Identifiants

- Toutes les entités utilisent des **UUID (String)**.
- Les enregistrements créés hors ligne reçoivent un **UUID généré côté client** (`lib/core/utils/id_generator.dart`), accepté par le backend (`WritableIDModelSerializer`).

## Dates

- **Envoi** : en UTC — `dt.toUtc().toIso8601String()`.
- **Affichage** : convertir en local — parsez puis `.toLocal()`.

## Authentification

- Connexion via `AuthRepository.login()` : stocke les jetons d'accès et de rafraîchissement dans `SecureStorage`.
- Les jetons sont ajoutés automatiquement à chaque requête par l'interceptor de `DioClient`.
- Le rafraîchissement du jeton sur `401` est **transparent**.
- **La connexion est bloquée côté serveur (403) si l'e-mail n'est pas vérifié** (`REQUIRE_EMAIL_VERIFICATION`).

## Endpoints principaux

Extraits de `ApiConstants` (liste non exhaustive) :

### Auth

| Endpoint | Description |
| --- | --- |
| `POST /auth/login/` | Connexion |
| `POST /auth/register/` | Inscription |
| `POST /auth/logout/` | Déconnexion |
| `GET /auth/me/` | Profil courant |
| `POST /auth/token/refresh/` | Rafraîchissement du jeton |
| `POST /auth/password-reset/` | Demande de réinitialisation |
| `POST /auth/email-verify/` | Vérification d'e-mail |

### Membres

| Endpoint | Description |
| --- | --- |
| `GET/POST /membres/` | Liste / création |
| `GET/PUT/DELETE /membres/{id}/` | Détail / modification / suppression |
| `GET /membres/me/` | Membre lié à l'utilisateur courant |
| `GET /membres/{id}/sacrements/` | Sacrements d'un membre |

### Groupes

| Endpoint | Description |
| --- | --- |
| `GET/POST /groupes/` | Liste / création |
| `GET/PUT/DELETE /groupes/{id}/` | Détail / modification / suppression |
| `GET /groupes/{id}/membres/` | Membres d'un groupe |

### Événements

| Endpoint | Description |
| --- | --- |
| `GET/POST /evenements/` | Liste / création |
| `POST /evenements/{id}/inscrire/` | Inscription |
| `GET /evenements/{id}/participants/` | Participants |

### Finances

| Endpoint | Description |
| --- | --- |
| `GET/POST /finances/transactions/` | Transactions |
| `GET /finances/rapport/` | Rapport financier |
| `GET /finances/membre/{id}/dons/` | Dons d'un membre |

### Librairie

| Endpoint | Description |
| --- | --- |
| `GET/POST /librairie/articles/` | Articles |
| `GET /librairie/articles/alertes/` | Alertes de stock |
| `GET/POST /librairie/ventes/` | Ventes |

### Synchronisation

| Endpoint | Description |
| --- | --- |
| `POST /sync/` | Synchronisation bidirectionnelle (push + pull) |

## Gestion des erreurs

Les repositories interceptent les erreurs de `DioClient` et émettent des états d'erreur. `ApiException._extractMessage` déballe `error` / `detail` / erreurs de champ. En cas de `NetworkException`, les écritures basculent en file d'attente hors ligne (voir [`database.md`](database.md)).
