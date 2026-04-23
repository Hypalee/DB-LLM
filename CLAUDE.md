# CLAUDE.md — Contexte global

> Ce fichier est le "cerveau global" importé dans chaque projet via
> `@claude-config/CLAUDE.md`. Il décrit le développeur, la stack, les
> conventions et les projets actifs. Le contexte spécifique à un projet vit
> dans `projects/<nom>.md`.

## 1. Profil développeur

- **Localisation** : France (fuseau Europe/Paris)
- **Mode** : développeur solo, sans équipe
- **Stack principale** :
  - Frontend : Next.js 16 (App Router), React, Tailwind v4
  - Backend : Routes API Next.js, Server Actions
  - DB : Neon Postgres (serverless)
  - Auth : Better Auth (email+password, 2FA TOTP, vérif email Resend)
  - IA : Anthropic SDK (Claude)
  - Hébergement : Vercel
  - DNS : Cloudflare
  - Paiement (à venir) : Stripe
- **Outils** : Claude Code CLI, GitHub, VS Code

## 2. Conventions code

### Langage
- **TypeScript strict obligatoire**. Pas de `any`, pas de `as any`, pas de
  `@ts-ignore`. Si le type est dur à exprimer, modéliser proprement (union,
  generic, `unknown` + narrowing).
- **Pas de workaround**. Si un hack semble nécessaire, creuser la cause
  racine. Préférer supprimer du code plutôt qu'en ajouter.
- **Commentaires uniquement pour le *pourquoi* non-évident** (contrainte
  cachée, bug contourné, invariant subtil). Jamais pour décrire ce que
  fait le code.
- **Nommage** : variables, fonctions, fichiers et identifiants en anglais.

### UI
- Textes affichés à l'utilisateur en **français**.
- Tailwind v4, classes utilitaires directement dans le JSX (pas de
  `@apply` sauf exception justifiée).
- Accessibilité : labels associés, focus visible, contrastes AA minimum.

### Git
- **Commits en français**, conventional commits :
  - `feat(scope): ...` nouvelle fonctionnalité
  - `fix(scope): ...` correction
  - `refactor(scope): ...` refacto sans changement fonctionnel
  - `chore(scope): ...` config, deps, outillage
  - `docs(scope): ...` documentation
- **Scope** = zone touchée (ex: `auth`, `notes`, `db`, `api`, `ui`).
- Un commit = une intention. Pas de commits fourre-tout.
- **Jamais `--no-verify`**, jamais `push --force` sur `main`.

### Architecture
- **Simplicité d'abord**. Pas d'abstraction prématurée : trois lignes
  dupliquées > un helper mal conçu.
- Pas de feature flag ni de shim de rétrocompat si on peut juste changer
  le code.
- Validation aux frontières seulement (input user, API externe). À
  l'intérieur du code, faire confiance aux types et aux garanties du
  framework.
- Un fichier, une responsabilité. Si un module dépasse ~300 lignes ou
  mélange plusieurs préoccupations, découper.

## 3. Philosophie de travail

- **Simple, propre, zéro workaround.**
- **Préférer supprimer plutôt qu'ajouter.** Code non utilisé = dette.
- **Fix the root cause, not the symptom.**
- **Ship small, ship often.** Pas de branches longues.
- **Claude est un pair**, pas un générateur. Je veux comprendre ce qui est
  écrit avant de le merger.

## 4. Projets actifs

| Projet | Statut | Description | Fichier |
|--------|--------|-------------|---------|
| Brain  | Phase 1 en cours | App de capture de notes enrichies par Claude | `projects/brain.md` |

> Ajouter un projet = créer `projects/<nom>.md` et l'inscrire ici.

## 5. Règles universelles pour Claude Code

Quand Claude Code travaille sur un de mes projets :

1. **Lire `projects/<nom>.md` avant toute modification non triviale** pour
   connaître les pièges spécifiques au projet.
2. **Ne jamais pousser sur `main` directement.** Toujours branche + PR.
3. **Ne jamais committer de `.env`**, clés API, ou secrets. Si un secret
   est détecté dans le diff, arrêter et alerter.
4. **Avant un changement de schéma DB** (migration, colonne, contrainte),
   vérifier si d'autres tables/plugins (ex: Better Auth) ont des attentes
   sur ce schéma. Documenter la migration dans `memory/decisions.md`.
5. **Avant d'ajouter une dépendance**, vérifier qu'elle n'est pas déjà
   couverte par l'existant. Justifier l'ajout dans le commit.
6. **Tests UI** : si un changement touche l'interface, le tester dans un
   navigateur avant de déclarer la tâche terminée. Sinon le dire
   explicitement.
7. **Quand une décision architecturale est prise**, l'ajouter à
   `memory/decisions.md` avec la date et le raisonnement.
8. **Quand un piège est découvert** (bug subtil, comportement non
   documenté), l'ajouter à `memory/gotchas.md` et au `projects/<nom>.md`
   concerné.
9. **Quand tu m'expliques en détail un concept IA / Claude Code /
   agents** (définitions, patterns, architectures, tradeoffs), ou
   quand je te demande explicitement de prendre des notes, écrire un
   nouveau chapitre ou enrichir un chapitre existant dans `learning/`.
   Format : chapitres numérotés (`NN-titre.md`), TOC en tête,
   auto-portant (lisible à froid), pensé pour export PDF et partage.
   Voir `learning/README.md` pour la convention.

## 6. Imports

Ce repo est conçu pour être importé dans chaque projet via un lien
symbolique ou un submodule. Voir `INTEGRATION.md` pour la procédure.

Dans un projet, le `CLAUDE.md` local commence typiquement par :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<nom-projet>.md

## Contexte spécifique à ce projet
...
```
