# Rapport d'incident - Absence de métriques de LINUX01

*Partie H du sujet fil rouge. Date : 23/10/2026. Heures en UTC (heure de Paris = UTC + 2).*

> **Nature de l'incident** : incident **provoqué volontairement** pour l'exercice, de façon contrôlée et
> réversible : une règle de pare-feu temporaire (table `nftables` dédiée `incident`) bloquant le port 9100
> de LINUX01. Le diagnostic a été mené comme si la cause était inconnue.

## Résumé

| Élément | Valeur |
|---|---|
| Service affecté | Collecte des métriques de LINUX01 (node_exporter, port 9100) par Prometheus |
| Impact | Plus aucune métrique de LINUX01 dans Prometheus et Grafana pendant 4 min 30 s ; le serveur et ses services (SSH, Nginx) restent disponibles |
| Détection | Automatique : cible `DOWN` puis alerte `HoteInjoignable` |
| Cause | Règle de pare-feu `tcp dport 9100 drop` sur LINUX01 |
| Correction | Suppression de la table `nftables` `incident` |
| Durée | 09:34:03 → 09:38:33 (anomalie observée), alerte résolue à 09:38:48 |

## Chronologie

| Heure (UTC) | Événement | Source |
|---|---|---|
| 09:28:18 | État initial : 4 cibles `UP`, aucune alerte | `S07_etat-initial.txt`, capture Grafana |
| *à compléter* | Ajout de la règle de pare-feu (début de l'incident) | Heure affichée par la commande de provocation |
| 09:34:03 | Première collecte en échec : `up{hote="LINUX01"} == 0` | `S07_ops01_chronologie-incident.txt` |
| 09:34:18 | Alerte `HoteInjoignable` en **pending** (évaluation suivante, + 15 s) | idem |
| 09:35:18 | Alerte en **firing** (exactement 1 min plus tard : `for: 1m`) | idem, capture |
| 09:3x | Diagnostic depuis OPS01 puis sur LINUX01 | `S07_ops01_diagnostic.txt`, `S07_linux01_diagnostic.txt` |
| 09:38:31 | Correction : suppression de la table `incident` | `S07_linux01_diagnostic.txt` (sortie de correction) |
| 09:38:33 | Dernière collecte en échec ; la suivante réussit | `S07_ops01_chronologie-incident.txt` |
| 09:38:48 | Alerte **résolue** (évaluation suivante, + 15 s) | idem |

## 1. Symptôme observé

- Grafana : la case **LINUX01 - linux** passe de `UP` à `DOWN` (rouge).
- Prometheus (`/classic/targets`) : cible `192.168.50.20:9100` en `DOWN`, erreur
  `Get "http://192.168.50.20:9100/metrics": context deadline exceeded` (délai de collecte dépassé).
- Alerte `HoteInjoignable` (`up == 0` pendant 1 min) en `firing`, visible dans Prometheus et dans Grafana.

## 2. Tests et journaux consultés

Ordre suivi : du réseau vers le service, du point de vue de Prometheus (OPS01) puis sur la machine (LINUX01).

| # | Test | Commande | Résultat | Conclusion permise |
|---|---|---|---|---|
| 1 | Connectivité IP depuis OPS01 | `ping -c 2 192.168.50.20` | 2/2 reçus, 0 % de perte | La machine est joignable : pas de panne réseau ni de VM éteinte |
| 2 | Port 9100 depuis OPS01 | `curl -m 5 http://192.168.50.20:9100/metrics` | `Connection timed out after 5002 ms` (code 28) | Le **port** ne répond pas : la panne est au niveau de l'accès au service |
| 3 | Erreur vue par Prometheus | API `/api/v1/targets` | `context deadline exceeded` | Confirme le délai dépassé (et non un refus de connexion) |
| 4 | État du service | `systemctl is-active prometheus-node-exporter` | `active` | Le service n'est **pas** arrêté |
| 5 | Écoute | `ss -lnt \| grep 9100` | `LISTEN *:9100` | Le service écoute sur toutes les interfaces |
| 6 | Métriques en local | `curl -m 5 localhost:9100/metrics` | **Aucune réponse** (délai dépassé) | Même en local, le port ne répond pas : un **filtrage sur la machine elle-même** est probable |
| 7 | Journaux du service | `journalctl -u prometheus-node-exporter` | Aucune erreur pendant l'incident (les seules erreurs `broken pipe` datent de 09:26, avant l'incident, causées par des tests `curl \| head -1` antérieurs) | Le service ne signale pas de problème |
| 8 | Pare-feu local | `nft list ruleset` | Table `inet incident`, chaîne `input` : **`tcp dport 9100 drop`** | **Cause confirmée** |

