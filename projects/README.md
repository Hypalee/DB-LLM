# projects/

> **Note 2026-04-26** — Ce dossier servait à héberger une fiche par
> projet de prod (Brain), importée dans le `CLAUDE.md` du projet via
> submodule. Ce pattern a été abandonné le 2026-04-26 (cf.
> `memory/decisions.md` → "Découplage Brain ↔ DB-LLM"). Le dossier
> est conservé pour héberger ce template, qui reste utile pour
> rédiger la section "Contexte produit" d'un `CLAUDE.md` projet
> auto-portant.

## Template — section "Contexte produit" d'un `CLAUDE.md` projet

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
