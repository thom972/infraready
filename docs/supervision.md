# Supervision - Prometheus et Grafana

*Mis à jour : séance 5-6. Partie F du sujet fil rouge. Déployée par `playbooks/supervision.yml`.*

## Architecture

| Composant | Hôte | Port | Rôle | Installation |
|---|---|---|---|---|
| node_exporter | LINUX01, OPS01 | 9100 | Publie les métriques système Linux (CPU, mémoire, disques, réseau) | Paquet Ubuntu `prometheus-node-exporter` |
| windows_exporter 0.31.8 | WIN-DC01 | 9182 | Publie les métriques Windows (CPU, mémoire, disques logiques, services…) | MSI officiel (GitHub prometheus-community) |
| Prometheus | OPS01 | 9090 | **Collecte** les métriques toutes les 15 s, les stocke, **évalue les règles d'alerte** | Paquet Ubuntu `prometheus` |
| Grafana | OPS01 | 3000 | **Visualise** les métriques (tableau de bord InfraReady) | Dépôt APT officiel Grafana |

Fichiers versionnés : `monitoring/prometheus.yml` (cibles), `monitoring/alertes.yml` (règles),
`monitoring/grafana/` (source de données et fournisseur), `monitoring/dashboards/infraready.json` (tableau de bord).
Grafana est **entièrement provisionné** : aucune configuration manuelle.

## Provenance des métriques

Prometheus fonctionne en mode **pull** : c'est lui qui interroge chaque exporter.

    OPS01 (Prometheus) --HTTP GET /metrics--> LINUX01:9100   (node_exporter)
                       --HTTP GET /metrics--> OPS01:9100     (node_exporter local)
                       --HTTP GET /metrics--> WIN-DC01:9182  (windows_exporter, pare-feu limité à OPS01)
    Grafana (OPS01) --requêtes PromQL--> Prometheus (localhost:9090)

Chaque cible porte une étiquette `hote` (LINUX01, OPS01, WIN-DC01) utilisée dans les légendes du tableau de bord.
La métrique `up` vaut 1 si la dernière collecte a réussi, 0 sinon : c'est la base de l'indicateur de disponibilité.

## Tableau de bord « InfraReady - Supervision »

| Panneau | Requête PromQL (Linux / Windows) |
|---|---|
| Disponibilité | `up` |
| Processeur utilisé (%) | `100 - avg by (hote) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100` / même calcul avec `windows_cpu_time_total` |
| Mémoire utilisée (%) | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` / `(1 - windows_memory_available_bytes / windows_memory_physical_total_bytes) * 100` |
| Espace disque libre (%) | `node_filesystem_avail_bytes / node_filesystem_size_bytes * 100` (ext4, xfs) / `windows_logical_disk_free_bytes / windows_logical_disk_size_bytes * 100` (C:) |
| Alertes actives | `ALERTS{alertstate="firing"}` |

## Règles d'alerte et seuils

| Alerte | Condition | Durée | Justification |
|---|---|---|---|
| `HoteInjoignable` | `up == 0` | 1 min | Une cible qui ne répond plus est une panne ou un service arrêté |
| `EspaceDisqueFaibleLinux` | moins de 15 % libre (ext4, xfs) | 5 min | Même seuil que `verification.yml` |
| `EspaceDisqueFaibleWindows` | moins de 15 % libre sur C: | 5 min | Même seuil |
| `ProcesseurSature` | plus de 90 % de CPU (Linux) | 10 min | Évite les alertes sur des pics brefs |

La durée (`for`) évite les fausses alertes : la condition doit rester vraie pendant tout ce délai.
États successifs d'une alerte : `inactive` → `pending` (condition vraie, délai en cours) → `firing`.

## Démonstration d'un seuil (procédure)

Remplir volontairement le volume de données de LINUX01 au-delà de 85 %, observer l'alerte, puis revenir à la normale :

    ssh linux01 'df -h /srv/infraready'
    ssh linux01 'fallocate -l 4300M /srv/infraready/demo-seuil.bin && df -h /srv/infraready'
    # attendre 5 à 6 minutes : EspaceDisqueFaibleLinux passe pending puis firing
    # (Prometheus > Alerts, et tableau de bord Grafana : barre rouge + table des alertes)
    ssh linux01 'rm /srv/infraready/demo-seuil.bin && df -h /srv/infraready'
    # l'alerte se résout dès l'évaluation suivante

| Étape | Heure | Observation | Preuve |
|---|---|---|---|
| État initial | 23/10, avant 09:06 UTC | `/srv/infraready` à 1 % utilisé, 4,6 Go libres ; alerte inactive | `S06_demo-seuil.txt` |
| Fichier de démonstration créé | 09:06:58 UTC (11:06:58 Paris) | 4 300 Mo écrits : 7,68 % d'espace libre, barre rouge dans Grafana | `S06_demo-seuil.txt`, capture Grafana |
| Alerte `pending` puis `firing` | pending 09:07:13, firing 09:12:13 UTC | `pending` 15 s après l'anomalie (évaluation suivante), `firing` exactement 5 min plus tard (`for: 5m`) | `S06_alerte-firing.png`, `S06_ops01_alerte-firing.json`, `S06_ops01_chronologie-seuil.txt` |
| Fichier supprimé, alerte résolue | 09:16:28 puis 09:16:43 UTC | Alerte résolue 15 s après la suppression du fichier ; barre redevenue verte | `S06_alerte-resolue.png`, `S06_ops01_chronologie-seuil.txt` |

## Accès et sécurité

- Le paquet Ubuntu de Prometheus ne fournit que l'interface classique (`/classic/targets`, `/classic/alerts`) ; la consultation courante se fait dans Grafana.

- Prometheus : http://192.168.50.30:9090 - Grafana : http://192.168.50.30:3000 (depuis le poste du binôme, réseau du labo).
- Mot de passe administrateur Grafana : défini par le playbook depuis Ansible Vault (`inventory/group_vars/ops/vault.yml`), jamais en clair.
- Port 9182 de WIN-DC01 limité à OPS01 ; toute autre règle ouvrant ce port est désactivée par le playbook.
- **À faire (sécurité transversale)** : limiter 9100 (LINUX01, OPS01), 9090 et 3000 (OPS01) par pare-feu aux seules sources nécessaires.
