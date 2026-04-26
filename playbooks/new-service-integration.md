# Playbook — Intégrer un nouveau service tiers

Pour ajouter proprement un service externe (Stripe, Resend, Upstash,
PostHog, etc.) à un projet existant.

## 1. Décision avant code

- **Pourquoi ce service ?** Écrire le besoin en une phrase.
- **Alternatives considérées ?** (au moins une).
- **Coût** : plan gratuit suffisant ? Plafond ?
- **Vendor lock-in** : à quel point c'est réversible ?

Si les 4 questions ne trouvent pas de réponse claire → ne pas
intégrer.

## 2. Provisionnement

1. Créer le compte / projet sur le service.
2. Créer des clés API **par environnement** (dev, preview, prod).
   Jamais la même clé partout.
3. Noter les URLs, webhooks, IDs dans un coin temporaire (supprimé à la
   fin).

## 3. Variables d'environnement

- Ajouter à `.env.example` avec un commentaire sur **où trouver la
  valeur**.
- Ajouter à `src/lib/env.ts` (parsing zod) pour échouer tôt si
  manquant.
- Ajouter à Vercel (Preview + Production).
- Ajouter les noms à la section "Variables d'env" du `CLAUDE.md` du
  projet.

## 4. Wrapper

- Créer `src/lib/<service>.ts` qui expose un client typé et les
  fonctions dont on a besoin. Ne jamais utiliser le SDK brut dispersé
  dans le code.
- Gestion d'erreur : distinguer erreurs transitoires (retry) des
  erreurs finales (bubble up).
- Logs : 1 log info par opération importante, 1 log error structuré si
  échec.

## 5. Webhooks (si applicable)

- Route dédiée : `app/api/webhooks/<service>/route.ts`.
- **Vérification de signature obligatoire** avant de lire le payload.
- Idempotence : un event reçu 2 fois ne doit pas faire l'action 2 fois
  (via ID d'event stocké ou opération elle-même idempotente).
- Répondre `200` rapidement, faire le travail lourd en async si besoin.

## 6. Tests manuels

- [ ] En local avec les clés de dev, déclencher l'opération happy path.
- [ ] Déclencher un cas d'erreur (clé invalide, payload malformé) →
      comportement propre, log clair.
- [ ] Si webhooks : utiliser le CLI du service (ex: `stripe listen`)
      pour vérifier la signature.

## 7. Documentation

Dans le `CLAUDE.md` du projet, sous "Services tiers" :

```md
### <Service>
- Rôle : ...
- Clés env : <VAR_NAMES>
- Dashboard : <URL>
- Pièges : ...
```

Et dans le journal de décisions du projet (ou `memory/decisions.md`
de DB-LLM si la décision est transversale à plusieurs projets) si le
choix est structurant.

## 8. Nettoyage

- Supprimer les notes temporaires avec les clés en clair.
- Vérifier qu'aucune clé n'est committée (`git log -p` sur le fichier
  ou scanner avec `gitleaks`).

## Pièges récurrents

- **Clés partagées dev/prod** → incident en dev impacte la prod.
- **Webhook sans vérification de signature** → endpoint ouvert à
  n'importe qui.
- **Pas de wrapper** → difficile à mocker en test, difficile à changer
  de fournisseur plus tard.
- **Quota silencieux** dépassé → dégradation invisible. Toujours
  configurer une alerte budget côté provider.
