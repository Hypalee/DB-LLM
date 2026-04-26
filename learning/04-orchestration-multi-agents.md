# 04 — Orchestration multi-agents Claude

## Table des matières

1. [Le problème : trois Claude, un humain au milieu](#1-le-problème--trois-claude-un-humain-au-milieu)
2. [Cartographie des trois agents](#2-cartographie-des-trois-agents)
3. [Ce qui existe nativement aujourd'hui](#3-ce-qui-existe-nativement-aujourdhui)
4. [Le pattern "documentation comme bus de communication"](#4-le-pattern-documentation-comme-bus-de-communication)
5. [Les handoffs concrets entre agents](#5-les-handoffs-concrets-entre-agents)
6. [Anti-patterns observés](#6-anti-patterns-observés)
7. [Pistes d'évolution](#7-pistes-dévolution)
8. [À retenir](#8-à-retenir)

---

## 1. Le problème : trois Claude, un humain au milieu

Quand on travaille sérieusement avec l'écosystème Anthropic, on se retrouve rapidement à utiliser plusieurs agents Claude spécialisés :

- **Claude.ai** (interface chat) pour la stratégie, la réflexion produit, la planification, les retours critiques
- **Claude Code** pour l'implémentation technique (lecture/écriture de code, tests, refactos, accès aux MCP)
- **Claude Design** (depuis novembre 2025, Anthropic Labs) pour l'exploration UI et le prototypage visuel

Chaque agent a son propre contexte, sa propre mémoire, ses propres outils. Et entre les trois, **il n'existe aujourd'hui aucune orchestration native**. L'humain devient le bus de communication : il copie-colle des décisions de Claude.ai vers Claude Code, exporte des designs de Claude Design vers Claude Code, ramène les résultats vers Claude.ai pour validation, etc.

Ce chapitre documente :
- Pourquoi ce problème existe
- Les solutions natives partielles déjà en place
- Le pattern documentaire qui fonctionne aujourd'hui pour limiter le travail manuel
- Les pistes d'évolution à surveiller

> **À retenir** — L'humain reste le chef d'orchestre. Aucun produit Anthropic ne fournit aujourd'hui une orchestration unifiée des trois agents. La bonne nouvelle : on peut limiter ce travail manuel à 5-10 minutes par session avec une discipline documentaire propre.

---

## 2. Cartographie des trois agents

### 2.1 Claude.ai (claude.ai)

**Rôle naturel** : orchestrateur, chef de projet, sparring partner stratégique.

**Forces** :
- Contexte conversationnel long, mémoire utilisateur Anthropic partagée entre sessions
- Bon pour la réflexion ouverte, le challenge d'idées, la critique constructive
- Accès aux artifacts (rendu interactif de code, prototypes, documents)
- Peut générer des fichiers complets à coller dans le repo

**Limites** :
- N'a pas accès direct au système de fichiers de l'utilisateur
- Ne peut pas exécuter de code dans le repo (sauf via artifacts isolés en sandbox)
- Ne peut pas committer ni pusher
- Ne voit pas l'état réel du code, uniquement ce qu'on lui montre

### 2.2 Claude Code (CLI ou GUI)

**Rôle naturel** : développeur exécutant, implémenteur.

**Forces** :
- Accès complet au système de fichiers du projet
- Peut exécuter des commandes, des tests, des migrations
- Peut interagir avec Git, GitHub CLI, MCP servers (Neon, Vercel, Resend, etc.)
- Lit automatiquement le `CLAUDE.md` à chaque session

**Limites** :
- Pas de mémoire entre sessions (chaque session repart de zéro, sauf via `CLAUDE.md` et `HANDOFF.md`)
- Pas conscient des conversations sur Claude.ai
- Pas conscient des designs créés sur Claude Design (sauf via handoff bundle)
- Tendance à se perdre sur des projets très larges sans contexte structuré

### 2.3 Claude Design (claude.ai/design)

**Rôle naturel** : designer UI, prototypeur visuel.

**Forces** :
- Génère des interfaces depuis du texte
- Peut lire un repo GitHub pour respecter le design system existant
- Sliders et commentaires inline pour itérer rapidement
- Handoff bundle natif vers Claude Code

**Limites** :
- En research preview, encore instable (commentaires inline qui disparaissent, problèmes en compact view)
- Pas de mémoire conversationnelle longue
- Le handoff vers Claude Code est unidirectionnel
- Pas conscient des conversations Claude.ai

### 2.4 Schéma simplifié

```
                    ┌─────────────────┐
                    │   Claude.ai     │
                    │  (stratégie)    │
                    └────────┬────────┘
                             │
                       (humain)
                             │
                ┌────────────┴────────────┐
                │                         │
        ┌───────▼────────┐       ┌────────▼─────────┐
        │  Claude Code   │◄──────┤ Claude Design    │
        │ (implémenteur) │handoff│  (designer)      │
        └────────┬───────┘       └──────────────────┘
                 │
        ┌────────▼───────┐
        │    Le repo     │
        │  (code + docs) │
        └────────────────┘
```

L'humain est en haut, le repo en bas, et les agents au milieu. Tout converge vers le repo.

---

## 3. Ce qui existe nativement aujourd'hui

### 3.1 La mémoire utilisateur Claude.ai

Anthropic a déployé un système de mémoire pour Claude.ai qui retient des informations entre les sessions. Tu peux explicitement demander à Claude.ai de mémoriser une décision, une préférence, un contexte projet.

**Limite** : cette mémoire ne se synchronise pas avec Claude Code ou Claude Design. C'est de la mémoire pour l'agent Claude.ai uniquement.

### 3.2 Le `CLAUDE.md`

C'est le fichier de contexte permanent que Claude Code lit automatiquement à chaque nouvelle session sur un projet. Il joue le rôle de "mémoire externe" pour Claude Code.

C'est aussi le fichier le plus puissant pour transmettre du contexte d'un agent à l'autre :
- Tu peux le **partager à Claude.ai** dans une nouvelle conversation pour qu'il s'aligne sur ton projet
- **Claude Design le lira** automatiquement quand tu connectes ton repo

C'est le **point de convergence documentaire le plus important** de ton écosystème.

### 3.3 Le handoff Claude Design → Claude Code

Quand tu finalises un design dans Claude Design, tu peux générer un "handoff bundle" qui contient :
- Le code des composants
- Les design tokens utilisés
- Les instructions d'implémentation

Tu transmets ce bundle à Claude Code en un clic. C'est **le seul vrai pont automatique** qui existe aujourd'hui entre deux agents Claude.

### 3.4 Les MCP servers

Les MCP (Model Context Protocol) servers permettent à n'importe quel agent Claude (Code, Design, ou via API) de partager des outils communs : accès à une DB, à une API, à un système de fichiers, etc.

Quand tu configures un MCP au scope user (dans ton profil Claude Code), il est disponible dans tous tes projets. Quand un MCP est configuré au scope projet, il l'est uniquement dans ce projet.

> **Piste à creuser** — Tu pourrais créer un MCP custom qui servirait de "tableau noir partagé" entre tes agents (lecture/écriture d'un état projet centralisé). C'est techniquement faisable mais demande du dev. Voir section 7 pour les pistes d'évolution.

---

## 4. Le pattern "documentation comme bus de communication"

> **Note 2026-04-26** — La structure décrite plus bas (§4.1) repose sur le pattern `claude-config` importé dans Brain via submodule. Ce pattern a été abandonné le 2026-04-26 (cf. `memory/decisions.md` → "Découplage Brain ↔ DB-LLM") : Brain est désormais auto-portant avec son propre `CLAUDE.md`, et DB-LLM n'indexe plus les projets externes. **L'idée centrale du chapitre — faire du repo le bus de communication entre agents — reste valide.** Le détail du "où vit quoi" change : les fichiers `decisions.md`, `gotchas.md`, fiche produit vivent désormais **dans le repo de chaque projet**, pas dans un repo de config partagé.

Faute d'orchestration native, la solution qui fonctionne aujourd'hui est de faire **du repo lui-même le bus de communication**. Chaque agent lit et écrit dans des fichiers documentaires conventionnés.

### 4.1 Structure recommandée pour un setup multi-projets

Pour un setup avec un repo `claude-config` global et un projet `brain` :

```
claude-config/                       # Repo de configuration partagé
├── CLAUDE.md                        # Profil dev, stack, conventions universelles
├── projects/
│   └── brain.md                     # Contexte produit Brain (cible, promesse, archi)
├── memory/
│   ├── decisions.md                 # Log des décisions archi (datées)
│   └── gotchas.md                   # Pièges découverts au fil de l'eau
├── mcp/
│   └── neon.md, vercel.md, ...      # Documentation des MCP configurés
└── learning/
    └── 01-fondamentaux.md, ...      # Chapitres d'apprentissage

brain/                               # Le repo du projet
├── CLAUDE.md                        # Minimal : @import claude-config + notes ponctuelles
├── claude-config/                   # Submodule Git pointant vers claude-config
├── HANDOFF.md                       # Journal de fin de session par Claude Code
├── BACKLOG.md                       # Audit technique du projet
├── ROADMAP_ADJUSTMENTS.md           # Ajustements de la roadmap initiale
├── BACKLOG_FUTUR.md                 # Idées hors scope actuel
└── src/                             # Le code
```

### 4.2 Comment chaque agent utilise cette structure

**Claude.ai** : tu lui colles le contenu de `claude-config/CLAUDE.md` + `claude-config/projects/brain.md` au début d'une session significative. Il a alors le contexte produit complet, sans avoir à tout réexpliquer.

**Claude Code** : il lit automatiquement le `CLAUDE.md` à la racine du repo Brain à chaque session. Ce `CLAUDE.md` contient `@claude-config/CLAUDE.md` et `@claude-config/projects/brain.md`, ce qui résout l'import via le submodule. Il a donc accès à tout le contexte sans intervention.

**Claude Design** : quand tu connectes le repo GitHub, il lit l'arborescence et notamment le `CLAUDE.md`. Il comprend ainsi le design system attendu et les conventions du projet.

### 4.3 Le rôle du `HANDOFF.md`

Le fichier `HANDOFF.md` à la racine du projet sert de **journal de fin de session** pour Claude Code. À la fin de chaque session significative, Claude Code y ajoute une entrée :

```md
## 2026-04-25 14:30 — Session audit initial Brain

**Fait** :
- Audit complet du code (frontend, backend, DB, auth)
- Création du BACKLOG.md avec priorités P1/P2/P3
- 10 questions stratégiques posées et résolues

**Reste** :
- Création de la branche Neon dev (bloqué côté humain)
- Implémentation du fallback Resend dev (issue S1·Mar·bonus)
- Démarrage S1·Mar attendu

**Pièges rencontrés** :
- Le from Resend est hardcodé à noreply@brain-app.app, domaine à vérifier
- Pas de système de migration DB en place

**Prochaine session** :
- Attendre validation de la connection string Neon dev
- Démarrer par la migration DB (S1·Mer)
```

Ce fichier complète la mémoire externe en gardant trace de la **continuité temporelle** des sessions.

### 4.4 Les fichiers `memory/` de claude-config

`memory/decisions.md` et `memory/gotchas.md` capturent ce qui a une valeur **transversale** entre projets ou sur le long terme :

- **`decisions.md`** : décisions architecturales structurantes (ex: "on utilise Better Auth pour tous nos projets Next.js avec auth par email/password"). Datées, contextualisées, raisonnées.
- **`gotchas.md`** : pièges découverts qui peuvent ressurgir ailleurs (ex: "Better Auth nécessite que la migration DB soit faite avant le premier signup, sinon erreur silencieuse").

Quand un nouveau projet démarre, lire ces fichiers évite de retomber dans les mêmes pièges.

---

## 5. Les handoffs concrets entre agents

### 5.1 Claude.ai → Claude Code

**Contexte typique** : tu as eu une discussion stratégique avec Claude.ai (ex: choix d'archi, décision produit), il faut transmettre ça à Claude Code pour implémentation.

**Méthode** :

1. Demande à Claude.ai de te générer un **prompt structuré** pour Claude Code, avec : contexte, mission claire, contraintes, livrables attendus, mode de validation.
2. Demande aussi de **mettre à jour `decisions.md`** ou la fiche produit du projet (selon où vit ton contexte produit : repo dédié, ou directement dans le `CLAUDE.md` du projet de prod) si la décision est durable.
3. Tu copies-colles le prompt dans Claude Code.
4. Tu copies-colles les modifs documentaires dans claude-config.

**Exemple concret** : nous avons utilisé ce pattern dans la conversation Brain pour faire transitionner du cadrage produit (décisions sur cible, promesse, pricing, archi LLM) vers l'audit technique fait par Claude Code via les PROMPT_1, PROMPT_2 et PROMPT_3.

### 5.2 Claude Code → Claude.ai

**Contexte typique** : Claude Code a fait un audit ou implémenté quelque chose, tu veux du retour critique de Claude.ai (validation produit, challenge d'archi).

**Méthode** :

1. Claude Code te livre des fichiers concrets (`BACKLOG.md`, `ROADMAP_ADJUSTMENTS.md`, etc.).
2. Tu copies-colles le contenu dans une session Claude.ai.
3. Tu lui demandes une analyse critique.
4. Si des décisions ressortent, retour vers Claude Code via un nouveau prompt (cf. 5.1).

> **Anti-pattern** — Ne lui colle pas tout le code source à chaque retour. Travaille par incréments, partage les fichiers de doc stratégiques, pas le code applicatif (sauf si une question technique précise se pose).

### 5.3 Claude Design → Claude Code

**Contexte typique** : tu as conçu une nouvelle UI dans Claude Design, il faut l'implémenter.

**Méthode native** :

1. Dans Claude Design, finalise le design (commentaires inline, sliders, etc.).
2. Clique sur "Handoff to Claude Code".
3. Le bundle est généré : code des composants + design tokens + instructions.
4. Ouvre Claude Code, colle le bundle, demande l'implémentation dans les fichiers du projet.

C'est **le seul handoff partiellement automatisé** de l'écosystème.

### 5.4 Claude Code → Claude Design

Ce sens existe en théorie mais est plus friction-heavy. Si tu veux retravailler un design existant à partir du code :

1. Connecte le repo GitHub à Claude Design.
2. Demande-lui de lire un composant spécifique et d'en proposer une variante.
3. Itère dans Claude Design.
4. Re-handoff vers Claude Code.

En pratique, sur un projet déjà avancé, ce flux est moins courant que Design → Code.

---

## 6. Anti-patterns observés

### 6.1 Tout dupliquer entre les agents

**Erreur** : recopier manuellement le contexte produit dans Claude.ai, Claude Code, et Claude Design séparément.

**Pourquoi c'est mauvais** : tu te retrouves avec 3 versions désynchronisées du même contexte. Quand tu changes une décision quelque part, tu oublies de la propager ailleurs.

**Solution** : la fiche produit du projet est la source unique. Les agents y accèdent (directement pour Claude Code via le `CLAUDE.md` du repo, par copier-coller pour Claude.ai et Claude Design).

> **Note 2026-04-26** — La version d'origine pointait `claude-config/projects/<projet>.md` (pattern submodule abandonné le 2026-04-26). Le principe reste le même : **une seule source de vérité** pour le contexte produit, peu importe qu'elle vive dans un repo de config partagé ou dans le `CLAUDE.md` du repo de prod.

### 6.2 Tout mettre dans le `CLAUDE.md` du projet

**Erreur** : faire un `CLAUDE.md` géant à la racine du projet avec tout le contexte produit + conventions globales + stack + règles + ...

**Pourquoi c'est mauvais** : un `CLAUDE.md` géant devient illisible et coûteux en tokens à chaque tour. Conventions universelles, contexte produit, pièges spécifiques mélangés sans structure.

**Solution** : structurer le `CLAUDE.md` projet avec des sections claires (profil dev, conventions, contexte produit, pièges). Si le fichier dépasse ~300 lignes, c'est probablement le signe qu'il faut découper en plusieurs fichiers internes au repo (ex: `docs/conventions.md` importé via `@`).

> **Note 2026-04-26** — La version d'origine prescrivait de scinder entre un repo partagé (`claude-config/CLAUDE.md`) et un fichier projet (`claude-config/projects/X.md`). Pattern abandonné le 2026-04-26 au profit du `CLAUDE.md` auto-portant (cf. `memory/decisions.md`). La règle de fond — éviter le `CLAUDE.md` géant et bien structurer — reste valide.

### 6.3 Demander à Claude Code des décisions stratégiques

**Erreur** : demander à Claude Code "qu'est-ce que tu en penses, on devrait faire X ou Y ?".

**Pourquoi c'est mauvais** : Claude Code est optimisé pour l'exécution technique, pas la réflexion produit large. Il va répondre, mais avec moins de profondeur que Claude.ai sur ces sujets.

**Solution** : les décisions stratégiques se prennent avec Claude.ai (qui a un contexte conversationnel plus large), puis sont transmises à Claude Code via un prompt précis.

### 6.4 Sauter le `HANDOFF.md`

**Erreur** : finir une session Claude Code sans laisser de trace, repartir de zéro à la session suivante.

**Pourquoi c'est mauvais** : tu perds le fil temporel. La session suivante recommence à explorer le projet alors qu'une note de 5 lignes aurait suffi à transmettre la continuité.

**Solution** : à chaque fin de session significative, Claude Code écrit une entrée datée dans `HANDOFF.md`. Le prochain démarrage de session commence par lire ce fichier.

### 6.5 Multiplier les outils d'orchestration tiers

**Erreur** : ajouter des outils tiers (LangGraph, CrewAI, AutoGen, etc.) pour "orchestrer" les agents Claude.

**Pourquoi c'est mauvais (en solo, sur un produit pas encore validé)** : tu ajoutes une couche de complexité qui te bouffe ton temps de dev. Pour un side-project solo, le ROI est rarement positif.

**Solution** : reste sur le pattern documentaire jusqu'à ce qu'un vrai besoin émerge. Les outils d'orchestration sont pertinents pour des équipes ou des produits à forte composante agent autonome, pas pour piloter ton workflow de dev quotidien.

---

## 7. Pistes d'évolution

### 7.1 MCP custom comme tableau noir partagé

**Idée** : créer un MCP server qui exposerait des outils communs aux trois agents :
- `read_project_state()` : lire l'état actuel du projet (décisions récentes, sprint en cours, blockers)
- `add_decision(text)` : ajouter une décision dans `memory/decisions.md`
- `flag_gotcha(text)` : ajouter un gotcha
- `current_focus()` : retourner ce sur quoi le projet est concentré actuellement

Configuré au scope user, ce MCP serait disponible dans Claude Code et accessible aussi à Claude.ai (via API ou intégration future) et Claude Design (via repo).

**Effort estimé** : 1-2 jours pour une v0 fonctionnelle. À envisager après la bêta de Brain.

### 7.2 Webhooks GitHub → Claude.ai

**Idée** : configurer un webhook qui notifie Claude.ai quand un commit important est pushé sur Brain, avec un résumé. Claude.ai peut alors analyser et commenter de façon proactive.

**Limite actuelle** : Claude.ai n'expose pas d'API publique pour recevoir des notifications. Cette piste dépend d'évolutions chez Anthropic.

### 7.3 Outils émergents à surveiller

- **LangGraph** : framework Python pour orchestrer des workflows multi-agents. Plus pertinent pour des produits agent-first que pour un workflow de dev personnel.
- **CrewAI** : abstraction haut niveau pour des "équipes" d'agents. Idem.
- **AutoGen** : Microsoft, similaire dans l'esprit.

À surveiller mais pas à intégrer aujourd'hui.

### 7.4 Évolution probable de l'écosystème Anthropic

Anthropic itère vite. Plusieurs choses sont à surveiller dans les mois qui viennent :
- Synchronisation de la mémoire utilisateur entre Claude.ai et Claude Code
- Handoffs plus avancés entre Claude.ai et Claude Code
- Intégration plus profonde Claude Design ↔ Claude Code (édition bidirectionnelle)
- API publique permettant des intégrations custom plus riches

---

## 8. À retenir

- **L'humain reste le chef d'orchestre**. Aucune solution magique d'orchestration native n'existe aujourd'hui.
- **Le repo est ton bus de communication**. Faire converger toute la documentation dans des fichiers conventionnés (`CLAUDE.md`, `decisions.md`, `gotchas.md`, `HANDOFF.md`) est ce qui marche le mieux aujourd'hui.
- **Une source de vérité par projet**. Pour un projet auto-portant, c'est le `CLAUDE.md` à la racine du repo. Pour un setup multi-projets avec contexte commun, un repo de configuration partagé importé via `@` reste une option valide (cf. §4.1, pattern conservé en référence).
- **Spécialise les agents** : Claude.ai pour la stratégie, Claude Code pour l'exécution, Claude Design pour le visuel. Ne demande pas à un agent de jouer le rôle d'un autre.
- **Le `HANDOFF.md` est sous-estimé**. C'est le fichier qui assure la continuité temporelle entre sessions Claude Code.
- **Évite les outils d'orchestration tiers** tant qu'un vrai besoin n'émerge pas. Le coût d'apprentissage et de maintenance n'est pas rentabilisé sur un projet solo en early stage.
- **Surveille l'évolution d'Anthropic**. L'écosystème bouge vite, ce qui est vrai aujourd'hui peut être obsolète dans 6 mois.

> **À retenir transversal** — La discipline documentaire est plus rentable que la recherche d'outils magiques. 10 minutes par session pour maintenir `claude-config` à jour t'épargnera des heures de confusion et de duplication d'efforts.

---

*Chapitre rédigé en avril 2026, dans le contexte du projet Brain. À mettre à jour quand l'écosystème Anthropic évolue (Claude Design étant encore en research preview, sortie publique récente).*
