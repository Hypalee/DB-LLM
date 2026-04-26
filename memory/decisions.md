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
  submodule. RAG évalué mais non retenu à ce stade.
- **Conséquences** : un seul endroit à maintenir, contexte partagé
  entre projets, facilité à onboarder un nouveau projet.
- **Statut** : décision **revue le 2026-04-26** — voir entrée
  "Découplage <projet> ↔ DB-LLM" plus bas. Le pattern submodule a été
  abandonné pour <projet>. La doc associée (`INTEGRATION.md`,
  `WORKFLOW.md`, chapitres `learning/`) est conservée comme trace
  pédagogique du pattern, pas comme prescription courante.

---

### 2026-04-26 — Découplage <projet> ↔ DB-LLM
- **Contexte** : <projet> a son propre cycle de release (bêta dans 6
  semaines), Hypalee est solo. L'architecture initiale (claude-config
  importé dans <projet> via submodule + `@imports`) a montré une friction
  réelle (bumps de submodule, doublonnage de contexte) sans bénéfice
  tangible tant qu'il n'y a qu'un seul projet consommateur.
- **Options considérées** :
  1. Garder le couplage submodule, accepter la friction.
  2. Découpler les deux repos. <projet> devient auto-portant, DB-LLM
     devient un labo d'apprentissage IA personnel pur.
  3. Mutualisation différée (réouvrir le sujet quand un 2e projet
     existe et que la duplication réelle pèse).
- **Décision** : option 2. Découplage acté côté <projet> dans la PR
  Hypalee/<projet>#47. Côté DB-LLM, ménage textuel à faire (cette
  session) en préservant la trace pédagogique du pattern abandonné.
- **Conséquences** :
  - <projet> n'a plus de submodule `claude-config/`. Son `CLAUDE.md` est
    auto-portant.
  - DB-LLM n'indexe plus les projets externes (suppression du tableau
    "Projets actifs" dans `CLAUDE.md` global, suppression de
    `projects/<projet>.md`).
  - Les chapitres `learning/` et `INTEGRATION.md` / `WORKFLOW.md` qui
    décrivent le pattern submodule + `@import` sont **conservés** mais
    encadrés comme "pattern documenté, abandonné le 2026-04-26 pour
    <projet> — réévaluer si un 2e projet émerge".
  - Vocation de DB-LLM clarifiée : labo d'apprentissage IA personnel
    (chapitres learning, doc MCP, expérimentations). Plus de rôle de
    "cerveau partagé".
- **Réversibilité** : élevée. Le pattern reste documenté ; si un 2e
  projet apparaît et qu'une duplication réelle pèse, on peut
  ressusciter le submodule.
