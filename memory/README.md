# memory/

Mémoire persistante entre sessions Claude. Trois fichiers, trois usages
distincts.

## Fichiers

- [`decisions.md`](./decisions.md) — **Décisions architecturales**
  prises, avec date et raisonnement. Permet de ne pas les rediscuter
  tous les 3 jours.
- [`gotchas.md`](./gotchas.md) — **Pièges** rencontrés : bugs subtils,
  comportements non documentés, trucs qui ont pris plus de temps que
  prévu. Une ligne = une heure économisée plus tard.
- [`lessons.md`](./lessons.md) — **Leçons plus générales**, pas liées à
  un bug précis : patterns qui marchent, patterns à éviter, méta-règles
  sur ma façon de travailler.

## Règle d'or

Ces fichiers sont **append-only en esprit** : on ajoute, on corrige,
mais on ne supprime une entrée que si elle est obsolète (et alors on
explique pourquoi dans l'entrée qui la remplace).

## Quand écrire ici

À la fin d'une session où :
- une décision non triviale a été prise ;
- un bug subtil a été identifié ou résolu ;
- une leçon émergente mérite d'être capturée.

Voir `WORKFLOW.md` pour le rituel post-session.
