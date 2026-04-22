# projects/

Un fichier par projet actif. Ces fichiers sont importés explicitement
dans le `CLAUDE.md` local de chaque projet via :

```md
@claude-config/projects/<nom>.md
```

## Template

```md
# <Nom du projet>

## Résumé
<une phrase sur ce que fait le projet>

## Stack
- ...

## Repo & déploiement
- Repo : `<org>/<nom>`
- Branche principale : `main`
- Prod : `https://...`
- Hébergement : Vercel

## Domaine
- Achat : Cloudflare
- DNS : Cloudflare → Vercel

## Variables d'environnement
| Nom | Usage | Où la trouver |
|-----|-------|---------------|
| ... | ...   | ...           |

## Schéma DB (vue d'ensemble)
- Table `...` : ...

## Services tiers
- Neon : ...
- Resend : ...
- Anthropic : ...

## Phase actuelle
- **Phase N** : ...

## Pièges spécifiques
- ...

## Roadmap court terme
- [ ] ...
```

## Projets actifs

- [`<projet>.md`](./<projet>.md) — App de capture de notes enrichies par Claude
