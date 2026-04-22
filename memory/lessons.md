# Leçons

Leçons générales, pas liées à un bug ponctuel. Méta-règles, patterns,
tendances observées dans ma façon de travailler.

---

### Préférer supprimer plutôt qu'ajouter
Quand je me surprends à ajouter une couche d'abstraction ou un flag
pour "supporter les deux cas", c'est presque toujours le signe qu'il
faut au contraire supprimer l'ancien chemin. Le code qui n'existe pas
n'a jamais de bug.

---

### Tester l'UI dans un navigateur, vraiment
Un changement UI qui compile, passe TypeScript, passe les tests, peut
toujours être cassé visuellement ou comportementalement. Si je ne peux
pas tester (ex: pas d'accès navigateur en CLI), **le dire
explicitement** plutôt que marquer comme fait.

---

### Les commits en français forcent à expliquer le "pourquoi"
Écrire `fix(auth): corrige la double redirection après login` oblige à
identifier précisément ce qui se passait. Un `fix: bug` en anglais est
trop facile, trop vague.

---

### Une session = un objectif
Quand je dérive vers 2-3 tâches en parallèle dans la même session
Claude, je finis avec un diff mal découpé et des commits fourre-tout.
Mieux vaut finir une chose, commit, puis ouvrir une nouvelle session.

---

### Le `memory/` vaut par sa fraîcheur
Une entrée écrite 3 jours après le bug est déjà moins précise qu'une
entrée écrite le jour même. Prendre l'habitude de noter **pendant** la
session, pas après.

---

### Objectif d'apprentissage : devenir autonome sur l'écosystème IA
Se spécialiser dans l'usage avancé de Claude Code et des LLMs : skills,
workflows, hooks, multi-agent, API Anthropic. Je suis débutant mais
motivé. Claude doit m'expliquer les concepts au fur et à mesure, avec
le vocabulaire exact, sans survol.

Direction à moyen terme :
1. Maîtriser settings.json / hooks / agents / skills de Claude Code.
2. Apprendre à écrire des prompts système pour agents spécialisés.
3. Construire avec l'API Anthropic (prompt caching, tool use, batch).

---

### Préférence device : mobile (transports matin/soir)
J'utilise Claude Code sur téléphone dans les transports. Sur mobile, le
sélecteur de modèle n'est pas accessible quand je reprends une session.
→ `model: "claude-opus-4-7"` posé globalement dans `~/.claude/settings.json`
pour que les **nouvelles sessions** démarrent toujours sur Opus 4.7.

Limite connue : le modèle des sessions déjà ouvertes n'est pas réécrit
par cette config. Si une session reprend sur un autre modèle, ouvrir
une nouvelle session est le plus simple.
