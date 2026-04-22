# INTEGRATION — Utiliser `claude-config` dans un projet

Ce guide décrit comment brancher ce repo dans un projet pour que
Claude Code y ait accès lors de chaque session.

Claude Code résout les imports `@file` dans un `CLAUDE.md` **par
rapport au CWD du projet**. Il faut donc que les fichiers de
`claude-config` soient accessibles **localement** depuis le repo du
projet. Trois stratégies possibles, par ordre de préférence.

---

## Option A — Lien symbolique local (recommandée, solo dev)

Tu clones `claude-config` une fois dans `~/code/claude-config`, et
chaque projet a un symlink vers lui.

### Setup initial (une fois)

```bash
mkdir -p ~/code
cd ~/code
git clone git@github.com:Hypalee/claude-config.git
```

### Dans chaque projet

```bash
cd ~/code/<projet>   # par exemple
ln -s ~/code/claude-config claude-config
echo "claude-config" >> .gitignore
```

Puis créer `CLAUDE.md` à la racine du projet :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<projet>.md

## Contexte spécifique à ce projet

(ce qui est vraiment propre au repo courant, pas déjà couvert par
les imports ci-dessus)
```

### Avantages
- Simple, rapide.
- Une seule source de vérité : quand tu `git pull` dans
  `~/code/claude-config`, tous tes projets voient la mise à jour.
- Le symlink n'est pas committé, donc pas de pollution dans les repos
  projet.

### Limites
- Marche pour toi, pas pour un CI/collaborateur qui n'aurait pas le
  repo cloné à côté.
- Solution : dans ce cas, passer à l'option B.

---

## Option B — Git submodule

Permet à un CI ou un collaborateur d'avoir le contexte en clonant
juste le repo projet (avec `--recursive`).

```bash
cd ~/code/<projet>
git submodule add git@github.com:Hypalee/claude-config.git claude-config
git commit -m "chore: ajoute claude-config en submodule"
```

Mise à jour :
```bash
cd claude-config
git pull origin main
cd ..
git commit -am "chore: update claude-config"
```

### Avantages
- Version explicite de `claude-config` liée à chaque projet.
- Fonctionne en CI.

### Limites
- Submodules ajoutent de la friction (il faut `--recursive`, il faut
  penser à `git submodule update`).
- Pour du solo, c'est souvent overkill.

---

## Option C — Copie + script de sync

Copie bête des fichiers, avec un script `bin/sync-claude-config.sh`
qui pull depuis GitHub et recopie. À éviter : on perd la source
unique de vérité, on risque des copies divergentes.

À ne considérer que si A et B sont impossibles (ex: contrainte CI
qui n'accepte ni symlink ni submodule).

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
@claude-config/projects/<projet>.md
@claude-config/skills/deploy-vercel.md
@claude-config/memory/gotchas.md
```

```md
# Session de migration DB
@claude-config/CLAUDE.md
@claude-config/projects/<projet>.md
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
