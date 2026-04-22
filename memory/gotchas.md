# Pièges (gotchas)

Bugs subtils, comportements non documentés, erreurs à ne pas
répéter. Format :

```
### <titre court>
- **Contexte** : projet(s) + stack concernés
- **Symptôme** : ce qu'on voit
- **Cause** : la vraie raison
- **Fix** : comment corriger
- **Prévention** : comment ne pas y retomber
```

---

### Plugin 2FA Better Auth : colonne `twoFactorEnabled` sur `user`
- **Contexte** : Brain, Better Auth + plugin 2FA TOTP.
- **Symptôme** : erreur SQL au login dès qu'un user active la 2FA,
  `column "twoFactorEnabled" does not exist`.
- **Cause** : le plugin `twoFactor` ajoute cette colonne **à la table
  `user`**, en plus de créer la table `twoFactor`. Ce n'est pas dans le
  schéma de base Better Auth, facile à rater en relisant la doc.
- **Fix** : regénérer le schéma DB via la CLI Better Auth après l'ajout
  du plugin (`npx @better-auth/cli generate`).
- **Prévention** : **toujours** regénérer le schéma après
  ajout/suppression d'un plugin Better Auth, même pour un plugin qui
  "semble" ne toucher que sa propre table.

---

### `NEXT_PUBLIC_APP_URL` ≠ domaine servi → cookies Better Auth cassés
- **Contexte** : Brain, Vercel + domaine custom `brain-app.app`.
- **Symptôme** : login fonctionne, mais l'utilisateur est redéloggé au
  refresh. Ou bien loggé en apparence mais `session` introuvable côté
  serveur.
- **Cause** : Better Auth utilise `NEXT_PUBLIC_APP_URL` (ou
  `BETTER_AUTH_URL`) pour fixer le scope du cookie de session. Si la
  valeur ne matche pas **exactement** le domaine réellement servi
  (trailing slash, www vs apex, http vs https), le cookie est posé
  sur un domaine et relu sur un autre → perdu.
- **Fix** : poser `NEXT_PUBLIC_APP_URL=https://brain-app.app` et
  `BETTER_AUTH_URL=https://brain-app.app` **exactement**. Pas de `/`
  final, pas de `www.`.
- **Prévention** : check-list dans `skills/deploy-vercel.md`, et
  tester post-déploiement avec un login + refresh.

---

### Neon compute "suspended" interprété comme bug
- **Contexte** : Neon plan free, pause de compute après inactivité.
- **Symptôme** : premier appel de la matinée met 1-2s, panique "c'est
  cassé".
- **Cause** : c'est normal, pas un bug.
- **Fix** : rien, ou passer à un plan payant si gênant.
- **Prévention** : ajouter une note visible dans `projects/<nom>.md`.

---

### Migration DB avec `DATABASE_URL` pooled
- **Contexte** : Neon pooled vs unpooled.
- **Symptôme** : `prepared statement "s1" already exists` pendant une
  migration.
- **Cause** : pooler PgBouncer ne supporte pas les prepared statements
  comme Postgres direct.
- **Fix** : utiliser `DIRECT_URL` pour les migrations.
- **Prévention** : scripts de migration pointent toujours sur
  `DIRECT_URL`, jamais sur `DATABASE_URL`.
