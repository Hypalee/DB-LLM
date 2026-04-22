# Décisions architecturales

Journal des décisions structurantes. Format :

```
### YYYY-MM-DD — <titre court>
- **Contexte** : ...
- **Options considérées** : ...
- **Décision** : ...
- **Conséquences** : ...
```

---

### 2026-04-22 — Création d'un repo `claude-config` centralisé
- **Contexte** : travailler avec Claude Code CLI sur plusieurs projets
  (<projet> + à venir), besoin de continuité entre les sessions.
- **Options considérées** :
  1. CLAUDE.md dupliqué dans chaque projet.
  2. Repo centralisé importé via `@claude-config/...`.
  3. RAG vectoriel (embeddings + recherche sémantique).
- **Décision** : option 2. Markdown structuré importé via symlink /
  submodule. RAG évalué mais non retenu à ce stade (cf. `WORKFLOW.md`).
- **Conséquences** : un seul endroit à maintenir, contexte partagé
  entre projets, facilité à onboarder un nouveau projet.

---

### 2026-04-22 — Better Auth plutôt que NextAuth pour <projet>
- **Contexte** : besoin auth multi-user avec 2FA TOTP pour <projet>.
- **Options considérées** : NextAuth/Auth.js, Clerk, Better Auth,
  Supabase Auth.
- **Décision** : Better Auth. API propre, self-hosted, 2FA natif,
  moins de magie que Clerk, moins de friction que NextAuth v5.
- **Conséquences** :
  - Schéma DB à gérer soi-même (tables `user`, `session`, `account`,
    `verification` + plugin 2FA ajoute `twoFactor` et colonne
    `twoFactorEnabled`).
  - `NEXT_PUBLIC_APP_URL` doit coller exactement au domaine servi.
