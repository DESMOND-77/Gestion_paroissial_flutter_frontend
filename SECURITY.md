# Politique de sécurité

La sécurité de **Gestion Paroissiale** est une priorité. Ce document décrit les versions supportées et la procédure de signalement des vulnérabilités.

## Versions supportées

Les correctifs de sécurité sont appliqués à la dernière version mineure publiée.

| Version | Support de sécurité |
| --- | --- |
| 1.0.x  | ✅ Supportée |
| < 1.0  | ❌ Non supportée |

## Signaler une vulnérabilité

**N'ouvrez pas d'Issue publique pour une faille de sécurité.**

Merci de signaler toute vulnérabilité de manière privée, par l'un des canaux suivants :

1. **GitHub Security Advisories** (recommandé) — via l'onglet **« Security » → « Report a vulnerability »** du dépôt, qui permet une divulgation coordonnée et privée.
2. **E-mail** — à **dut2.git2025@gmail.com** avec l'objet `[SECURITY] Gestion Paroissiale`.

Merci d'inclure, dans la mesure du possible :

- une description de la vulnérabilité et de son impact ;
- les étapes de reproduction ou un exemple de code ;
- la version, la plateforme et l'environnement concernés ;
- toute suggestion de correctif éventuelle.

## Délais de réponse

| Étape | Délai indicatif |
| --- | --- |
| Accusé de réception | sous **72 heures** |
| Évaluation initiale | sous **7 jours** |
| Correctif ou plan d'action | selon la gravité, généralement sous **30 jours** |

Ces délais sont donnés à titre indicatif ; ce projet est maintenu à titre bénévole et académique.

## Divulgation responsable

Nous appliquons une politique de **divulgation coordonnée** :

- Nous vous tiendrons informé de l'avancement du traitement.
- Nous vous demandons de **ne pas divulguer publiquement** la vulnérabilité tant qu'un correctif n'est pas disponible.
- Avec votre accord, nous vous **créditerons** dans l'avis de sécurité et le `CHANGELOG.md`.

## Politique CVE

Pour les vulnérabilités confirmées et à impact significatif, un identifiant **CVE** pourra être demandé via le programme GitHub Security Advisories. L'avis correspondant sera publié après la mise à disposition du correctif.

## Bonnes pratiques de sécurité du projet

- Les jetons JWT sont stockés via `flutter_secure_storage`, jamais en clair.
- L'authentification impose la **vérification d'e-mail** côté serveur ; aucune session n'est persistée pour un compte non vérifié.
- L'accès aux fonctionnalités est contrôlé par rôle, en miroir des permissions du backend.
- Les analyses de sécurité automatisées (CodeQL, Dependabot) sont exécutées via GitHub Actions.

Merci de contribuer à la sécurité du projet. 🔒
