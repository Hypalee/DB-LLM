# Chapitre 02 — MCP (Model Context Protocol) : concepts, scopes, cross-repo

> Deuxième chapitre du journal. Explique ce qu'est un MCP concrètement,
> comment il s'intègre à Claude Code, la question **critique** des
> scopes (user/project/local), et le pattern pour qu'un repo partagé
> (type `claude-config`) documente des MCP utilisés depuis d'autres
> projets.
>
> Destiné à être relu à froid, partageable.

## Table des matières

1. [Qu'est-ce qu'un MCP ?](#1-quest-ce-quun-mcp-)
2. [Comment ça marche techniquement](#2-comment-ça-marche-techniquement)
3. [Les scopes : user, project, local](#3-les-scopes--user-project-local)
4. [MCP officiels vs communautaires](#4-mcp-officiels-vs-communautaires)
5. [Auth : OAuth, clé API, stdio local](#5-auth--oauth-clé-api-stdio-local)
6. [Pattern cross-repo : documenter ici, configurer au user](#6-pattern-cross-repo--documenter-ici-configurer-au-user)
7. [MCP vs agent vs outil natif](#7-mcp-vs-agent-vs-outil-natif)
8. [Pièges courants](#8-pièges-courants)
9. [À retenir](#9-à-retenir)

---

## 1. Qu'est-ce qu'un MCP ?

**MCP** = Model Context Protocol. C'est un **protocole standard**
(comme HTTP pour le web) pour connecter un LLM à des outils et des
données externes.

Analogie souvent utilisée : **"l'USB-C pour les LLMs"**. Avant MCP,
chaque LLM inventait sa propre manière d'appeler un outil externe
(OpenAI function calling, Anthropic tool use, etc. — tous
incompatibles). Avec MCP, un **serveur MCP** expose ses outils une
fois, et tous les LLMs qui parlent MCP peuvent les utiliser. Neon
écrit **un** serveur MCP, et Claude Code, Cursor, VS Code, Windsurf
s'y connectent tous.

### Ce qu'expose un serveur MCP

Trois types d'objets :

- **Tools** : actions que le LLM peut exécuter (`create_branch`,
  `send_email`, `query_db`). L'équivalent d'un endpoint API,
  décrit en langage naturel pour que le LLM sache quand l'utiliser.
- **Resources** : données que le LLM peut lire (fichiers, DB,
  documentation). L'équivalent d'un GET.
- **Prompts** : templates de prompts préfabriqués, paramétrables.

La plupart des MCP que tu croiseras se concentrent sur les **tools**.

### Ce que MCP n'est PAS

- **Pas un modèle LLM.** MCP est un canal de communication, pas une
  IA.
- **Pas un framework d'agent.** C'est plus bas niveau : tu branches
  un agent MCP-aware (comme Claude Code) sur un serveur MCP.
- **Pas un runtime pour ton app.** Un MCP Neon ne remplace pas ta
  connexion `DATABASE_URL` dans Next.js. Il sert à Claude Code pour
  te faire gagner du temps en dev.

---

## 2. Comment ça marche techniquement

### L'architecture

```
Claude Code (client MCP) ←→ serveur MCP ←→ service réel (Neon, Vercel…)
```

Le client MCP (Claude Code) parle au serveur MCP via JSON-RPC. Le
serveur traduit les appels du LLM en appels API réels vers le
service. Les résultats remontent par le même chemin.

### Deux transports

- **stdio** : le serveur MCP est un process local lancé par le
  client. Communication via stdin/stdout. Cas typique : un binaire
  Node.js ou Python que tu installes localement.
- **HTTP / SSE** : le serveur est remote, hosted quelque part. Le
  client ouvre une connexion HTTP (souvent Server-Sent Events pour
  le streaming). Cas typique : `mcp.neon.tech`, `mcp.vercel.com`.

**Pour toi, mobile-first, solo** : les MCP **remote HTTP** sont
préférables. Zéro install locale, fonctionnent depuis la sandbox
Claude Code web comme depuis un PC.

### Le cycle de vie d'un appel

1. Tu dis à Claude "liste mes branches Neon".
2. Claude détecte qu'un tool MCP matche (`neon_list_branches`).
3. Claude Code envoie l'appel au serveur MCP Neon.
4. Le serveur fait la vraie requête API à Neon.
5. Le résultat revient au serveur, qui le structure, le renvoie à
   Claude Code.
6. Claude le reçoit comme un "tool result", l'interprète, te
   répond en langage naturel.

Pour toi, c'est fluide et invisible. Mais savoir qu'il y a **trois
sauts réseau** (client → serveur MCP → service réel → retour) aide à
debugger quand c'est lent ou ça échoue.

---

## 3. Les scopes : user, project, local

**C'est le concept le plus important à maîtriser.** Trois scopes
possibles pour configurer un MCP dans Claude Code :

| Scope | Où c'est stocké | Qui y a accès | Committé git |
|---|---|---|---|
| **user** | Profil Claude Code (lié à ton compte) | Tous tes projets, tous devices | Non |
| **project** | `.mcp.json` à la racine du projet | Quiconque clone ce projet | **Oui** |
| **local** | Config du projet, non committée | Toi sur ce projet uniquement | Non |

### Cas d'usage de chaque scope

**User** : tu utilises un MCP pour **ton** workflow personnel,
peu importe le projet. Exemple : un MCP Notion pour ta prise de
notes perso, un MCP Neon pour tous tes projets Neon. **Par défaut
en solo, c'est ce scope.**

**Project** : un MCP fait partie intégrante du projet, toute
personne qui clone doit l'avoir. Exemple : MCP Stripe pour un
projet e-commerce où chaque dev doit interagir avec Stripe.
Committé dans `.mcp.json`, partagé en équipe.

**Local** : tu veux tester un MCP sur un projet sans embêter les
autres, ou ton setup est spécifique (clé API perso dans l'URL).
Pas committé.

### Comment on ajoute un MCP

Via la CLI Claude Code :

```bash
# Scope user (par défaut recommandé pour solo)
claude mcp add --scope user <nom> <commande-ou-url>

# Scope project (committé)
claude mcp add --scope project <nom> <commande-ou-url>

# Scope local
claude mcp add --scope local <nom> <commande-ou-url>
```

### Pour les MCP remote HTTP

```bash
claude mcp add --scope user --transport http neon https://mcp.neon.tech/sse
```

### Pour les MCP stdio locaux

```bash
claude mcp add --scope user filesystem npx -y @modelcontextprotocol/server-filesystem /path/to/dir
```

Claude Code gère l'authentification (OAuth ou clé) au premier
appel.

---

## 4. MCP officiels vs communautaires

Deux qualités possibles.

### MCP officiels

Maintenus par l'éditeur du service. Exemples : Neon, Vercel,
Resend, GitHub, Stripe, Supabase, Red Hat.

Avantages :
- Maintenance garantie par le service lui-même.
- Sécurité : le code est signé, l'OAuth passe par le vrai service.
- Capacités alignées sur l'API officielle.

Risque : **aucun** en général. C'est l'option par défaut.

### MCP communautaires

Écrits par des développeurs tiers (souvent sur GitHub). Exemples :
des milliers disponibles sur `mcpservers.org`, `mcpcursor.com`,
Docker MCP catalog…

Avantages :
- Couverture de services qui n'ont pas de MCP officiel.
- Parfois plus innovants (features que l'éditeur ne veut pas
  supporter).

Risques :
- **Sécurité** : tu exécutes du code tiers avec accès à tes
  données / tes clés. Lire le code avant d'installer.
- **Maintenance** : peut devenir obsolète si l'auteur abandonne.
- **Qualité variable** : de l'excellent au cassé.

### Règle que je me donne

- **Toujours privilégier l'officiel** quand il existe.
- Communautaire seulement si pas d'officiel **et** code review
  rapide avant install.
- Pour un contexte équipe / client (MSP), communautaire sans
  validation = non.

---

## 5. Auth : OAuth, clé API, stdio local

Trois patterns d'authentification selon le MCP.

### OAuth (remote HTTP, recommandé)

Le serveur MCP redirige vers le service (Neon, Vercel…) pour que tu
te loggues, puis récupère un token d'accès scopé à ton compte.

- **Avantage** : pas de clé à gérer en clair.
- **Tu peux révoquer** depuis le dashboard du service.
- Le token est stocké par Claude Code, ré-injecté à chaque appel.

Utilisé par Neon MCP, Vercel MCP.

### Clé API (en variable d'env ou URL)

Tu fournis une clé API au moment de la configuration. Le serveur
MCP l'utilise pour authentifier tous les appels.

- **Avantage** : simple.
- **Risque** : si la clé fuit, tout ce qui est derrière fuit.
  Toujours utiliser une clé avec scope réduit (ex: Resend, crée une
  clé dédiée à ton MCP avec permissions restreintes).

Utilisé par Resend MCP (selon la variante).

### Stdio local sans auth distante

Le MCP tourne en local, accède à des ressources locales (fichiers,
terminal…). Pas besoin d'auth externe.

- **Exemple** : `server-filesystem` qui expose un dossier du disque.
- Attention aux **permissions locales** : ne jamais pointer vers
  `/` ou `~` — limiter strictement aux dossiers nécessaires.

---

## 6. Pattern cross-repo : documenter ici, configurer au user

> **Note 2026-04-26** — Cette section décrit le pattern qui était
> en place avec `claude-config` importé dans Brain via submodule.
> Le couplage entre les deux repos a été abandonné le 2026-04-26
> (cf. `memory/decisions.md` → "Découplage Brain ↔ DB-LLM"). La
> mécanique générale reste correcte : la **config active des MCP
> vit au scope user** (profil Claude Code, partagé entre tous mes
> projets). La **documentation des MCP** vit toujours dans `mcp/`
> de DB-LLM, à titre de référence personnelle. Section conservée
> comme référence pour un futur setup multi-repos.

### Le problème

Tu as un repo partagé `claude-config` qui centralise tes conventions,
skills, memory. Tu veux aussi que les MCP soient "partagés" entre
tes projets (Brain, projet suivant…) sans avoir à les reconfigurer
à chaque repo.

Naïvement, tu te dis : "je mets la config MCP dans claude-config, et
chaque projet y accède via les imports". **Ça ne marche pas.** La
config MCP dans un projet spécifique active le MCP uniquement pour
**ce projet-là**.

### La bonne solution (théorique)

Séparer deux choses :

1. **La config active du MCP** → scope **user** (profil Claude Code).
   Configurée une fois via `claude mcp add --scope user …`, suit ton
   compte, active partout.
2. **La documentation du MCP** (ce qu'il fait, comment l'utiliser,
   conventions) → dans `claude-config/mcp/<service>.md`.

### La solution pragmatique pour mobile-first

**Problème** : le scope user nécessite la CLI `claude mcp add …`,
pas disponible depuis l'app mobile / web. Si tu n'as pas de PC avec
Claude Code CLI, tu ne peux pas configurer au niveau user.

**Contournement** : utiliser le **scope project** via un fichier
`.mcp.json` committé à la racine de chaque repo. Claude Code le lit
automatiquement quand tu ouvres le repo, les MCP s'activent (avec
demande d'auth au premier appel).

Exemple minimal de `.mcp.json` :

```json
{
  "mcpServers": {
    "neon": {
      "type": "http",
      "url": "https://mcp.neon.tech/sse"
    },
    "vercel": {
      "type": "http",
      "url": "https://mcp.vercel.com/sse"
    },
    "resend": {
      "command": "npx",
      "args": ["-y", "resend-mcp"],
      "env": {
        "RESEND_API_KEY": "${RESEND_API_KEY}"
      }
    }
  }
}
```

Avantages :
- Pas de CLI requise, tout est dans le repo.
- Reproductible sur tous devices / toutes sandboxes Claude Code web.
- Versionné : tu sais quand les MCP ont été ajoutés.

Limite :
- Chaque repo doit avoir son propre `.mcp.json`. Quand tu crées
  Brain comme repo séparé, il faudra y mettre un `.mcp.json` aussi.
  Convention : copier celui de `claude-config` comme base, ajuster.

### Ce que tu obtiens

- Brain démarre → lit `CLAUDE.md` → importe `@claude-config/CLAUDE.md`
  → qui référence les fiches `mcp/` → Claude sait **quels** MCP
  existent et **comment** les utiliser selon tes conventions.
- La config active (URL, token OAuth) vit dans ton profil user et
  s'active automatiquement.
- Tu peux bosser sur mobile/web/PC, changer de device : tant que tu
  es connecté à Claude Code avec ton compte, les MCP suivent.

### Schéma

```
┌──────────────────────────────────────────┐
│   Profil Claude Code (scope user)        │
│   ├─ mcp.neon.tech (OAuth)               │
│   ├─ mcp.vercel.com (OAuth)              │
│   └─ mcp.resend.com (API key)            │
└──────────────────────────────────────────┘
           ↓ active partout
┌──────────────┐      ┌──────────────┐
│ Repo Brain   │      │ Repo Projet2 │
│              │      │              │
│ CLAUDE.md    │      │ CLAUDE.md    │
│ imports      │      │ imports      │
│ @claude-config/mcp/*                │
│                                    │
│ → Claude sait quoi, comment, règles│
└──────────────┘      └──────────────┘
           ↑                    ↑
           └──── claude-config ─┘
             (documentation uniquement)
```

### Quand ce pattern ne suffit pas

Si tu passes en équipe (comme dans un MSP), le scope **project**
(via `.mcp.json` committé) devient pertinent pour que chaque dev
ait **exactement** la même liste d'outils. Mais en solo, c'est
overkill.

---

## 7. MCP vs agent vs outil natif

Concepts proches, qui ne jouent pas au même niveau.

| Concept | Niveau | Rôle |
|---|---|---|
| **Outil natif** Claude Code | Bas niveau | Read, Edit, Bash, Grep… intégrés au CLI |
| **MCP** | Niveau intermédiaire | Ajouter des outils externes (services tiers) |
| **Skill** | Niveau usage | Capsule une manière d'utiliser les outils |
| **Agent** | Niveau orchestration | Instance Claude autonome avec son propre contexte |

### Exemple combinant les quatre

Tu demandes "déploie Brain en prod et envoie un mail de release
à mes beta testeurs".

1. Un **agent** "deploy-orchestrator" est spawné avec outils
   restreints.
2. L'agent utilise le **MCP Vercel** pour déclencher le déploiement
   et suivre les logs.
3. Il utilise le **MCP Resend** pour envoyer le mail aux contacts
   taggés "beta".
4. Il utilise l'**outil natif Bash** pour vérifier localement qu'un
   test de smoke passe.
5. Le tout est encapsulé dans un **skill** `/release-brain` qui
   fixe le workflow et les conventions.

Chaque niveau fait une chose qu'il fait bien. Pas de duplication.

---

## 8. Pièges courants

### 8.1 MCP installé en mauvais scope

Tu configures un MCP en scope **project** par erreur. Il disparaît
quand tu changes de repo. Solution : `claude mcp list` pour voir
les scopes, `claude mcp remove <nom>` puis re-ajouter en scope user.

### 8.2 MCP qui ne répond plus

Trois causes fréquentes :

- **Token OAuth expiré** : re-faire le login (Claude Code te
  redemandera au prochain appel).
- **Service down** : vérifier le status public du service.
- **Rate limit atteint** : attendre ou passer à un plan supérieur.

### 8.3 Confondre MCP dev et API runtime

Le MCP Neon sert à **Claude Code** pour t'aider en dev. Ce n'est
**pas** ton driver DB runtime. Ton app continue d'utiliser
`DATABASE_URL` / Drizzle / etc.

Même logique pour Vercel (l'API Vercel du MCP n'a rien à voir avec
ton app déployée) et Resend (le MCP n'envoie pas les emails de ton
app en prod — c'est ton intégration Resend SDK qui le fait).

### 8.4 Donner trop de permissions

Un MCP avec pleine permission OAuth peut **tout** faire sur ton
compte. Pour des environnements sensibles (prod, client) :

- Créer des tokens/API keys **scopés** au minimum nécessaire.
- Review les logs d'activité régulièrement.
- Révoquer tout ce qui n'est plus utilisé.

### 8.5 Multiplier les MCP qui se chevauchent

Tu ajoutes 3 MCP communautaires qui font des choses similaires.
Claude devient confus sur lequel appeler. Règle : **un MCP par
service, choisir le meilleur, supprimer les autres**.

---

## 9. À retenir

- **MCP** = protocole pour connecter des LLMs à des services
  externes. "USB-C des LLMs".
- **Trois scopes** : user (perso, tous projets), project (équipe,
  committé), local (perso, un projet).
- Pour un usage **solo mobile-first** : scope **user** par défaut.
- Ton repo `claude-config` **documente** les MCP (conventions,
  pièges), mais **ne contient pas** leur config active.
- Préférer **officiel > communautaire** quand possible.
- Préférer **remote HTTP > stdio local** pour compatibilité
  mobile/web.
- Un MCP n'est pas un agent, pas un skill, pas une API runtime.
  C'est une couche d'accès pour les outils de dev.

---

## Sources

- [Neon MCP Server overview](https://neon.com/docs/ai/neon-mcp-server)
- [Vercel Model Context Protocol docs](https://vercel.com/docs/mcp)
- [Use Vercel's MCP server](https://vercel.com/docs/agent-resources/vercel-mcp)
- [Send emails with MCP · Resend](https://resend.com/mcp)
- [Resend MCP Server docs](https://resend.com/docs/mcp-server)
- [Model Context Protocol (MCP) explained: An FAQ - Vercel](https://vercel.com/blog/model-context-protocol-mcp-explained)
