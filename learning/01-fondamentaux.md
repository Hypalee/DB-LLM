# Chapitre 01 — Fondamentaux Claude Code, agents et workflows IA

> Premier chapitre du journal d'apprentissage. Capture ce qu'on a vu
> dans la session d'initialisation de `claude-config` : vocabulaire
> git, briques Claude Code (CLAUDE.md, settings, hooks, skills,
> agents), patterns multi-agent, économie des tokens, RAG, intégration
> cross-repo, env vars, et recommandations pour une équipe MSP.
>
> Destiné à être relu à froid et partagé. Pas besoin d'avoir suivi la
> session pour comprendre.

## Table des matières

1. [À qui s'adresse ce document](#1-à-qui-sadresse-ce-document)
2. [Préambule : comprendre Git en 5 minutes](#2-préambule--comprendre-git-en-5-minutes)
3. [Comment Claude Code "se souvient"](#3-comment-claude-code-se-souvient)
4. [Les briques fondamentales](#4-les-briques-fondamentales-de-claude-code)
5. [Le concept de multi-agent](#5-le-concept-de-multi-agent)
6. [Patterns multi-agent classiques](#6-patterns-multi-agent-classiques)
7. [Composer un workflow](#7-composer-un-workflow-efficace)
8. [L'économie des tokens](#8-léconomie-des-tokens)
9. [RAG vectoriel ou Markdown structuré ?](#9-rag-vectoriel-ou-markdown-structuré-)
10. [Intégrer un repo de contexte (submodule vs symlink)](#10-intégrer-un-repo-de-contexte)
11. [Variables d'environnement (env vars)](#11-variables-denvironnement-env-vars)
12. [Apprendre efficacement](#12-apprendre-efficacement-lia)
13. [Autonomie API](#13-donner-de-lautonomie-à-claude-sur-lapi)
14. [Cas d'usage MSP / équipe](#14-cas-dusage-msp--équipe)
15. [Glossaire](#15-glossaire)

---

## 1. À qui s'adresse ce document

À quelqu'un qui :

- sait coder à un niveau correct (TypeScript, Python, ou autre) ;
- commence à utiliser Claude Code ou un assistant IA sérieusement ;
- veut aller au-delà du "je copie-colle du code généré" et comprendre
  comment **construire un environnement de travail IA solide** ;
- pense éventuellement à déployer ces patterns dans une équipe.

Il est volontairement progressif : on commence par des basiques git
pour que personne ne décroche, et on monte en abstraction jusqu'aux
architectures multi-agent.

---

## 2. Préambule : comprendre Git en 5 minutes

Claude Code s'appuie sur git en permanence. Si tu n'es pas à l'aise
avec les branches, les commits et les Pull Requests, le reste n'a pas
de sens. Résumé express.

### Concepts

- **Repository (repo)** : un dossier versionné. Chaque modification y
  est tracée.
- **Commit** : une "photo" du repo à un instant T, avec un message
  qui décrit le **pourquoi** de la modif. Les commits sont les
  briques de l'histoire du projet.
- **Branche** : une ligne de développement parallèle. `main` est la
  branche de référence (prod). Chaque feature / fix vit dans sa
  propre branche (ex: `feat/auth-2fa`) avant d'être fusionnée.
- **Merge** : fusionner une branche dans une autre (typiquement une
  feature branch dans `main`).
- **Push / pull** : envoyer (push) ou recevoir (pull) des commits
  entre ton repo local et le repo distant (souvent GitHub).
- **Pull Request (PR)** : demande formelle "je propose de fusionner
  ma branche dans main, viens relire avant". C'est le **filet de
  sécurité** avant un merge. Même seul, c'est utile : tu relis ton
  propre diff.

### Ce que tu vois dans Claude Code (web)

Une barre en haut de l'écran ressemble à :

```
main ← feat/audit-m365-tenant    +1442 -0    [Créer une PR]
```

- `main ← feat/audit-m365-tenant` : tu es sur la branche de droite,
  qui est "candidate à être mergée" dans la branche de gauche.
- `+1442 -0` : ton diff contre `main` — 1442 lignes ajoutées, 0
  supprimée.
- `[Créer une PR]` : bouton qui ouvre une Pull Request GitHub.

Tant que tu n'as pas mergé ou cliqué "Créer une PR", ton travail reste
isolé dans ta branche, ne touche pas `main`.

### La règle d'or

**Ne jamais pousser directement sur `main`.** Toujours une branche +
une PR. Trois raisons :

1. Tu peux relire ton diff avant de casser la prod.
2. L'historique de `main` reste propre.
3. En équipe, c'est le seul moyen d'avoir une revue.

---

## 3. Comment Claude Code "se souvient"

Le problème à résoudre : chaque nouvelle session Claude Code démarre
**de zéro**. Il ne sait rien de ton projet, de ta stack, de tes
conventions. Sans mécanisme de mémoire, tu ré-expliques tout à chaque
fois. Perte de temps massive.

### La mécanique de base : `CLAUDE.md`

Claude Code lit **automatiquement** un fichier nommé `CLAUDE.md` à
la racine du projet au démarrage. Son contenu devient ton "prompt
système implicite". Tout ce qui est écrit dedans fait partie du
contexte à chaque tour de conversation.

Il existe plusieurs niveaux, cumulatifs :

- `~/.claude/CLAUDE.md` : global, tous tes projets.
- `<projet>/CLAUDE.md` : spécifique à ce projet.

### Les imports `@file`

La syntaxe `@chemin/fichier.md` dans un CLAUDE.md demande à Claude
Code de **lire et inclure** ce fichier dans le contexte. Ça permet
d'éclater le savoir en plusieurs fichiers sans tout dupliquer.

Exemple de `CLAUDE.md` local dans un projet :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<projet>.md

## Contexte spécifique à ce projet
Ce qui est vraiment propre à ce repo, pas déjà couvert ci-dessus.
```

Les deux premières lignes importent des fichiers d'un **repo partagé**
(voir section 10) qui contient :

- `CLAUDE.md` global (profil, stack, conventions générales) ;
- `projects/<projet>.md` (état spécifique du projet <projet>).

Résultat : une seule source de vérité pour tes conventions, et pour
chaque projet juste son spécifique.

> **Note 2026-04-26** — L'exemple ci-dessus utilise `claude-config`
> et `projects/<projet>.md` parce que c'était le pattern initial pour
> mes projets. Ce pattern précis a été abandonné pour <projet> le
> 2026-04-26 au profit d'un `CLAUDE.md` projet auto-portant (cf.
> `memory/decisions.md` → "Découplage <projet> ↔ DB-LLM"). Le mécanisme
> `@import` lui-même reste pertinent et utilisable dès qu'un repo de
> contexte partagé existe (équipe, ≥ 2 projets avec contexte commun).

### Règle de densité

Tout ce qui est dans `CLAUDE.md` et ses imports est lu **à chaque
tour de conversation**. Donc :

- Tout token stocké ici est un token en moins pour le raisonnement.
- Écrire **sec et actionnable**. Pas de prose ornementale.
- Retirer ce qui ne sert plus. Code mort de la mémoire = bruit.

---

## 4. Les briques fondamentales de Claude Code

Claude Code est un CLI (et une app web/mobile) qui enveloppe Claude
(le modèle) avec des **outils** (lecture de fichiers, bash, édition,
web fetch…) et des **points d'extension** que tu peux configurer.

### 4.1 `settings.json`

Le fichier de configuration principal. Deux emplacements utiles :

- `~/.claude/settings.json` : global (tous projets, ton profil).
- `<projet>/.claude/settings.json` : projet (partagé en équipe).
- `<projet>/.claude/settings.local.json` : projet mais personnel
  (gitignoré, tes overrides).

Ce qu'il contrôle :

- **`model`** : le modèle par défaut (`claude-opus-4-7`, `sonnet`,
  `haiku`). Utile si tu bosses sur mobile et que tu ne peux pas
  choisir le modèle dans l'UI quand tu reprends une session.
- **`permissions`** : quels outils Claude peut utiliser sans te
  demander (`allow`, `deny`, `ask`). Ex: `Bash(npm *)` = toute
  commande npm autorisée sans prompt.
- **`env`** : variables d'environnement injectées.
- **`hooks`** : scripts déclenchés automatiquement (voir ci-dessous).
- **`enabledPlugins`** : plugins actifs.

### 4.2 Hooks — la vraie puissance

Un **hook** est un script shell (ou une prompt LLM, ou un agent)
déclenché **automatiquement** à un événement précis du cycle de vie
de Claude Code.

Différence fondamentale avec la mémoire (`CLAUDE.md`) :

- `CLAUDE.md` = ce que Claude doit **savoir**.
- Hook = ce qui doit **se passer** automatiquement quand X arrive.

Les événements les plus utiles :

| Événement | Quand ça déclenche | Usage typique |
|---|---|---|
| `PreToolUse` | Avant un appel d'outil | Bloquer un `rm -rf`, logger |
| `PostToolUse` | Après un appel d'outil réussi | Formater le code écrit |
| `SessionStart` | Au démarrage de Claude Code | Charger des infos fraîches |
| `Stop` | Quand Claude finit un tour | Rappel "commit avant de fermer" |
| `PreCompact` | Avant compression du contexte | Sauvegarder de l'info critique |
| `UserPromptSubmit` | Quand tu envoies un prompt | Ajouter du contexte dynamique |

Exemples concrets :

1. **Auto-formateur** : un hook `PostToolUse` sur `Write|Edit` qui
   lance Prettier sur chaque fichier modifié. Ton code est toujours
   propre, sans y penser.
2. **Garde-fou force push** : un hook `PreToolUse` sur `Bash` qui
   refuse tout `git push --force origin main`. Sécurité à la racine,
   pas une discipline à maintenir.
3. **Check commit en sortie** : un hook `Stop` qui te rappelle que
   ton working tree n'est pas propre avant que tu fermes Claude.
4. **Tests automatiques** : un hook `PostToolUse` qui re-lance la
   suite de tests dès qu'un fichier `.ts` est modifié.

**Ce qu'il faut retenir** : les hooks transforment des disciplines
(que tu dois appliquer à la main) en **garanties** (que l'environnement
applique pour toi).

### 4.3 Skills

Un **skill** Claude Code est un fichier Markdown qui encapsule une
capacité : "savoir déployer sur Vercel", "savoir reviewer une PR",
"savoir configurer settings.json". Il peut inclure des instructions
détaillées, des règles, et parfois des scripts.

Emplacements :

- **Built-in** : fournis par Claude Code (`/review`, `/init`,
  `/security-review`, etc.).
- **User** : `~/.claude/skills/<nom>/SKILL.md`, perso.
- **Project** : `.claude/skills/<nom>/SKILL.md`, partagé en équipe.
- **Plugin** : via l'écosystème de plugins Claude Code.

Un skill est **chargé à la demande**, pas en permanence. Donc il ne
consomme pas de tokens tant que tu ne l'invoques pas. Tu peux en
avoir des dizaines sans pénalité.

Un skill s'invoque :

- Par toi, via une **slash command** (`/review`, `/deploy-vercel`).
- Par Claude lui-même, quand la description du skill matche le
  contexte.

**Anti-confusion** : dans le repo `claude-config`, le dossier
`skills/` contient pour l'instant des **notes** au format markdown,
pas des vrais skills Claude Code invocables. Pour les transformer en
skills officiels, il faut les déplacer dans `~/.claude/skills/<nom>/`
avec un frontmatter YAML (nom, description, déclencheurs).

### 4.4 Slash commands

Les commandes préfixées par `/` dans Claude Code. Certaines sont
natives (`/help`, `/model`, `/clear`), d'autres sont des skills
user-invocables. Conversationnelles et rapides.

### 4.5 Agents (sous-agents)

Une instance Claude isolée, lancée depuis la conversation principale
pour une tâche précise. Elle a :

- Un **prompt d'objectif** (ce qu'elle doit faire).
- Un **jeu d'outils restreint** (pour éviter les dérapages).
- Un **retour structuré** à son orchestrateur quand elle finit.

Plus de détails section 5.

---

## 5. Le concept de multi-agent

Jusque-là : un humain parle à un Claude, qui fait des choses. Simple.

Avec le **multi-agent**, le Claude principal peut **déléguer** une
tâche à une autre instance Claude — son "sous-agent" — qui a sa
propre conversation, ses propres outils, et qui rend un rapport.

Pourquoi c'est un levier énorme :

### 5.1 Parallélisation

Tu as 3 recherches indépendantes à faire dans le code ? Tu lances 3
sous-agents en parallèle, chacun sur sa piste. Temps de réponse total
= temps du plus lent, pas la somme. Gain de temps massif sur des
tâches exploratoires.

### 5.2 Protection du contexte principal

Un sous-agent qui lit 50 fichiers de code consomme ~200k tokens.
S'il remonte juste un résumé de 500 tokens à l'agent principal, tu
économises 199.5k tokens sur le budget de la conversation principale.

Le "gros" contexte est isolé dans le sous-agent et disparaît à sa
terminaison. Tu gagnes une marge énorme pour continuer à raisonner
au niveau principal.

### 5.3 Isolation et sécurité

Un sous-agent "security-reviewer" n'a pas besoin d'outils d'écriture
— tu lui donnes juste Read et Grep. Même s'il se "trompe", il ne peut
rien casser. Un sous-agent "autotask-worker" a juste les outils MCP
Autotask, pas d'accès au repo de code.

Isolation = surface d'erreur réduite.

### 5.4 Spécialisation

Un sous-agent "frontend-reviewer" a un prompt système dédié qui
connaît tes conventions UI (Tailwind v4, textes en français,
accessibilité). Un "backend-reviewer" a les siennes (TypeScript
strict, pas de any, sécurité SQL). Chacun fait son job mieux qu'un
généraliste.

---

## 6. Patterns multi-agent classiques

Quatre patterns qu'on croise tout le temps en architecture d'agents.

### 6.1 Orchestrateur + workers

```
Agent principal (orchestrateur)
  ├─ Worker 1 (tâche A)
  ├─ Worker 2 (tâche B)
  └─ Worker 3 (tâche C)
```

L'orchestrateur décompose, dispatche en parallèle, fusionne les
résultats. Usage : audits, recherches multi-axes, refactorings
structurés.

### 6.2 Critic / reviewer

```
Agent générateur → produit une réponse
       ↓
Agent critique → relit, pointe les erreurs
       ↓
Agent générateur → corrige
```

Utile quand la qualité compte plus que la vitesse. Ex: code de
sécurité, prose client-facing.

### 6.3 Planner / executor

```
Agent planner : conçoit le plan (haut niveau)
       ↓
Agent executor : exécute chaque étape (bas niveau)
```

Sépare le **raisonnement** (coûteux, nécessite un gros modèle) de
l'**exécution** (souvent faisable avec un plus petit modèle).

### 6.4 Router (contre rephraser)

```
User prompt
   ↓
Router (petit modèle rapide) classifie
   ↓
  ┌────────┬────────┬────────┐
Worker A  Worker B  Worker C
```

Le router **ne réécrit pas** le prompt. Il décide juste **où**
l'envoyer. Le worker reçoit le prompt utilisateur original, intact.

### 6.5 Anti-pattern : "rephraser"

```
User prompt
   ↓
LLM "améliore" le prompt (réécrit)
   ↓
LLM cible répond
```

**À éviter en production.** Quatre raisons :

1. **Dérive d'intention** : le réécriveur interprète, donc peut
   déformer. Quand le résultat final est bizarre, tu ne sais pas si
   le bug vient de la réécriture ou du worker.
2. **Double latence et double coût**.
3. **Incitation à mal prompter** : tu ne progresses jamais puisque
   la machine corrige derrière.
4. **Boîte noire non déterministe** : deux runs sur le même input
   peuvent produire deux reformulations différentes → deux résultats
   différents. Cauchemar à auditer.

En revanche, un skill pédagogique `/prompt-critique` à invoquer **à
la demande** pour apprendre à mieux prompter : bonne idée. La
différence est clé : outil d'apprentissage ≠ filtre permanent.

---

## 7. Composer un workflow efficace

Un workflow mature combine les briques précédentes. Exemple d'un dev
solo sérieux :

1. **Contexte permanent** : `CLAUDE.md` à la racine du repo (pour
   un projet auto-portant) ou imports depuis un repo partagé via
   submodule (pattern abandonné pour mes projets actuels en
   2026-04-26 — voir §10). Claude connaît ta stack, tes conventions,
   l'état de tes projets à chaque session.
2. **Skills** installés pour les tâches récurrentes : déploiement,
   debug DB, revue de PR, audit env vars. Invoquer via slash command
   ou laisser Claude les choisir.
3. **Hooks** pour les actions automatiques : format post-édition,
   blocage force push, rappel commit en sortie.
4. **Sous-agents** pour parallélisation et isolation sur tâches
   lourdes : exploration multi-fichiers, review critique, planner.
5. **Mémoire** (`memory/`) : décisions, pièges, leçons. Alimentée à
   chaque session significative.

L'erreur classique : construire cette stack **trop tôt**. Si ton
`CLAUDE.md` de base n'est pas bon, aucune architecture multi-agent ne
te sauvera. Commence par muscler le contexte, puis ajoute des couches
seulement quand le besoin est clair.

---

## 8. L'économie des tokens

Un **token** ≈ un morceau de mot (environ 4 caractères en anglais, 3
en français). Chaque tour de conversation avec Claude consomme des
tokens en entrée (le contexte envoyé) et en sortie (la réponse).

La fenêtre de contexte est limitée (souvent 200k tokens). Plus tu
remplis, plus Claude a de "matière", mais aussi moins de marge pour
réfléchir et répondre. L'équilibre est stratégique.

### Répartition des coûts

| Source | Quand chargé | Contrôle |
|---|---|---|
| Système Anthropic | À chaque tour, incompressible | Aucun |
| `CLAUDE.md` + imports | À chaque tour, permanent | Toi (contenu) |
| Ton prompt du tour | Une fois | Toi |
| Réponse de Claude | Une fois | Claude (longueur) |
| Résultats d'outils (lectures, grep, bash) | Au moment de l'appel | Claude (choix de l'outil) |
| Skills | Seulement si invoqués | À la demande |

### Les trois pièges

1. **CLAUDE.md bloat** : écrire trop dans `CLAUDE.md`. Chaque mot
   inutile est payé **à chaque tour**. Rester sec.
2. **Tool result explosion** : un `grep` sur un gros repo peut
   remonter 50k tokens en un call. Solution : déléguer à un
   sous-agent qui remonte un résumé court.
3. **Sessions trop longues** : plus la conversation grossit, plus
   chaque tour est coûteux et lent. Pour une nouvelle tâche, ouvrir
   une nouvelle session est souvent plus sain.

### Prompt caching (notion avancée)

L'API Anthropic permet de **cacher** la partie stable du contexte
(ton CLAUDE.md, tes instructions récurrentes). Les tours suivants
paient beaucoup moins cher pour ce contexte. Si tu construis une
app avec l'API Anthropic directement, c'est un levier important
d'économie. Claude Code l'utilise automatiquement en coulisses.

---

## 9. RAG vectoriel ou Markdown structuré ?

Question récurrente quand on veut donner de la "mémoire" à un LLM :
faut-il un **RAG** (Retrieval-Augmented Generation) ?

### Ce qu'est un RAG

1. Tu découpes tes docs en petits morceaux ("chunks").
2. Pour chaque morceau, tu calcules un **embedding** : un vecteur de
   nombres (typiquement 1024 ou 1536 dimensions) qui représente le
   sens du texte.
3. Tu stockes les vecteurs dans une base vectorielle (pgvector,
   Qdrant, Pinecone…).
4. À la question de l'utilisateur, tu calcules l'embedding de la
   question, tu cherches les N vecteurs les plus "proches" en
   similarité cosinus.
5. Tu injectes ces morceaux dans le contexte du LLM avant qu'il
   réponde.

C'est utile quand ton corpus est **gros** (millions de tokens), **non
structurable** en arbre, et que tu veux de la recherche par
signification plutôt que par mot-clé.

### Quand ça ne sert à rien

Tant que ton corpus est :

- **Petit** (< 100k tokens tout confondu) ;
- **Structuré** (par projet, par thème, accessible via des chemins
  de fichiers nommés) ;
- **Connu de toi** (tu sais où chaque info se trouve).

Alors un arbre Markdown bien nommé, avec des imports `@file` ciblés,
bat un RAG sur tous les axes :

- **Déterminisme** : l'import lit EXACTEMENT le fichier voulu. Un
  RAG peut rater la bonne info à cause d'une similarité faible.
- **Coût zéro** : pas d'infra, pas d'embedding API, pas de
  re-indexation à chaque modif.
- **Simplicité** : un `git pull` et tout est à jour.
- **Debuggabilité** : tu lis un fichier, tu vois ce qui est injecté.
  Un RAG est plus opaque.

### Quand envisager un RAG

Si au moins un critère s'applique :

- Ton corpus dépasse 500k tokens ;
- Tu veux une recherche transversale non structurable ("toutes les
  sessions où on a parlé de rate limiting", peu importe le projet) ;
- Plusieurs utilisateurs / agents sans le même modèle mental de la
  structure ;
- Tes données changent en temps réel et les `@imports` deviennent
  fragiles.

Étape intermédiaire avant le RAG : un `INDEX.md` par tags, une
commande `grep` via un skill dédié. Souvent suffisant jusqu'à
plusieurs milliers de fichiers Markdown.

---

## 10. Intégrer un repo de contexte

> **Note 2026-04-26** — Cette section décrit en détail le pattern
> du repo de contexte partagé (submodule + symlink). **Ce pattern
> n'est plus en usage dans mes projets actuels** : <projet> a été
> découplé de DB-LLM le 2026-04-26 (cf. `memory/decisions.md` →
> "Découplage <projet> ↔ DB-LLM"), chaque projet de prod a désormais
> un `CLAUDE.md` auto-portant. Section conservée comme référence
> pédagogique : si je redémarre un setup multi-repos (équipe, ≥ 2
> projets avec contexte commun), c'est la mécanique à reprendre.

Pattern utile : un repo `claude-config` (ou `ai-context`, peu importe
le nom) qui contient les `CLAUDE.md`, skills, memory, playbooks
partagés entre tes projets. Puis chaque projet y accède.

Comment concrètement le brancher dans un projet ? Deux options selon
ton usage principal.

### 10.1 Option A — Git submodule (recommandée mobile/web)

**Quand choisir** : tu utilises Claude Code sur téléphone / web, ou
tu veux un setup qui marche en CI et pour un collaborateur.

Pourquoi : Claude Code sur le web tourne dans une **sandbox
éphémère**. Il n'y a pas de filesystem local qui persiste. Un
submodule se clone avec le repo projet, donc les `@imports`
fonctionnent partout.

Ajouter le submodule à un projet :

```bash
cd ~/code/<projet>
git submodule add https://github.com/<owner>/claude-config.git claude-config
git commit -m "chore: ajoute claude-config en submodule"
git push
```

Cloner un projet avec submodule :

```bash
git clone --recursive https://github.com/<owner>/<projet>.git
# ou si déjà cloné :
git submodule update --init --recursive
```

Mettre à jour `claude-config` dans un projet :

```bash
cd ~/code/<projet>/claude-config
git pull origin main
cd ..
git commit -am "chore: bump claude-config"
git push
```

Coût : une petite friction régulière (penser à bumper), compensée
par la fiabilité sur tous les devices.

### 10.2 Option B — Lien symbolique local (desktop uniquement)

**Quand choisir** : tu n'utilises JAMAIS Claude Code sur le web ou
mobile. Tout se passe dans ton terminal local.

```bash
mkdir -p ~/code
git clone https://github.com/<owner>/claude-config.git ~/code/claude-config
cd ~/code/<projet>
ln -s ~/code/claude-config claude-config
echo "claude-config" >> .gitignore
```

Avantage : un `git pull` dans `~/code/claude-config` propage partout,
zéro friction de bump.

Limite : inutilisable dès que tu passes en mobile/web — le symlink
pointerait vers un chemin inexistant dans la sandbox.

### 10.3 `CLAUDE.md` du projet

Squelette minimal :

```md
@claude-config/CLAUDE.md
@claude-config/projects/<nom>.md

## Contexte spécifique à ce projet

### État courant
<2-3 lignes sur ce que tu bosses là>

### Trucs à savoir
<hyper-local, ne doit pas être dans claude-config>
```

Si tu te surprends à écrire beaucoup dans le `CLAUDE.md` local,
c'est souvent le signe qu'une partie devrait remonter dans le repo
partagé.

---

## 11. Variables d'environnement (env vars)

Terme qu'on croise partout. Base essentielle.

### Définition

Une **variable d'environnement** (env var) est une donnée lue par
ton application **depuis l'extérieur du code**, au démarrage du
process.

### Pourquoi ne pas mettre les valeurs dans le code

1. **Secrets**. Un `DATABASE_URL` contient un mot de passe. Si tu
   le mets dans le code, il finit sur GitHub, donc potentiellement
   fuité en quelques minutes.
2. **Environnements multiples**. Même code, valeurs différentes
   entre dev, staging, prod. L'env var permet de switcher sans
   toucher au code.
3. **Portabilité**. Ton collègue n'a pas la même base que toi. Il
   met sa propre valeur dans son env, même code chez vous deux.

### Comment ça marche concrètement

**En dev local** : tu crées un fichier `.env.local` à la racine du
projet :

```
DATABASE_URL=postgres://user:pass@neon.tech/<dbname>
ANTHROPIC_API_KEY=sk-ant-xxxxxxxx
RESEND_API_KEY=re_yyyyyyyy
```

Ce fichier est **jamais committé** (ajouté au `.gitignore`).

**En prod (Vercel, par exemple)** : tu ajoutes chaque variable dans
le dashboard → Settings → Environment Variables. Vercel les injecte
au déploiement.

**Dans le code (Node.js)** : `process.env.DATABASE_URL` te donne la
valeur courante.

### `.env.example`

Convention utile : un fichier `.env.example` committé qui liste
**les noms** des variables requises, sans leurs valeurs. Ça sert de
documentation : un nouveau dev lance `cp .env.example .env.local`,
remplit les blancs, il est prêt.

### Pièges classiques

- **Committer `.env.local` par accident**. Toujours le mettre dans
  `.gitignore` dès le setup du repo.
- **Clés partagées dev/prod**. Un incident en dev impacte la prod.
  Toujours des clés séparées par environnement.
- **Quota silencieux dépassé**. Configurer une alerte budget côté
  provider (Anthropic, Resend…). Sinon dégradation invisible.
- **Variable manquante en prod**. Crash au premier usage. Solution :
  parser l'env avec `zod` au démarrage pour planter tôt si une
  variable est absente ou malformée.

---

## 12. Apprendre efficacement l'IA

Opinion informée, pas recette miracle.

### Les canaux, leurs forces

- **Claude Code (hands-on)** : imbattable pour apprendre à
  **faire**. Tu modifies un vrai repo, tu casses, tu répares.
  Ancre la connaissance par la pratique.
- **Claude chat (claude.ai)** : meilleur pour **comprendre**. Pas
  de pression d'exécution, tu peux divaguer, poser des questions
  conceptuelles ouvertes. "C'est quoi un embedding ? Quelle
  architecture pour X ? Pourquoi cette API plutôt qu'une autre ?"
- **Docs officielles** (`docs.anthropic.com`, `docs.claude.com`) :
  source de vérité, à jour, précise.
- **Vidéos YouTube** : **méfiance**. L'écosystème IA bouge tous les
  2-3 mois. Une vidéo de 6 mois peut déjà être périmée. À privilégier
  pour les concepts intemporels, pas pour "comment configurer X".

### Reco pratique

1. Un concept nouveau ? **Claude chat**. Tu creuses.
2. Mise en œuvre ? **Claude Code**, dans un repo jetable.
3. Vérification ? **Docs officielles**.
4. Inspiration ? Vidéos ponctuelles, avec esprit critique.

### Erreurs classiques à éviter

- **Empiler des abstractions sans maîtriser les bases.** Le
  multi-agent est inutile si ton CLAUDE.md est mal écrit.
- **Copier-coller sans comprendre.** Si tu ne peux pas expliquer
  une ligne de code à quelqu'un, ne la commit pas.
- **Se reposer sur l'IA au lieu d'apprendre.** L'IA est un pair,
  pas une béquille. Si tu ne progresses pas, c'est que tu l'utilises
  mal.

---

## 13. Donner de l'autonomie à Claude sur l'API

Question fréquente : peut-on laisser Claude Code agir directement
sur un service externe (ex: créer une table dans Neon, créer un
ticket dans Autotask) ?

### Techniquement oui, via plusieurs leviers

1. **MCP** (Model Context Protocol) : un serveur MCP expose les
   actions d'un service comme des outils utilisables par Claude.
   Ex: MCP Neon, MCP GitHub, MCP Autotask.
2. **Bash** : Claude peut exécuter `psql "$DATABASE_URL" -c "..."`
   directement. Simple et efficace.
3. **Migrations versionnées** : Claude écrit le fichier de migration
   (SQL ou Drizzle), toi ou ton CI l'applique.

### Guardrails recommandés

Ne pas céder au confort aveugle. Classement par risque :

| Environnement | Autonomie raisonnable |
|---|---|
| Dev local / branche de test | **Haute** — fais-toi plaisir. |
| Staging | **Moyenne** — Claude agit, humain relit les logs. |
| Prod | **Basse** — Claude prépare, humain déclenche. |

Raison : les actions destructives ou structurantes méritent un
humain dans la boucle. Une colonne mal ajoutée en prod = 3h de
debug pour 30s de confort gagné.

### Exemple concret

Besoin : ajouter une table `audit_logs` à la base <projet>.

Mauvais : Claude exécute `CREATE TABLE audit_logs (...)` en prod
directement via bash.

Bon :

1. Claude écrit un fichier de migration dans `migrations/`.
2. Claude crée une **branche Neon** de test.
3. Claude applique la migration sur la branche, vérifie.
4. Toi tu relis le fichier, tu mergeras la PR.
5. Le CI applique la migration en prod au déploiement.

C'est le pattern du playbook `db-migration`. Plus long ? Un peu.
Plus sûr ? Énormément.

---

## 14. Cas d'usage MSP / équipe

Conseils spécifiques pour une équipe qui veut professionnaliser son
usage de Claude Code (ex: MSP de 4 personnes, ~30 clients, MCP
connectés à des outils comme Autotask).

### 14.1 L'erreur classique

Se précipiter sur le multi-agent sophistiqué avant d'avoir un bon
CLAUDE.md d'équipe. C'est comme construire une bibliothèque sur un
sol pas nivelé : ça tient un temps, puis ça s'effondre.

### 14.2 Ordre de priorité recommandé

1. **Audit du CLAUDE.md d'équipe**. Est-ce qu'il capture :
   - les conventions de nommage des tickets, clients, environnements ?
   - les SLA et règles d'escalade par client ?
   - les pièges connus ("client X a un tenant M365 particulier") ?
   - les playbooks récurrents (onboarding client, audit sécu) ?
   Si non, **c'est ici que se trouve 80% du gain pour 10% du
   travail**.
2. **Ajouter des hooks de discipline partagés** :
   - `PreToolUse` sur `Bash` qui bloque les commandes destructives
     sur les tenants prod.
   - `PostToolUse` qui log toutes les actions MCP dans un fichier
     audit.
   - `Stop` qui vérifie qu'aucune info sensible n'a fuité dans la
     conversation.
3. **Créer des skills par workflow récurrent** : `/audit-m365-tenant`,
   `/close-ticket-autotask`, `/onboard-new-client`.
4. **Puis**, quand un workflow est stable et répété N fois, envisager
   de le transformer en **agent spécialisé** avec prompt système et
   outils restreints.

### 14.3 Agent spécialisé + MCP : la combinaison gagnante

Quand un MCP existe (ex: MCP Autotask), l'agent spécialisé apporte
**la couche métier au-dessus** :

- MCP = accès aux actions (`create_ticket`, `update_status`…).
- Agent = règles internes (« un ticket P1 déclenche un mail client
  + entrée dans le canal #incidents »), outils limités au domaine,
  retours structurés.

Un MCP sans agent = outil brut. Un agent sans MCP = expert sans
moyens. Ensemble, tu as un spécialiste efficace.

### 14.4 Routeur plutôt que rephraser

Si tu mets plusieurs workers spécialisés, ajoute un **routeur**
(petit modèle rapide, type Haiku) qui classifie le prompt et
dispatche. **Ne laisse jamais un LLM réécrire le prompt avant
de le transmettre** — voir section 6.5 pour le pourquoi détaillé.

---

## 15. Glossaire

- **Agent / sous-agent** : instance Claude isolée, lancée par
  l'agent principal pour une tâche précise, avec ses propres
  outils et son propre contexte.
- **CLAUDE.md** : fichier Markdown auto-chargé par Claude Code au
  démarrage. Fait partie du contexte permanent.
- **Commit** : "photo" versionnée du repo à un instant T avec un
  message qui explique le changement.
- **Embedding** : vecteur numérique qui représente le sens d'un
  morceau de texte. Base du RAG.
- **Env var** : variable d'environnement lue par le process au
  démarrage, pour les secrets et configs externes au code.
- **Hook** : script déclenché automatiquement par un événement
  Claude Code (PreToolUse, PostToolUse, Stop, SessionStart…).
- **Import `@file`** : syntaxe dans un CLAUDE.md pour inclure un
  autre fichier dans le contexte.
- **MCP** (Model Context Protocol) : protocole qui expose les
  actions d'un service externe (GitHub, Neon, Autotask…) comme
  des outils utilisables par Claude.
- **Pull Request (PR)** : demande de fusion d'une branche dans
  une autre, avec étape de revue.
- **Prompt caching** : mécanisme API Anthropic qui réduit le coût
  des tours successifs quand une partie du contexte est stable.
- **RAG** (Retrieval-Augmented Generation) : architecture où on
  cherche des morceaux pertinents (via embeddings) avant d'appeler
  le LLM, pour lui fournir le bon contexte.
- **Sandbox éphémère** : environnement d'exécution temporaire dans
  le cloud, utilisé par Claude Code sur le web. Disparaît à la
  fin de la session.
- **settings.json** : fichier de configuration Claude Code
  (permissions, hooks, modèle par défaut, env, plugins).
- **Skill** : fichier Markdown qui encapsule une capacité (avec
  éventuellement des scripts), invocable via slash command ou
  déclenché par Claude.
- **Slash command** : commande préfixée par `/` dans Claude Code
  (`/help`, `/model`, ou un skill user).
- **Submodule git** : dépendance externe d'un repo vers un autre
  repo, figée sur un commit précis.
- **Token** : unité élémentaire de texte traitée par un LLM
  (environ 3-4 caractères).

---

## Pour aller plus loin

Prochains chapitres prévus (à écrire au fil des sessions) :

- **02 — Hooks en pratique** : exemples concrets, debug, patterns.
- **03 — Construire un skill Claude Code** : du markdown au skill
  invocable, bonnes pratiques.
- **04 — Architecture multi-agent en profondeur** : cas réels,
  tradeoffs, quand ne pas le faire.
- **05 — API Anthropic et prompt caching** : quand passer du CLI à
  l'API programmatique.
- **06 — Sécurité des agents** : permissions, sandboxing, audit.

Ce document vit dans `learning/` du repo `claude-config`. Sa
vocation est de grandir au fur et à mesure des sessions et d'être
exporté en PDF quand il y aura assez de matière pour être partagé.
