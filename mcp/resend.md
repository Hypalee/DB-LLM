# MCP — Resend

## Service

Resend : envoi d'emails transactionnels (vérif email, reset password,
notifications). Domaine envoyeur : `<domaine.tld>`.

## Statut

**Officiel** — maintenu par Resend. Plusieurs modes d'exécution.

## Modes disponibles

- **Remote HTTP** (le plus simple, équivalent Neon/Vercel) :
  endpoint hosted par Resend.
- **Local stdio** : le MCP tourne en local, lancé par Claude Code à
  la demande. Utile si tu veux zéro dépendance réseau au MCP.

Pour mon usage solo mobile-first : **remote HTTP**.

## Capacités

### Envoi

- Envoyer un email (HTML, plain text, pièces jointes locales / URL /
  base64, CC/BCC, reply-to).
- Scheduler un envoi (date future).
- Tagger un email (pour filtrage dans le dashboard).
- Envoi batch.

### Inbound

- Lister les emails reçus.
- Lire le contenu d'un email reçu.
- Télécharger les pièces jointes reçues.

### Contacts & segments

- CRUD contacts.
- Gérer l'appartenance à des segments / topics.
- Custom properties.

### Broadcasts (campagnes)

- Créer, envoyer, lister, mettre à jour, supprimer des campagnes.

### Webhooks

- CRUD webhooks pour notifications d'événements (delivered, bounced,
  opened, etc.).

## Authentification

Clé API Resend. Stockée en env var (`RESEND_API_KEY`).

## Setup

Voir la doc officielle `resend.com/mcp` ou `resend.com/docs/mcp-server`
pour les commandes exactes selon le mode choisi. Elles évoluent plus
vite que cette fiche.

## Conventions d'usage

1. **Toujours utiliser l'expéditeur `noreply@<domaine.tld>`** pour
   les emails transactionnels <projet>. Pour un nouveau projet, utiliser
   le domaine propre à ce projet.
2. **Tagger les envois** (`tag: "signup-verif"`, `tag: "password-reset"`)
   pour pouvoir filtrer / debugger dans le dashboard Resend.
3. **Tester sur une adresse jetable d'abord** avant tout envoi à un
   client/utilisateur réel.
4. **Ne pas utiliser le MCP pour des envois de masse en prod** sans
   confirmation explicite. Un agent qui envoie 1000 emails en
   autonomie = incident.

## Pièges

- **DNS pas encore propagé** : après l'ajout d'un domaine dans Resend,
  SPF/DKIM/DMARC mettent 5-30 min à se valider. Attendre avant les
  premiers envois.
- **Quota free plan** : vérifier les limites avant une session
  d'envois intenses.
- **Rate limits** : le MCP respecte l'API Resend, donc attention aux
  boucles d'envois dans un script.

## Docs

- [Send emails with MCP · Resend](https://resend.com/mcp)
- [MCP Server Docs](https://resend.com/docs/mcp-server)
- [GitHub PSU3D0/resend-mcp (alternative communautaire)](https://github.com/PSU3D0/resend-mcp)
