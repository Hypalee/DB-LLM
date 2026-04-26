# DB-LLM

> Labo d'apprentissage IA personnel : chapitres `learning/` sur
> Claude Code / MCP / hooks / agents, doc de mes MCP configurés,
> mémoire (décisions, leçons), expérimentations.
>
> Ce repo n'est **pas** importé dans mes projets de prod (cf.
> `memory/decisions.md` → "2026-04-26 — Découplage"). Chaque projet
> de prod a son `CLAUDE.md` auto-portant.

## Structure

```
DB-LLM/
├── CLAUDE.md           → Profil dev, stack perso, conventions
├── learning/           → Journal d'apprentissage IA (chapitres)
├── mcp/                → Doc des MCP configurés (Neon, Vercel, Resend)
├── skills/             → Skills Claude Code réutilisables (notes)
├── playbooks/          → Procédures step-by-step
├── memory/             → Décisions, gotchas IA/Claude Code, leçons
├── INTEGRATION.md      → (historique) Pattern submodule abandonné
└── WORKFLOW.md         → (partiel historique) Conventions de maintenance
```

## Vocation

- **Apprendre** l'écosystème Claude Code en profondeur, en formalisant
  ce qui est compris et en gardant trace.
- **Documenter** les MCP utilisés et les conventions associées.
- **Capturer** les décisions et leçons méta-IA (workflow, agents,
  patterns) dans `memory/`.
- **Expérimenter** des hooks, des skills, des configs.

## Principes

- **Markdown d'abord.** Pas de RAG vectoriel pour l'instant (cf.
  `WORKFLOW.md` §5).
- **Auto-portant.** Aucune dépendance externe : tout ce qui est dans
  ce repo est lisible et utilisable seul.
- **Honnête sur l'historique.** Les patterns abandonnés sont
  conservés et encadrés, pas effacés.
