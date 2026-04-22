# Brain

## Résumé
App de capture de notes enrichies par Claude : l'utilisateur balance
des notes brutes, Claude les structure, les catégorise et les rend
exploitables.

## Stack
- Next.js 16 (App Router)
- Tailwind v4
- Neon Postgres (serverless)
- Better Auth (email+password, 2FA TOTP, vérif email)
- Resend (emails transactionnels)
- Anthropic SDK (enrichissement des notes par Claude)
- Vercel (hébergement)
- Cloudflare (DNS + registrar)

## Repo & déploiement
- Repo : `Hypalee/Brain`
- Branche principale : `main`
- Prod : `https://brain-app.app`
- Hébergement : Vercel

## Domaine
- `brain-app.app` acheté via Cloudflare Registrar.
- DNS gérés dans Cloudflare, pointés vers Vercel.
- SPF/DKIM/DMARC configurés pour Resend.

## Variables d'environnement

| Nom                      | Usage                                                     | Où la trouver              |
|--------------------------|-----------------------------------------------------------|----------------------------|
| `DATABASE_URL`           | Connexion app (pooled)                                    | Neon dashboard             |
| `DIRECT_URL`             | Migrations (unpooled)                                     | Neon dashboard             |
| `BETTER_AUTH_SECRET`     | Signature des sessions Better Auth                        | généré localement, stable  |
| `BETTER_AUTH_URL`        | URL publique, **exactement** le domaine servi             | `https://brain-app.app`    |
| `NEXT_PUBLIC_APP_URL`    | Idem côté client, **même valeur** que `BETTER_AUTH_URL`   | `https://brain-app.app`    |
| `RESEND_API_KEY`         | Envoi d'emails (vérif, reset)                             | Resend dashboard           |
| `ANTHROPIC_API_KEY`      | Enrichissement des notes                                  | Console Anthropic          |

Expéditeur d'emails : `noreply@brain-app.app`.

## Schéma DB (vue d'ensemble)

Tables Better Auth (auto-gérées par le schéma Better Auth) :
- `user` (inclut `twoFactorEnabled` ajouté par le plugin 2FA)
- `session`
- `account`
- `verification`
- `twoFactor` (ajoutée par le plugin 2FA)

Tables métier :
- `notes` avec `user_id TEXT` (pas UUID, car l'ID user Better Auth est
  string).
- `subscriptions` (préparée pour la phase 2 Stripe).
- `usage_logs` (tracking usage pour freemium).

Toutes les tables métier ont une FK sur `user.id` avec `ON DELETE
CASCADE` pour nettoyer proprement à la suppression d'un compte.

## Services tiers

### Neon
- Un projet Neon dédié Brain.
- Branche `main` = prod. Branches de test créées à la volée pour les
  migrations (cf. `playbooks/db-migration.md`).

### Resend
- Domaine `brain-app.app` vérifié.
- Sender : `noreply@brain-app.app`.
- Utilisé pour : vérification email, reset mot de passe.

### Anthropic
- Clé API dédiée Brain (budget mensuel limité).
- Modèle par défaut : `claude-opus-4-7` (à réévaluer selon coût/qualité
  vs Sonnet).

## Phase actuelle

- **Phase 1 — Auth multi-user** : en cours de finalisation.
  - [x] Signup / login email+password
  - [x] Vérification email via Resend
  - [x] 2FA TOTP
  - [ ] Flow reset mot de passe complet
  - [ ] Suppression de compte (RGPD)

- **Phase 2 — Stripe + freemium** : à venir.
  - Plan gratuit limité (X notes/mois ou X appels Claude/mois).
  - Plan payant mensuel.
  - Webhooks Stripe (cf. `playbooks/new-service-integration.md`).

## Pièges spécifiques

- **Plugin 2FA ajoute `twoFactorEnabled` à `user`** → toujours
  regénérer le schéma Better Auth après modification des plugins
  (cf. `memory/gotchas.md`).
- **`NEXT_PUBLIC_APP_URL` doit matcher exactement le domaine servi**
  sinon les cookies Better Auth sont perdus (cf. `memory/gotchas.md`).
- **`user.id` est un string (nanoid)** pas un UUID → toutes les FK
  métier sont TEXT, pas UUID.
- **Neon free tier** : compute suspendu après inactivité, premier hit
  du matin met 1-2s. C'est normal.

## Roadmap court terme

- [ ] Finir reset mot de passe (email + formulaire + endpoint).
- [ ] Page "Mon compte" (changement mot de passe, activation 2FA,
      suppression compte).
- [ ] Préparer les tables Stripe (sans intégration encore).
- [ ] Rate limiting basique sur l'API d'enrichissement Claude.
