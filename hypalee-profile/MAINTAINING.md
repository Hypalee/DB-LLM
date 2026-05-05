# Maintaining this README

This repo is the GitHub profile README (`hypalee/hypalee`). The `README.md` at the root is what GitHub renders on the profile page.

## When to update

- A new public project is worth surfacing → replace the `WIP` line under **Projects**.
- The stack you actually use shifts → add or remove a badge under **Stack**.
- Contact info changes → update the placeholders under **Contact**.
- Anything else: don't touch it. Less is more on a profile.

## Sections

- **Intro** — one line. Who you are, where you are.
- **Currently** — two or three bullets max. What you're focused on right now.
- **Stack** — sober shields.io badges. Keep the list short and generic.
- **Projects** — featured public repos with a one-liner each. Stay under five.
- **Stats** — `github-readme-stats` widgets, `github_dark` theme.
- **Contact** — minimal channels. Placeholders are fine until ready.

## Theme

Dark and minimal. Keep it consistent:

- Badges: `style=flat-square`, background `0d1117` (GitHub dark), `logoColor=white`.
- Stats widgets: `theme=github_dark`, `hide_border=true`.

If you switch theme, change it in every widget URL — don't mix.

## Placeholders

Anything not yet filled is marked `<!-- TODO: ... -->`. Search the file for `TODO` before publishing changes.

## Adding a badge

Format:

```
![Name](https://img.shields.io/badge/Name-0d1117?style=flat-square&logo=<simpleicons-slug>&logoColor=white)
```

Logo slugs come from [Simple Icons](https://simpleicons.org/). Verify the slug renders before committing.

## Workflow

1. Edit `README.md`.
2. Preview locally (any markdown viewer) or in a draft PR.
3. Commit with a conventional message (`docs(profile): ...`, `chore(profile): ...`).
4. Push to `main` once happy. GitHub picks it up immediately.

## Don't

- No fun facts, no inspirational quotes.
- No emoji on every line.
- No "thanks for visiting" footers.
- No animated banners or visitor counters.
