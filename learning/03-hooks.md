# Chapitre 03 — Hooks Claude Code en pratique

> Troisième chapitre du journal. Concept des hooks, événements, flux
> de données, puis trois cas pratiques **réellement implémentés** dans
> ce repo : rappel git à la fin du tour, blocage des push destructifs,
> état git au démarrage de session. Debugging et sécurité à la fin.
>
> Destiné à être relu à froid, partageable.

## Table des matières

1. [Rappel : qu'est-ce qu'un hook](#1-rappel--quest-ce-quun-hook)
2. [Les événements en détail](#2-les-événements-en-détail)
3. [Anatomie d'un hook dans settings.json](#3-anatomie-dun-hook-dans-settingsjson)
4. [Le flux de données : stdin, stdout, codes de sortie](#4-le-flux-de-données--stdin-stdout-codes-de-sortie)
5. [Cas pratique #1 — Stop hook : rappel git](#5-cas-pratique-1--stop-hook--rappel-git)
6. [Cas pratique #2 — PreToolUse : bloquer un push destructif](#6-cas-pratique-2--pretooluse--bloquer-un-push-destructif)
7. [Cas pratique #3 — SessionStart : état git au démarrage](#7-cas-pratique-3--sessionstart--état-git-au-démarrage)
8. [Debugging : mon hook ne fait rien](#8-debugging--mon-hook-ne-fait-rien)
9. [Sécurité : un hook est du shell exécutable](#9-sécurité--un-hook-est-du-shell-exécutable)
10. [À retenir](#10-à-retenir)

---

## 1. Rappel : qu'est-ce qu'un hook

Un **hook** est un **script shell** (ou, plus rarement, un prompt
LLM ou un sous-agent) que Claude Code exécute **automatiquement** à
un événement précis de son cycle de vie.

Différence clé avec la mémoire :

- `CLAUDE.md` et ses imports = ce que Claude doit **savoir**.
- Hook = ce qui doit **se passer automatiquement** quand X arrive.

Les hooks transforment des **disciplines** (« il faut toujours
committer avant de fermer ») en **garanties** (« l'environnement me
le rappelle, je n'ai pas à y penser »).

### Exemples d'usages typiques

- **Auto-format** le code après chaque édition (prettier, black…).
- **Bloquer** des commandes dangereuses (rm -rf /, git push --force
  sur main).
- **Logger** toutes les commandes bash exécutées.
- **Rappeler** de committer à la fin d'un tour.
- **Injecter du contexte frais** au démarrage de session.

---

## 2. Les événements en détail

Claude Code expose de nombreux événements. Voici les plus utiles,
avec leur cas d'usage et leur payload principal.

| Événement | Quand ça se déclenche | Matcher utile | Cas d'usage typique |
|---|---|---|---|
| `PreToolUse` | Avant l'exécution d'un outil | Nom de l'outil (`Bash`, `Write`, `Edit`…) | Bloquer ou modifier un appel risqué |
| `PostToolUse` | Après l'exécution réussie d'un outil | Nom de l'outil | Formater, linter, logger |
| `PostToolUseFailure` | Après l'échec d'un outil | Nom de l'outil | Analyser les erreurs, retry |
| `UserPromptSubmit` | Quand tu envoies un prompt | — | Logger, enrichir le prompt |
| `SessionStart` | Au démarrage d'une session | — | Injecter du contexte frais |
| `Stop` | Quand Claude finit un tour | — | Rappels (commit, tests) |
| `PreCompact` | Avant compression du contexte | `manual` ou `auto` | Sauvegarder info critique |
| `PostCompact` | Après compression du contexte | `manual` ou `auto` | Réinjecter ce qui a sauté |
| `Notification` | Sur notification système | Type de notif | Alertes externes |

### Ce qu'il faut comprendre

- **Le matcher filtre** quand un événement a plusieurs déclencheurs
  possibles. Pour `PreToolUse`, il matche le nom de l'outil. Un
  matcher vide (`""`) veut dire "tous".
- **Plusieurs hooks peuvent être chaînés** sur le même événement :
  ils s'exécutent dans l'ordre déclaré.
- **Un hook qui échoue** (exit code ≠ 0, selon le cas) peut bloquer
  l'action ou simplement logger.

---

## 3. Anatomie d'un hook dans settings.json

Un hook est déclaré dans `~/.claude/settings.json` (global) ou
`.claude/settings.json` (projet). Structure :

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command>",
            "timeout": 60,
            "statusMessage": "Vérification…"
          }
        ]
      }
    ]
  }
}
```

### Champs importants

- **`matcher`** : pour les événements d'outil, c'est le nom d'outil
  (ou une alternance comme `"Write|Edit"`). Pour `Stop`,
  `SessionStart`, etc., souvent `""`.
- **`type`** : le plus courant est `"command"` (shell). Existent
  aussi `"prompt"` (LLM) et `"agent"` (sous-agent).
- **`command`** : la commande shell. Peut être un inline, un script,
  un `bash path/to/script.sh`.
- **`timeout`** : en secondes, défaut ~60. Au-delà, le hook est
  tué.
- **`statusMessage`** : ce que tu vois dans l'UI pendant que le
  hook tourne.

### Où stocker les scripts

Convention que j'applique dans ce repo :

- `.claude/settings.json` : config des hooks.
- `.claude/hooks/<nom>.sh` : le code du hook, un fichier par hook,
  exécutable (`chmod +x`), auto-documenté en tête.

Avantages :
- Chaque hook est reviewable dans git (diff lisible).
- Tu peux tester un hook isolément en ligne de commande.
- Pas de blocs de shell géants dans le JSON.

---

## 4. Le flux de données : stdin, stdout, codes de sortie

### Entrée : JSON sur stdin

Claude Code envoie au hook un objet JSON décrivant l'événement.
Structure :

```json
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "old_string": "...",
    "new_string": "..."
  },
  "tool_response": {
    "success": true
  }
}
```

Le hook lit ce JSON sur stdin (ex: `cat` ou `jq -r '.champ'`) et
extrait ce dont il a besoin.

### Sortie : JSON sur stdout (facultatif)

Le hook peut retourner un JSON pour **communiquer avec l'interface**
ou **modifier le comportement**. Structure courante :

```json
{
  "systemMessage": "Texte affiché à l'utilisateur",
  "continue": true,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "…",
    "additionalContext": "Texte injecté dans le contexte modèle"
  }
}
```

Champs clés :

- **`systemMessage`** : bandeau affiché à l'utilisateur dans l'UI.
- **`hookSpecificOutput.permissionDecision`** (PreToolUse seulement) :
  autoriser, refuser, ou demander l'action concernée.
- **`hookSpecificOutput.additionalContext`** : texte injecté dans
  le contexte modèle. Utile pour `SessionStart` (état git), ou
  `PostToolUse` (retour structuré).
- **`continue: false`** : arrête le flux en cours.

### Codes de sortie

- **0** : tout va bien.
- **≠ 0** : selon l'événement, bloque ou est loggé.

Règle simple : pour un hook **non bloquant** (rappel informatif),
toujours `exit 0` et communiquer via `systemMessage`. Pour un hook
**bloquant** (refus), utiliser `permissionDecision: "deny"` ou
`continue: false`.

---

## 5. Cas pratique #1 — Stop hook : rappel git

### Objectif

À la fin de chaque tour de Claude, si la working tree est sale ou
qu'il reste des commits non pushés, afficher un rappel. Silencieux
sinon.

### Pourquoi c'est utile (mobile-first)

Scénario type : tu travailles 10 min dans le métro, Claude modifie
des fichiers, tu fermes l'app. **Sans filet**, les fichiers non
committés disparaissent avec la sandbox. **Avec le hook**, tu vois
le rappel avant de fermer, tu dis « commit et push », tu ne perds
rien.

### Implémentation

`.claude/hooks/git-reminder.sh` :

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
branch=$(git branch --show-current 2>/dev/null || echo "")

unpushed=0
if [ -n "$branch" ] && git rev-parse "@{u}" >/dev/null 2>&1; then
  unpushed=$(git rev-list "@{u}..HEAD" --count 2>/dev/null || echo 0)
fi

if [ "$dirty" = "0" ] && [ "$unpushed" = "0" ]; then
  exit 0
fi

msg="Rappel git :"
if [ "$dirty" != "0" ]; then
  msg="$msg $dirty changement(s) non committé(s)"
fi
if [ "$unpushed" != "0" ]; then
  [ "$dirty" != "0" ] && msg="$msg •"
  msg="$msg $unpushed commit(s) non pushé(s) sur $branch"
fi

printf '%s' "$msg" | jq -Rsc '{systemMessage: .}'
```

Branchement dans `.claude/settings.json` :

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/git-reminder.sh" }
        ]
      }
    ]
  }
}
```

### Lecture ligne par ligne

1. `set -euo pipefail` : bash strict. Toute erreur interrompt, toute
   variable non définie plante, toute commande de pipeline qui échoue
   fait échouer la pipeline.
2. `git rev-parse --is-inside-work-tree` : check silencieux qu'on
   est bien dans un repo git. Sinon, exit 0 (hook inoffensif).
3. `git status --porcelain | wc -l` : compte les lignes de statut
   git, une par fichier modifié / ajouté / supprimé.
4. `git rev-parse "@{u}"` : vérifie que la branche a un upstream.
5. `git rev-list @{u}..HEAD --count` : nombre de commits locaux
   pas encore sur le remote.
6. Si rien à signaler, exit 0 silencieux.
7. Sinon, construit le message et l'émet en JSON via `jq -Rsc`
   (`-R` raw input, `-s` slurp tout, `-c` compact).

### Test manuel

```bash
echo '{}' | bash .claude/hooks/git-reminder.sh
# → {"systemMessage":"Rappel git : 3 changement(s) non committé(s)"}
```

---

## 6. Cas pratique #2 — PreToolUse : bloquer un push destructif

### Objectif

Empêcher toute commande `git push --force` (ou `--force-with-lease`,
ou `-f`) qui viserait `main` ou `master`. Safety net ultime : même
si Claude ou toi tape la commande par erreur, elle est refusée
avant exécution.

### Pourquoi c'est critique

Un `git push --force origin main` peut **réécrire l'historique
distant** et faire perdre du travail irrécupérable. Autant c'est
parfois légitime sur une branche perso, autant sur `main` ça ne
doit jamais arriver. Un hook qui refuse = zéro risque.

### Implémentation

`.claude/hooks/block-force-push.sh` :

```bash
#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