Hypothèses examinées :

| Hypothèse | Test discriminant | Verdict |
|---|---|---|
| VM éteinte ou réseau coupé | Test 1 | Écartée |
| Service node_exporter arrêté | Tests 4 et 5 | Écartée |
| Service bloqué ou en erreur | Test 7 | Écartée |
| Filtrage réseau sur LINUX01 | Tests 2, 3, 6 puis 8 | **Confirmée** |

Le délai dépassé (et non « connexion refusée ») orientait vers un filtrage : une règle `drop` ignore les
paquets sans répondre, alors qu'un service arrêté produit un refus immédiat. La règle s'appliquant à toute
l'entrée de la machine, y compris l'interface de bouclage, le test local échouait aussi : c'est ce qui
désignait la machine elle-même plutôt que le chemin réseau entre OPS01 et LINUX01.

## 3. Cause identifiée

Une règle `nftables` dans une table dédiée `incident` rejetait silencieusement (`drop`) tout trafic TCP
entrant vers le port 9100 de LINUX01. node_exporter fonctionnait normalement, mais Prometheus ne pouvait
plus le joindre.

## 4. Correction appliquée

    sudo nft delete table inet incident

Correction limitée à l'élément fautif : seule la table `incident` est supprimée, sans modifier d'autre règle.

## 5. Vérification du retour à la normale

| Vérification | Résultat |
|---|---|
| `curl http://192.168.50.20:9100/metrics` depuis OPS01 | Première ligne de métriques reçue (`# HELP apt_autoremove_pending …`) |
| Cible LINUX01 dans Prometheus et Grafana | De nouveau `UP` après 09:38:33 |
| Alerte `HoteInjoignable` | Résolue à 09:38:48 |

Preuves : `S07_ops01_retour-normale.txt` (première ligne de métriques reçue), `S07_ops01_chronologie-incident.txt`,
captures `S07_grafana-retour-normale.png` (4 cibles `UP`) et `S07_prometheus-retour-normale.png` (4 règles inactives).
La capture `S07_prometheus-pending.png` affiche `Active Since 09:34:09.9 UTC` ; la chronologie, reconstituée par
`scripts/linux/chronologie-alerte.py` et calée sur les évaluations toutes les 15 s, indique 09:34:18.

## Enseignements et prévention

1. **La supervision a détecté seule l'incident**, avec le délai prévu : cible `DOWN` en 15 s, alerte `firing`
   1 min 15 après le début. Le paramètre `for: 1m` évite d'alerter sur une seule collecte manquée.
2. **Les contrôles locaux ne suffisent pas** : `verification.yml` s'exécute sur la machine elle-même et ne voit
   pas un filtrage entre le serveur de supervision et la cible. Les deux approches sont complémentaires.
   *Amélioration possible* : ajouter à `verification.yml` une vérification de l'état des cibles via l'API de Prometheus.
3. **Toute règle de pare-feu doit être versionnée et documentée** (`docs/securite.md`) : une règle ajoutée à la main,
   sans trace, est exactement le type de changement qui provoque ce genre d'incident. Les règles du laboratoire
   seront gérées par Ansible (étape sécurité).
4. **Attention aux codes de retour dans les pipelines** : `curl … | head -1; echo $?` affiche le code de `head`
   (0), pas celui de `curl` (28). Le message d'erreur de `curl` faisait foi ; en Bash, `${PIPESTATUS[0]}` donne
   le code de la première commande.
