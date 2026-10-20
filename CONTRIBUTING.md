# Conventions de travail

## Messages de commit

Format : `type(portée): description à l'infinitif, en français`

| Type | Usage |
|---|---|
| `docs` | Documentation, livrables, procédures |
| `feat` | Nouveau fichier de configuration, script, inventaire |
| `fix` | Correction d'une configuration ou d'un document erroné |
| `test` | Ajout de preuves de tests (sorties de commandes, captures) |
| `chore` | Maintenance du dépôt (.gitignore, structure) |

Portées utilisées : `s1`, `s2` (livrables de séance), `infra` (hôte, réseau virtuel),
`linux01`, `ops01`, `windows`, `ansible`, `scripts`.

Exemples :

```
docs(s1): ajouter la matrice des besoins du SI
feat(linux01): ajouter la configuration netplan statique
test(s2): ajouter les preuves de réception de LINUX01
fix(ops01): corriger le nom d'interface dans netplan
```

## Règles

1. **Un commit = une modification logique.** Pas de commit « divers » qui mélange réseau, docs et scripts.
2. **Relire avant de committer** : `git diff --staged`. Vérifier qu'aucun secret n'apparaît.
3. **Les preuves sont réelles.** On ne committe jamais un résultat « observé » qui n'a pas été observé.
   Un test non réalisé reste vide ou marqué `à faire` / `bloqué`.
4. **Une étiquette par séance terminée** : `v0.1-seance1`, `v0.2-seance2`, etc.
5. **Les deux membres du binôme committent** sous leur propre identité Git.
6. Un écart par rapport au kit ou au sujet est consigné dans `docs/ecarts-et-decisions.md`
   dans le même commit que la modification qui l'introduit.
