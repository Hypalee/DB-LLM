# claude-config

Repo centralisé qui sert de **cerveau global** pour toutes mes sessions
Claude Code. Importé dans chaque projet pour assurer la continuité et la
mémoire entre sessions.

## Structure

```
claude-config/
├── CLAUDE.md           → Contexte global (profil, stack, conventions)
├── INTEGRATION.md      → Comment utiliser ce repo depuis un projet
├── WORKFLOW.md         → Comment maintenir ce repo à jour
├── skills/             → Skills Claude Code réutilisables
│   ├── deploy-vercel.md
│   ├── debug-neon.md
│   ├── review-pr.md
│   ├── setup-nextjs.md
│   └── README.md
├── playbooks/          → Procédures step-by-step
│   ├── new-project.md
│   ├── db-migration.md
│   ├── new-service-integration.md
│   └── README.md
├── memory/             → Mémoire persistante entre sessions
│   ├── decisions.md    → Décisions architecturales
│   ├── gotchas.md      → Pièges à ne pas répéter
│   ├── lessons.md      → Leçons apprises
│   └── README.md
└── projects/           → Un fichier par projet actif
    ├── <projet>.md
    └── README.md
```

## Utilisation rapide

Dans un projet existant, créer un lien vers ce repo et importer ce qu'il
faut depuis le `CLAUDE.md` du projet :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<projet>.md
```

Voir [INTEGRATION.md](./INTEGRATION.md) pour les détails.

## Maintenance

Voir [WORKFLOW.md](./WORKFLOW.md) pour les conventions de mise à jour
(décisions, leçons, commits).

## Principes

- **Markdown d'abord.** Pas de RAG vectoriel pour l'instant (voir
  `WORKFLOW.md` section "Faut-il un vrai RAG ?").
- **Structuré mais vivant.** Chaque fichier a une responsabilité claire,
  mais le contenu évolue à chaque session significative.
- **Actionnable.** Pas de doc théorique : si une info n'aide pas Claude
  (ou moi) à prendre une décision, elle n'a pas sa place ici.
