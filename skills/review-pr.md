# review-pr

Revue de PR selon mes standards (voir `CLAUDE.md` §2).

## Quand l'utiliser
- "Revois cette PR"
- "Dis-moi si c'est mergeable"
- Avant chaque merge sur `main`

## Inputs attendus
- Numéro ou URL de la PR
- Optionnel : focus particulier (sécurité, perf, UX…)

## Procédure

### 1. Lire avant de juger
- Titre et description : l'intention est-elle claire ?
- Diff complet lu end-to-end, pas seulement survolé.
- Repérer le "pourquoi" : quelle issue/besoin ?

### 2. Check-list systématique

**TypeScript**
- [ ] Aucun `any`, `as any`, `@ts-ignore`.
- [ ] Types aux frontières (API, DB, props publiques).

**Architecture**
- [ ] Pas d'abstraction prématurée. Trois lignes dupliquées OK,
      helper bancal pas OK.
- [ ] Pas de feature flag ou shim inutile.
- [ ] Un commit = une intention.

**Sécurité**
- [ ] Aucun secret committé (`.env`, clé, token).
- [ ] Validation des inputs utilisateur (zod ou équivalent).
- [ ] SQL paramétré, pas de concat.
- [ ] Auth vérifiée sur chaque route sensible.

**DB**
- [ ] Migrations versionnées et idempotentes.
- [ ] Pas de `DROP` sur table partagée sans backup plan.
- [ ] Index sur les colonnes filtrées fréquemment.

**UI**
- [ ] Textes en français, identifiants en anglais.
- [ ] Tailwind v4 dans JSX (pas de CSS maison sauf exception).
- [ ] Labels / focus / contrastes OK.

**Tests**
- [ ] Les tests passent en CI.
- [ ] Si UI touchée : testée dans un navigateur ET c'est mentionné dans
      la PR. Sinon dire explicitement "non testé UI".

**Hygiène**
- [ ] Pas de `console.log` oubliés.
- [ ] Pas de TODO sans ticket/contexte.
- [ ] Commits en français, format `type(scope): ...`.

### 3. Feedback

Classer les remarques en 3 niveaux :
- **Bloquant** : doit être corrigé avant merge.
- **Important** : à corriger, mais peut partir en follow-up si justifié.
- **Nit** : suggestion, pas bloquante.

Formuler en disant ce qui ne va pas **et pourquoi**, pas juste "change
ça". Proposer un fix concret quand possible.

### 4. Décision

- Si aucun bloquant → **Approuver**.
- Sinon → **Request changes** avec la liste priorisée.

## Pièges à éviter

- Ne pas pinailler pour pinailler : si le code atteint le but proprement
  et respecte les conventions, approuver.
- Ne pas laisser passer "juste cette fois" sur TS strict ou sur un
  workaround — la dette technique se paie toujours.
- Vérifier le **contexte du projet** (`projects/<nom>.md`) avant de
  pointer une "erreur" qui est en fait une contrainte connue.

## Sortie attendue
- Revue structurée par niveau de sévérité, actionnable.
- Décision claire : approve / request changes / comment.
