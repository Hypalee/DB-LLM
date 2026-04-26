# INTEGRATION — Utiliser `claude-config` dans un projet

> **Note 2026-04-26 — Document historique conservé à titre
> pédagogique.** Ce guide décrit le pattern submodule + symlink qui
> permettait d'importer DB-LLM dans un projet de prod (Brain) via
> `@claude-config/...` dans le `CLAUDE.md` local. **Ce pattern n'est
> plus en usage** : Brain a été découplé de DB-LLM le 2026-04-26 (PR
> Hypalee/Brain#47), et DB-LLM n'a plus vocation à être importé
> ailleurs. Décision détaillée : `memory/decisions.md` → "2026-04-26 —
> Découplage Brain ↔ DB-LLM".
>
> Le contenu en dessous reste juste : si un jour je redémarre un
> pattern multi-repos avec un repo de contexte partagé, c'est la
> bonne mécanique. Conservé pour ça, et pour la pédagogie (le pattern
> revient régulièrement dans la littérature Claude Code).

Ce guide décrit comment brancher ce repo dans un projet pour que
Claude Code y ait accès lors de chaque session.

Claude Code résout les imports `@file` dans un `CLAUDE.md` **par
rapport au CWD du projet**. Il faut donc que les fichiers de
`claude-config` soient accessibles depuis le repo du projet. Deux
stratégies utiles, **à choisir selon ton device principal** :

- **Mobile-first / Claude Code web** : option A (submodule).
- **Desktop-first / terminal local uniquement** : option B (symlink).

---

## Option A — Git submodule (recommandée pour mobile/web)

**Pourquoi c'est le bon choix si tu utilises Claude Code sur
téléphone** : les sessions web tournent dans une sandbox éphémère. Il
n'y a pas de filesystem local qui persiste, donc pas de chemin vers
lequel un symlink pourrait pointer. Le submodule se clone avec le
projet, les `@imports` fonctionnent partout.

### Ajouter le submodule à un projet existant

```bash
cd ~/code/Brain   # par exemple
git submodule add https://github.com/Hypalee/db-llm.git claude-config
git commit -m "chore: ajoute claude-config en submodule"
git push
```

### Cloner un projet qui a déjà le submodule

```bash
git clone --recursive https://github.com/Hypalee/Brain.git
# ou si déjà cloné sans --recursive :
git submodule update --init --recursive
```

### Mettre à jour claude-config dans un projet

Quand tu modifies `claude-config` (commit + push sur son repo), chaque
projet qui l'utilise doit "pointer" vers le nouveau commit :

```bash
cd ~/code/Brain/claude-config
git pull origin main
cd ..
git commit -am "chore: bump claude-config"
git push
```

### CLAUDE.md du projet

```md
@claude-config/CLAUDE.md
@claude-config/projects/brain.md

## Contexte spécifique à ce projet

(ce qui est vraiment propre au repo courant, pas déjà couvert par
les imports ci-dessus)
```

### Avantages
- Marche sur tous les devices (mobile/web/desktop).
- Version explicite de `claude-config` liée à chaque projet (le
  submodule pointe vers un commit précis).
- Fonctionne en CI sans config spéciale.

### Limites
- Petite friction : penser à `git submodule update` et committer les
  bumps quand tu modifies `claude-config`. Avec l'habitude, c'est
  négligeable.

---

## Option B — Lien symbolique local (desktop-first uniquement)

**Ne choisir que si tu n'utilises jamais Claude Code sur le web ou le
téléphone.** Plus léger mais ne survit pas aux sandboxes éphémères.

### Setup initial (une fois)

```bash
mkdir -p ~/code
cd ~/code
git clone git@github.com:Hypalee/db-llm.git claude-config
```

### Dans chaque projet

```bash
cd ~/code/Brain
ln -s ~/code/claude-config claude-config
echo "claude-config" >> .gitignore
```

### Avantages
- Zéro friction : un `git pull` dans `~/code/claude-config` propage
  instantanément partout.
- Pas de pollution dans les repos projet (symlink ignoré).

### Limites
- **Inutilisable en Claude Code web / mobile** : la sandbox éphémère
  n'a pas ton `~/code/claude-config`.
- **Inutilisable en CI / pour un collaborateur** qui n'a pas cloné le
  repo à côté.

---

## Structure du `CLAUDE.md` local (dans chaque projet)

Squelette minimal :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<nom>.md

## Contexte spécifique à ce projet

### État courant
<ce sur quoi je bosse là, typiquement 2-3 lignes>

### Trucs à savoir
<hyper-local, ne doit pas être dans claude-config>
```

Le reste vit dans `claude-config`. Si tu te surprends à écrire
beaucoup dans le `CLAUDE.md` local, demande-toi si ça ne devrait pas
remonter dans `claude-config/projects/<nom>.md`.

---

## Imports possibles (à la carte)

Tu peux importer plus finement selon la session. Exemples :

```md
# Session de déploiement
@claude-config/CLAUDE.md
@claude-config/projects/brain.md
@claude-config/skills/deploy-vercel.md
@claude-config/memory/gotchas.md
```

```md
# Session de migration DB
@claude-config/CLAUDE.md
@claude-config/projects/brain.md
@claude-config/playbooks/db-migration.md
@claude-config/skills/debug-neon.md
```

Le plus souvent, les deux premières lignes suffisent : Claude sait
aller chercher skills/playbooks par lui-même via le contexte du
`CLAUDE.md` global.

---

## Vérification rapide

Après setup, dans le projet, ouvrir Claude Code et demander :

> "Quels sont mes conventions de commit ?"

Si la réponse mentionne `feat(scope):` en français → l'import
fonctionne. Sinon, vérifier le chemin du symlink / submodule.
