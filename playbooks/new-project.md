# Playbook — Lancer un nouveau projet

Procédure complète du "j'ai une idée" à "premier déploiement en ligne".
À suivre dans l'ordre. Chaque étape attend validation avant la suivante.

## 0. Préalable

- Nom du projet décidé (kebab-case).
- Objectif du projet écrit en 2-3 phrases (ce que ça fait, pour qui).
- Budget : si ça dépasse le plan gratuit Vercel/Neon/Resend dès le
  départ, décision consciente.

## 1. Nom de domaine (optionnel, peut être différé)

1. Chercher la dispo : `<nom>.app`, `.com`, `.fr`.
2. Acheter via Cloudflare Registrar (meilleur prix, pas de markup).
3. Configurer les DNS Cloudflare pour pointer vers Vercel (A / CNAME
   renseignés automatiquement quand on ajoute le domaine côté Vercel).

## 2. Repo GitHub

1. Exécuter le skill `skills/setup-nextjs.md`.
2. Vérifier que le repo est **privé** par défaut.
3. Protection de branche : `main` protégé, PR requises (même en solo :
   c'est une barrière contre les pushs accidentels).

## 3. Services externes

### Neon
1. Créer un projet Neon dédié (pas mutualiser avec un autre projet).
2. Récupérer `DATABASE_URL` (pooled) et `DIRECT_URL` (unpooled).
3. Créer une branche `dev` séparée de `main` pour les tests.

### Resend
1. Créer un domaine dans Resend avec `<domaine.tld>`.
2. Configurer les DNS (SPF, DKIM, DMARC) dans Cloudflare.
3. Attendre la vérification (typiquement 5-30 min).
4. Adresse d'envoi : `noreply@<domaine.tld>`.

### Anthropic
1. Créer une clé API dédiée au projet (pas réutiliser une autre clé).
2. Activer un budget mensuel limite pour éviter les mauvaises surprises.

## 4. Configuration locale

1. `.env.local` rempli avec toutes les variables.
2. `.env.example` committé (sans valeurs).
3. `npm run dev` démarre sans erreur.
4. Au moins un flux end-to-end testé (signup → vérif email → login).

## 5. Déploiement

1. Suivre `skills/deploy-vercel.md`.
2. Ajouter le domaine custom côté Vercel.
3. Vérifier que `NEXT_PUBLIC_APP_URL` = domaine custom exact.
4. Tester auth + DB sur le domaine de production.

## 6. Intégration dans claude-config

1. Créer `claude-config/projects/<nom>.md` (template dans
   `projects/README.md`).
2. Ajouter le projet au tableau "Projets actifs" du `CLAUDE.md` global.
3. Dans le repo du projet, créer `CLAUDE.md` avec les imports :
   ```md
   @claude-config/CLAUDE.md
   @claude-config/projects/<nom>.md
   ```
4. Voir `INTEGRATION.md` pour le lien symbolique.

## 7. Premier commit significatif

- Commit sur `main` (via PR) : `chore: setup initial projet <nom>`.
- Tag `v0.0.1`.

## 8. Documentation minimale

Dans `projects/<nom>.md`, remplir dès le jour 1 :
- Stack
- Variables d'env
- Domaine et repo
- Pièges connus (même si vide au début, la section existe)
- Phase en cours

## Checklist finale

- [ ] Repo créé et poussé
- [ ] Services externes provisionnés et testés
- [ ] `.env.local` et `.env.example` alignés
- [ ] Build local OK
- [ ] Premier déploiement Vercel vert
- [ ] Domaine custom fonctionnel (si acheté)
- [ ] Auth end-to-end validée
- [ ] `claude-config/projects/<nom>.md` créé
- [ ] Entrée dans `CLAUDE.md` global ajoutée
