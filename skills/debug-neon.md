# debug-neon

Diagnostiquer un souci Neon Postgres : connexion, lenteurs, schéma.

## Quand l'utiliser
- "La DB ne répond pas"
- "Erreur de connexion Postgres"
- "Une requête est lente"
- "Le schéma ne correspond pas à ce que j'attends"

## Inputs attendus
- Message d'erreur exact ou symptôme observé
- Accès à `DATABASE_URL` et `DIRECT_URL` via `.env.local`
- Optionnel : requête SQL fautive

## Procédure

### 1. Connectivité de base
```bash
psql "$DATABASE_URL" -c "SELECT 1;"
```
- Si timeout → vérifier si la compute Neon est "suspended" (plan free
  la met en veille après inactivité). Premier hit la réveille en ~1s.
- Si `password authentication failed` → rotation de mot de passe côté
  Neon, mettre à jour `.env.local` et Vercel.

### 2. Vérifier le schéma
```bash
psql "$DATABASE_URL" -c "\dt"          # lister les tables
psql "$DATABASE_URL" -c "\d \"user\""  # inspecter une table (quotes car nom réservé)
```
- Better Auth crée : `user`, `session`, `account`, `verification`.
- Plugin 2FA ajoute : `twoFactor` + colonne `twoFactorEnabled` sur
  `user` (piège : pas dans le schéma de base).

### 3. Pooled vs Direct
- `DATABASE_URL` (pooled, `...-pooler.neon.tech`) pour l'app en prod.
- `DIRECT_URL` (unpooled) pour migrations, introspection, long-lived
  connections.
- Erreurs typiques si inversé :
  - `prepared statement "s1" already exists` → using pooled pour une
    migration : passer sur DIRECT_URL.
  - Latence élevée inutile → using direct en serverless : passer pooled.

### 4. Requêtes lentes
```sql
EXPLAIN ANALYZE <requête>;
```
- Chercher `Seq Scan` sur grosses tables → index manquant.
- Chercher `Rows Removed by Filter` élevé → filtre trop tardif.
- Ajouter index via migration, jamais directement en prod sans trace.

### 5. Locks / transactions bloquées
```sql
SELECT pid, state, wait_event_type, query
FROM pg_stat_activity
WHERE state != 'idle';
```

## Pièges à éviter

- **Suspended compute** interprété comme bug → attendre 2s et retry.
- **Ne jamais `DROP TABLE` sans backup** sur une base partagée avec
  Better Auth : les tables `user`, `session` sont critiques.
- **Ne pas éditer le schéma directement** en prod. Toujours via
  migration versionnée (voir `playbooks/db-migration.md`).
- **Branches Neon** : profiter de `neon branches create` pour tester
  une migration sur une copie, pas sur main.

## Sortie attendue
- Cause racine identifiée (connexion, schéma, requête, ou config).
- Correction appliquée OU plan de correction clair si risqué (à valider
  avec moi avant exécution).
