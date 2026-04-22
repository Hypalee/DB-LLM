# deploy-vercel

Déployer ou redéployer un projet Next.js sur Vercel.

## Quand l'utiliser
- "Déploie ce projet sur Vercel"
- "Le déploiement a échoué, débogue"
- "Ajoute une variable d'env et redéploie"

## Inputs attendus
- Nom du projet Vercel (ou lien au repo GitHub)
- Branche à déployer (défaut : `main`)
- Variables d'env à configurer le cas échéant

## Procédure

### 1. Vérifier l'état local
- `git status` doit être propre, sinon commit/stash d'abord.
- `npm run build` doit passer en local. Si échec, corriger avant push.
- `npm run typecheck` ou équivalent doit être vert.

### 2. Variables d'environnement
Vérifier que toutes les variables requises sont présentes côté Vercel :

- `DATABASE_URL` (Neon pooled)
- `DIRECT_URL` (Neon unpooled, pour migrations)
- `BETTER_AUTH_SECRET`
- `BETTER_AUTH_URL` = URL publique exacte du déploiement
- `NEXT_PUBLIC_APP_URL` = **même valeur** que `BETTER_AUTH_URL`
- `RESEND_API_KEY`
- `ANTHROPIC_API_KEY`
- Stripe (si phase 2) : `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`

Comparer avec `.env.example` du projet. Si une variable manque dans
Vercel, l'ajouter via dashboard ou `vercel env add`.

### 3. Push et déploiement
- Push sur la branche cible.
- Vercel déclenche automatiquement le déploiement.
- Suivre le build log (`vercel logs` ou dashboard).

### 4. Vérification post-déploiement
- Page d'accueil : 200 OK.
- Auth : login, logout, signup fonctionnels.
- DB : au moins une requête passe (ex: lister les notes).
- Resend : envoi d'un email de vérif test.

## Pièges à éviter

- **`NEXT_PUBLIC_APP_URL` ≠ domaine réellement servi** → les cookies
  Better Auth ne matchent pas, l'utilisateur est déloggé en boucle.
  Bien mettre **exactement** `https://brain-app.app` (pas de slash
  final, pas de `www`).
- **`DATABASE_URL` pooled pour migrations** → les migrations doivent
  utiliser `DIRECT_URL` (non-poolée), sinon erreurs de locks.
- **Build cache Vercel** qui garde un vieux `.next/` → si comportement
  étrange post-déploiement, tenter un "Redeploy without cache".
- **Preview vs Production envs** : Vercel distingue les deux, une
  variable ajoutée en Production n'est pas automatiquement en Preview.

## Sortie attendue
- URL de production validée (200 + auth OK).
- Si échec : cause racine identifiée et corrigée (pas un workaround).