if printf '%s' "$cmd" | grep -qE 'git[[:space:]]+push.*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$))' && \
   printf '%s' "$cmd" | grep -qE '(main|master)'; then
  reason="Refusé : git push --force sur main/master est interdit par hook. Utilise une branche ou retire le --force."
  jq -nc --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
fi

exit 0
```

Branchement :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/block-force-push.sh" }
        ]
      }
    ]
  }
}
```

### Lecture ligne par ligne

1. `input=$(cat)` : lit tout le JSON d'entrée dans une variable.
2. `jq -r '.tool_input.command // ""'` : extrait la commande bash
   que Claude s'apprête à exécuter. `// ""` = fallback si absente.
3. Deux regex grep pour détecter :
   - `git push ... --force` (avec variantes) ;
   - et la cible contient `main` ou `master`.
4. Si matche, émet un JSON avec `permissionDecision: "deny"`. Claude
   Code refuse l'exécution et affiche la raison.
5. Sinon, exit 0 sans output : l'exécution se poursuit normalement.

### Limites connues

- La regex reste heuristique : un alias git (`git yeet`) ou une
  commande complexe avec pipes peut passer entre les mailles. Pour
  un vrai garde-fou, on pourrait :
  - parser vraiment la commande (ast bash) ;
  - ou doubler avec un pre-push hook côté git (côté serveur).
