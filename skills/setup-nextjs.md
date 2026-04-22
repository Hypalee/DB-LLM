# setup-nextjs

Bootstrap d'un nouveau projet Next.js 16 aligné avec ma stack.

## Quand l'utiliser
- "Crée un nouveau projet Next.js"
- "Initialise un projet avec Neon + Better Auth"

## Inputs attendus
- Nom du projet (kebab-case)
- Domaine prévu (optionnel, peut venir plus tard)

## Procédure

### 1. Création
```bash
npx create-next-app@latest <nom> \
  --typescript --tailwind --app --eslint --src-dir \
  --import-alias "@/*"
cd <nom>
```

### 2. Dépendances de base
```bash
npm i better-auth @neondatabase/serverless drizzle-orm resend \
      @anthropic-ai/sdk zod
npm i -D drizzle-kit tsx
```

### 3. Structure
```
src/
├── app/
├── components/
├── lib/
│   ├── auth.ts        → config Better Auth
│   ├── db/
│   │   ├── index.ts   → client Drizzle + Neon
│   │   └── schema.ts  → tables
│   ├── anthropic.ts   → client Anthropic
│   └── env.ts         → parsing env via zod
└── styles/
```

### 4. Config env (`src/lib/env.ts`)
Parser strictement les variables requises avec zod. Planter tôt si une
variable manque, plutôt que de découvrir l'erreur en prod.

### 5. Better Auth
- Email + password activé.
- Plugin 2FA TOTP si projet utilisateur final.
- Vérif email via Resend (sender par défaut : `noreply@<domaine>`).
- Important : après ajout du plugin 2FA, regénérer le schéma DB
  (`twoFactor` + colonne `twoFactorEnabled` sur `user`).

### 6. Git
```bash
git init
git add -A
git commit -m "chore: initialisation projet <nom>"
gh repo create Hypalee/<nom> --private --source=. --push
```

### 7. CLAUDE.md projet
Créer `CLAUDE.md` à la racine avec :
```md
@claude-config/CLAUDE.md
@claude-config/projects/<nom>.md

## Notes spécifiques à ce projet
(à remplir au fur et à mesure)
```

Puis créer `projects/<nom>.md` dans `claude-config` (cf. template dans
`claude-config/projects/README.md`).

### 8. Deploy initial
Suivre `skills/deploy-vercel.md`.

## Pièges à éviter

- **Oublier de regénérer le schéma après ajout du plugin 2FA** →
  erreurs runtime à la première vérif 2FA.
- **`NEXT_PUBLIC_APP_URL`** manquant ou incorrect dès le départ : le
  poser dès la création du projet, même en dev (`http://localhost:3000`).
- **Tailwind v4** : config différente de v3. Pas de `tailwind.config.js`
  par défaut, tout passe par `@import` dans le CSS.

## Sortie attendue
- Repo GitHub créé et poussé.
- Projet déployé sur Vercel.
- Entrée dans `claude-config/projects/<nom>.md`.
- Entrée dans le tableau "Projets actifs" du `CLAUDE.md` global.
