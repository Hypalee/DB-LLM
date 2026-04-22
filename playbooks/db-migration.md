# Playbook — Migration DB en sécurité

Toute migration sur une base en prod passe par ce playbook. Pas
d'exception, même pour "juste un index".

## Principe

1. **Branche Neon** pour tester (pas de risque prod).
2. **Migration versionnée** (fichier dans le repo, pas de SQL ad hoc).
3. **Validation** en local + branche Neon avant prod.
4. **Trace** dans `memory/decisions.md`.

## 1. Préparation

- Identifier **pourquoi** la migration est nécessaire (bug, feature,
  perf). Écrire une phrase.
- Identifier l'impact : combien de lignes touchées, verrous possibles,
  downtime potentiel ?
- Vérifier qu'aucune table critique tierce (ex: `user`, `session` de
  Better Auth) n'est touchée sans nécessité absolue.

## 2. Écriture de la migration

- Créer un fichier daté : `migrations/YYYY-MM-DD_<description>.sql` ou
  via `drizzle-kit generate`.
- **Idempotente quand possible** (`IF NOT EXISTS`, `IF EXISTS`).
- **Pas de `DROP TABLE`** sans backup explicite dans le playbook.
- Pour un renommage de colonne : ajouter nouvelle colonne → backfill
  → deploy code qui lit la nouvelle → supprimer l'ancienne. Jamais en
  une seule étape.

## 3. Test sur branche Neon

```bash
# Créer une branche depuis la prod
neon branches create --name migration-test --parent main

# Pointer DIRECT_URL vers la branche de test
# Lancer la migration
npm run db:migrate
```

Vérifier :
- [ ] Schéma conforme après migration.
- [ ] App tourne sans erreur contre la nouvelle DB.
- [ ] Requêtes fréquentes toujours rapides (EXPLAIN ANALYZE si doute).

Si OK → supprimer la branche de test.

## 4. Déploiement

1. Commit de la migration + code qui l'utilise sur une branche.
2. PR, revue (skill `review-pr`).
3. Merge sur `main`.
4. Vercel déploie. **Côté DB**, deux cas :
   - **Migration automatique au build** : ok si idempotente et rapide.
   - **Migration manuelle** : exécuter via script dédié contre
     `DIRECT_URL` de prod, **avant** que le nouveau code prenne le
     trafic (basculer via feature flag ou temporairement pause
     déploiement).

## 5. Post-déploiement

- [ ] Vérifier logs Vercel : pas d'erreur 500 liée au schéma.
- [ ] Vérifier une opération critique end-to-end (ex: signup crée bien
      la ligne dans la nouvelle forme).
- [ ] Ajouter une entrée dans `memory/decisions.md` :
  ```
  ### YYYY-MM-DD — Migration <description>
  - Raison : ...
  - Impact : ...
  - Rollback : ...
  ```

## Rollback

- Pour tout changement risqué, documenter la **procédure de rollback
  avant d'exécuter la migration**. Exemples :
  - Ajout de colonne nullable : DROP COLUMN si non utilisée.
  - Ajout d'index : DROP INDEX.
  - Renommage : si étape multi-deploy suivie, chaque étape a son
    rollback propre.

## Pièges récurrents

- **Pooled URL pour migration** → erreurs de prepared statements.
  Utiliser `DIRECT_URL`.
- **Modifier la table `user` de Better Auth** sans comprendre les
  plugins → incident auth global. Vérifier la doc Better Auth avant.
- **Index en prod sur grosse table** sans `CONCURRENTLY` → lock long.
  Toujours `CREATE INDEX CONCURRENTLY` en Postgres.
- **Migration qui change la forme d'une colonne utilisée partout** →
  split en 2 déploiements (write both old + new, puis flip).