- Sur un repo où tu veux autoriser le force push sur main
  volontairement (ex: rebase d'un repo perso), il faut désactiver
  temporairement le hook.

### Tests

```bash
# Cas 1 : commande safe → pas de sortie, exit 0.
echo '{"tool_input":{"command":"git status"}}' | bash .claude/hooks/block-force-push.sh

# Cas 2 : push force main → JSON deny.
echo '{"tool_input":{"command":"git push --force origin main"}}' | \
  bash .claude/hooks/block-force-push.sh

# Cas 3 : push force feature branch → autorisé (exit 0 silencieux).
echo '{"tool_input":{"command":"git push --force origin feat/x"}}' | \
  bash .claude/hooks/block-force-push.sh
```

Les trois comportements sont attendus et vérifiés dans ce repo.

---

## 7. Cas pratique #3 — SessionStart : état git au démarrage

### Objectif

Quand tu ouvres Claude Code dans le repo, injecter dans le contexte
un résumé de l'état git : branche, dernier commit, working tree,
ahead/behind vs upstream.

### Pourquoi c'est utile

Après une nuit, un trajet, une compaction du contexte, tu perds le
fil. Re-demander « où j'en étais ? » consomme du contexte et de la
friction. Le hook te resynchronise automatiquement en une ligne.

### Implémentation

`.claude/hooks/session-status.sh` :

```bash
#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "detached")
last_commit=$(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo "aucun commit")

dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
tree_status="propre"
[ "$dirty" != "0" ] && tree_status="$dirty changement(s) non committé(s)"

ahead_behind=""
if git rev-parse "@{u}" >/dev/null 2>&1; then
  ahead=$(git rev-list "@{u}..HEAD" --count 2>/dev/null || echo 0)
  behind=$(git rev-list "HEAD..@{u}" --count 2>/dev/null || echo 0)
  if [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
    ahead_behind=" (↑$ahead ↓$behind vs upstream)"
  fi
fi

msg="📍 Session sur $branch$ahead_behind
   • Dernier commit : $last_commit
   • Working tree : $tree_status"

printf '%s' "$msg" | jq -Rsc '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: .
  }
}'
```

### Ce qui est injecté

Le champ `additionalContext` du JSON est **injecté dans le contexte
du modèle** au démarrage. Claude voit donc "📍 Session sur …"
dès son premier tour, sans que tu aies à dire quoi que ce soit.

---

## 8. Debugging : mon hook ne fait rien

Check-list si ton hook ne se déclenche pas.

### 8.1 Vérifier la syntaxe JSON

Une virgule manquante dans `settings.json` **désactive silencieusement
toute la config**.

```bash
jq . .claude/settings.json
# Si ça ne parse pas, c'est ton coupable.
```

### 8.2 Vérifier le matcher

Pour un `PreToolUse` sur Bash, le matcher doit être `"Bash"`
(exact), pas `"bash"` ou `"Shell"`.

Pour des matchers multiples : `"Write|Edit"` (alternance, pas de
virgule).

Pour tous : `""` (matcher vide).

### 8.3 Tester le hook à la main

```bash
echo '<payload>' | bash .claude/hooks/<script>.sh
echo "exit: $?"
```

Si le script plante ou ne produit rien, le hook ne fera rien en
contexte Claude Code non plus.

### 8.4 Vérifier les chemins

Quand le hook est déclenché, Claude Code est dans le `cwd` du
projet. Les chemins relatifs type `bash .claude/hooks/...` marchent.
Un chemin absolu (`/home/user/...`) peut casser entre devices ou
sandboxes.

### 8.5 Watcher de settings

Claude Code ne rescanne pas `.claude/settings.json` en continu. Si
tu as modifié le fichier **pendant une session**, ouvre `/hooks`
dans l'UI ou relance la session pour qu'il recharge.

### 8.6 Mode debug

```bash
claude --debug
```

Affiche les logs internes, dont les hooks déclenchés et leur
output.

---

## 9. Sécurité : un hook est du shell exécutable

### Principe

Un hook `"command"` est un **shell script**. Il a accès à :

- Tous les outils du système où Claude Code tourne.
- Les variables d'environnement de la session.
- Le filesystem selon les permissions de l'utilisateur courant.

**Ne jamais installer un hook d'une source douteuse** sans lire le
script.

### Règles que je m'applique

1. **Un fichier par hook** dans `.claude/hooks/` : facile à reviewer
   en diff git.
2. **Commentaire d'en-tête** qui explique quand et pourquoi le hook
   se déclenche.
3. **`set -euo pipefail`** en tête de chaque script bash : échec
   rapide sur erreur.
4. **Pas de fetch réseau** dans un hook sauf nécessité claire (un
   hook qui appelle une API à chaque tour ralentit tout).
5. **Pas de secrets en dur**. Si le hook a besoin d'une clé, la lire
   depuis l'environnement (`$RESEND_API_KEY`).
6. **Pas d'action destructive autonome**. Un hook qui `rm` ou `git
   reset` sans prompt utilisateur est une bombe à retardement.

### Permissions

Les hooks héritent des permissions du process Claude Code. Sur le
web/mobile c'est scopé par la sandbox. Sur desktop, c'est ton user
local — un hook mal écrit peut effacer ton home. Prudence.

---

## 10. À retenir

- Un hook = un script exécuté automatiquement sur un événement
  Claude Code.
- Trois événements phares pour le solo dev : **Stop** (rappels),
  **PreToolUse** (garde-fous), **SessionStart** (contexte).
- Format stable : JSON sur stdin, JSON (facultatif) sur stdout,
  code de sortie 0 si pas bloquant.
- Convention : un fichier `.sh` par hook dans `.claude/hooks/`,
  déclaration dans `.claude/settings.json`.
- Tester à la main avant de câbler (`echo '{...}' | bash ...`).
- **Sécurité** : un hook est du code shell, à treater comme tel.
  Source connue, review, pas de fetch réseau gratuit, pas
  d'action destructive autonome.

Les trois hooks de ce chapitre sont **réellement installés** dans
ce repo (`.claude/hooks/`). Tu peux les lire, les modifier, les
désactiver (en retirant du `.claude/settings.json`) à ta guise.