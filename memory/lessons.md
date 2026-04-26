# Leçons

Leçons générales, pas liées à un bug ponctuel. Méta-règles, patterns,
tendances observées dans ma façon de travailler.

---

### Préférer supprimer plutôt qu'ajouter
Quand je me surprends à ajouter une couche d'abstraction ou un flag
pour "supporter les deux cas", c'est presque toujours le signe qu'il
faut au contraire supprimer l'ancien chemin. Le code qui n'existe pas
n'a jamais de bug.

---

### Tester l'UI dans un navigateur, vraiment
Un changement UI qui compile, passe TypeScript, passe les tests, peut
toujours être cassé visuellement ou comportementalement. Si je ne peux
pas tester (ex: pas d'accès navigateur en CLI), **le dire
explicitement** plutôt que marquer comme fait.

---

### Les commits en français forcent à expliquer le "pourquoi"
Écrire `fix(auth): corrige la double redirection après login` oblige à
identifier précisément ce qui se passait. Un `fix: bug` en anglais est
trop facile, trop vague.

---

### Une session = un objectif
Quand je dérive vers 2-3 tâches en parallèle dans la même session
Claude, je finis avec un diff mal découpé et des commits fourre-tout.
Mieux vaut finir une chose, commit, puis ouvrir une nouvelle session.

---

### Le `memory/` vaut par sa fraîcheur
Une entrée écrite 3 jours après le bug est déjà moins précise qu'une
entrée écrite le jour même. Prendre l'habitude de noter **pendant** la
session, pas après.

---

### Objectif d'apprentissage : devenir autonome sur l'écosystème IA
Se spécialiser dans l'usage avancé de Claude Code et des LLMs : skills,
workflows, hooks, multi-agent, API Anthropic. Je suis débutant mais
motivé. Claude doit m'expliquer les concepts au fur et à mesure, avec
le vocabulaire exact, sans survol.

Direction à moyen terme :
1. Maîtriser settings.json / hooks / agents / skills de Claude Code.
2. Apprendre à écrire des prompts système pour agents spécialisés.
3. Construire avec l'API Anthropic (prompt caching, tool use, batch).

---

### Préférence device : mobile (transports matin/soir)
J'utilise Claude Code sur téléphone dans les transports. Sur mobile, le
sélecteur de modèle n'est pas accessible quand je reprends une session.
→ `model: "claude-opus-4-7"` posé globalement dans `~/.claude/settings.json`
pour que les **nouvelles sessions** démarrent toujours sur Opus 4.7.

Limite connue : le modèle des sessions déjà ouvertes n'est pas réécrit
par cette config. Si une session reprend sur un autre modèle, ouvrir
une nouvelle session est le plus simple.

---

### Mode critique attendu de Claude
Ne pas être complaisant. Si une demande paraît irréaliste, mal
calibrée ou mal priorisée, le dire. Proposer une alternative motivée.
Contredire quand il faut. L'objectif est d'apprendre, pas de se faire
flatter.

---

### Workflow mobile-first = submodule, pas symlink
Correction d'une recommandation initiale. Le symlink ne marche que
pour un workflow 100% desktop (local filesystem persistant). Pour un
usage mobile / Claude Code web, la sandbox est éphémère, donc le
symlink n'a rien à pointer.

→ **Submodule git** est la bonne solution. Chaque projet déclare le
repo de contexte partagé comme submodule, la sandbox web clone les
deux ensemble, les `@imports` fonctionnent.

> **Note 2026-04-26** — Cette leçon générale reste vraie : si je
> redémarre un pattern multi-repos avec un repo de contexte partagé,
> c'est bien le submodule (pas le symlink) qui marche sur mobile/web.
> En revanche, **la prescription concrète "claude-config en submodule
> dans Brain" a été abandonnée le 2026-04-26** (cf.
> `memory/decisions.md` → "Découplage Brain ↔ DB-LLM"). Le pattern
> reste documenté dans `INTEGRATION.md` à titre pédagogique.

---

### Contexte pro : MSP 4 personnes, 30 clients
Travail parallèle dans une MSP (Managed Service Provider) avec 4
personnes et ~30 clients. Stack Claude Code entreprise avec plusieurs
MCP connectés (Autotask pour ticketing, entre autres).

Opportunités identifiées pour l'équipe :
- **Hooks** : pas encore utilisés, potentiel énorme (lint, audit, log
  commandes, check avant push).
- **Multi-agent** : pattern routeur (pas rephrase) pour dispatcher
  prompts vers workers spécialisés (Autotask, Azure/M365, etc.).
- **Skills par workflow récurrent** : audit tenant, onboarding client,
  clôture ticket.

Avant tout ça : commencer par muscler le `CLAUDE.md` du repo
entreprise avec les conventions MSP et les pièges clients. 80% du gain
pour 10% du travail.

---

### Pattern anti-recommandé : orchestrateur qui réécrit les prompts
Raison du rejet : dérive d'intention (téléphone arabe), double coût
et latence, incitation à mal prompter, boîte noire non déterministe.

Préférer :
- **Routeur** : classifie et dispatche sans réécrire.
- **Planner/decomposer** : découpe une tâche complexe en sous-tâches.
- **Clarifier** : demande une précision seulement si ambigu.

Le "prompt critique" comme **outil pédagogique à la demande** (skill
`/prompt-critique`) est OK. Le "prompt auto-amélioré" **en production
par défaut** ne l'est pas.
