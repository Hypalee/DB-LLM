# WORKFLOW — Maintenir `claude-config` à jour

> **Note 2026-04-26 — Document partiellement historique.** Ce fichier
> a été écrit quand DB-LLM avait vocation de "cerveau global" importé
> dans mes projets via submodule. Suite au découplage <projet> ↔ DB-LLM
> (cf. `memory/decisions.md`), une partie du contenu (rituels
> post-session liés à `projects/<nom>.md`, fin de phase projet) ne
> s'applique plus dans ce repo — le suivi d'état des projets vit
> désormais dans le repo de chaque projet.
>
> Les sections **§1 Conventions de commit**, **§4 Automatisation
> possible**, **§5 Faut-il un vrai RAG** restent applicables à DB-LLM
> tel que recentré (labo d'apprentissage IA). Les sections **§2** et
> **§3** sont conservées comme trace du workflow envisagé à
> l'origine, et restent utilisables si je redémarre un pattern
> multi-repos.

Ce repo n'a de valeur que s'il reflète la réalité. Ce fichier décrit
comment l'entretenir sans que ça devienne une corvée.

## 1. Conventions de commit (sur ce repo)

Même format que pour mes projets code (cf. `CLAUDE.md` §2 "Git") :

- `feat(skill|playbook): ajoute skill <nom>`
- `docs(memory): ajoute décision <titre>`
- `docs(gotchas): piège <titre>`
- `chore(projects): mise à jour état <projet> phase 2`
- `refactor: ...` (réorganisation de structure)

Scopes utiles ici : `skill`, `playbook`, `memory`, `gotchas`,
`decisions`, `lessons`, `projects`, `<projet>`, `global`.

## 2. Rituel post-session

À la fin d'une session Claude significative (≥ 30 min de vrai
travail), **5 minutes** pour mettre à jour ce repo :

1. **Décision architecturale prise ?** → ajouter à
   `memory/decisions.md`.
2. **Piège découvert ?** → ajouter à `memory/gotchas.md` et, si
   spécifique à un projet, dupliquer la ligne dans
   `projects/<nom>.md` section "Pièges".
3. **État d'un projet a changé ?** → mettre à jour `projects/<nom>.md`
   (phase, variables env, roadmap).
4. **Leçon plus générale** émergente → `memory/lessons.md`.
5. Commit groupé : `chore(memory): session YYYY-MM-DD — <topic>`.

Si rien à noter → ne rien noter, c'est OK.

## 3. Rituel fin de phase projet

Quand une phase d'un projet se termine (ex: <projet> Phase 1 → Phase 2) :

- [ ] Mettre à jour `projects/<nom>.md` : section "Phase actuelle" et
      "Roadmap court terme".
- [ ] Relire les "Pièges spécifiques" : retirer ceux qui ne
      s'appliquent plus, reformuler ceux qui ont évolué.
- [ ] Ajouter une entrée décision si la phase a apporté des choix
      structurants.

## 4. Automatisation possible (plus tard)

- **Hook post-session** : un script qui, à la sortie de Claude Code,
  demande "quelque chose à ajouter dans memory/ ?". Pas prioritaire.
- **Script `bin/new-project.sh`** : crée l'arborescence
  `projects/<nom>.md` depuis le template.
- **Lint** : vérifier que chaque projet listé dans `CLAUDE.md` a bien
  son fichier dans `projects/`.

## 5. Faut-il un vrai RAG vectoriel ?

### Recommandation : **non, pas maintenant.**

### Pourquoi

- **Volume** : tant que `claude-config` tient en quelques dizaines de
  fichiers Markdown (< 100k tokens), Claude ingère tout directement via
  les imports `@file`. Pas besoin de retrieval.
- **Coût/bénéfice** : un RAG demande infra (DB vectorielle, pipeline
  d'embeddings, re-indexation), ce qui est une distraction pour un
  usage solo.
- **Précision** : un Markdown bien structuré avec des titres clairs et
  des imports ciblés est **plus déterministe** qu'un retrieval
  sémantique. Tu sais exactement ce que Claude lit.
- **Sémantique "approximative" = piège** : sur un sujet niche (ex:
  piège 2FA Better Auth), un RAG peut rater la note exacte à cause
  d'une similarité faible. Un import explicite ne rate jamais.

### Quand ça deviendrait pertinent

Un vrai RAG vectoriel aurait du sens si :

1. **Volume > 500k tokens** de notes cumulées (contexte plein même
   avec gros modèle).
2. Besoin de **recherche transversale** non structurable en arbre
   (ex: "toutes les sessions où j'ai parlé de rate limiting", peu
   importe le projet ou la date).
3. **Multiples utilisateurs/agents** qui ne partagent pas le même
   mental model de la structure.

### Alternative intermédiaire si le volume grossit

Avant de sortir l'artillerie vectorielle :

1. **Index textuel structuré** : un fichier `INDEX.md` qui liste les
   entrées par tag (`#auth`, `#db`, `#vercel`...) avec pointeurs vers
   les fichiers. Claude le charge, puis ouvre les fichiers pertinents.
2. **Recherche `grep`** via un skill dédié. Sur 50 fichiers
   Markdown, `rg "2FA" claude-config/` est plus rapide et plus exact
   qu'un embedding.
3. **Split par thème** : si `gotchas.md` devient énorme, le splitter
   (`gotchas/auth.md`, `gotchas/db.md`) reste du Markdown pur et
   scale bien.

### Conclusion

Pour mon usage solo actuel, **le Markdown bien structuré gagne sur
tous les axes** : coût, précision, maintenance, compréhension. Le RAG
vectoriel est une optimisation prématurée tant que je n'ai pas un
volume de notes qui dépasse ce que Claude peut ingérer en une fois
(plusieurs centaines de milliers de tokens).

Réévaluer **dans 6 mois ou à 3 projets actifs avec mémoire riche**.
