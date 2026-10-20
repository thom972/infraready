# Séance 1 — Exercice C : inventaire prévisionnel

*Mise à jour : 19/10/2026 — statut : **prévisionnel**.*
Références : support 1 (exercice C, §2.6, fiche 5), kit (§2.1, §18.1).

> Aucun mot de passe, clé privée ou jeton dans ce document (fiche 5).

| Champ | WIN-DC01 | LINUX01 | OPS01 |
|---|---|---|---|
| Nom proposé | WIN-DC01 | LINUX01 | OPS01 |
| OS envisagé | Windows Server 2025 Standard Evaluation, Desktop Experience | Ubuntu Server 24.04 LTS | Ubuntu Server 24.04 LTS |
| Rôle | AD DS, DNS | Service Linux (à définir), node_exporter | Ansible, Prometheus, Grafana |
| vCPU / RAM / disque à prévoir | 2 / 4–6 Go / 50 Go | 2 / 2–4 Go / 30 Go | 2–4 / 4–8 Go / 50 Go |
| Adresse IP | 192.168.50.10/24 — **à définir/valider en séance 2** | 192.168.50.20/24 — **à valider** | 192.168.50.30/24 — **à valider** |
| Passerelle | Seulement si elle existe sur le réseau retenu — à valider | idem | idem |
| DNS | Lui-même après installation du rôle DNS | WIN-DC01 (192.168.50.10) | WIN-DC01 (192.168.50.10) |
| Domaine | `infraready.test` | client du domaine (DNS) | client du domaine (DNS) |
| Services attendus | AD DS, DNS, windows_exporter | Service Linux, SSH, node_exporter | SSH, Ansible, Prometheus, Grafana |
| Ports entrants envisagés | 53 (VM du labo), 9182 (OPS01), 3389 (hôte, facultatif) | 22 (hôte, OPS01), 9100 (OPS01) | 22 (hôte), 3000 et 9090 (hôte) |
| Accès d'administration | Console, RDP facultatif | SSH par compte nominatif + sudo | SSH par compte nominatif + sudo |
| Dépendances | IP fixe | DNS de WIN-DC01 | DNS de WIN-DC01, SSH vers LINUX01, exporters |
| Snapshot de référence prévu | `00-installation-propre` | `00-installation-propre` | `00-installation-propre` |

## Exercice C — questions

- **Information donnée :** noms, OS, rôles et ressources indicatives (kit §2.1, sujet §4.2).
- **Hypothèse formulée :** les ressources indicatives tiennent dans la RAM de l'hôte en laissant une
  marge pour le système hôte, et le sous-réseau proposé est libre.
- **Test futur :** relever la RAM et le disque disponibles sur l'hôte (`free -h`, `df -h`) et les
  routes existantes (`ip route`) avant de créer les VM ; après création, vérifier que les trois VM
  démarrent ensemble sans ralentir fortement l'hôte.

## Vérification par un autre binôme (fiche 5)

Question à poser : « Où se trouve la machine de supervision et de quels flux a-t-elle besoin ? »
Réponse attendue : OPS01 (192.168.50.30), qui a besoin de joindre TCP 9100 sur LINUX01,
TCP 9182 sur WIN-DC01, le DNS sur WIN-DC01 et SSH sur LINUX01 pour Ansible.
