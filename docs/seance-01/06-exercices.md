# Séance 1 — Exercices et fiches de contrôle

Références : support 1 (§4, fiches 2, 3, 4 et 6). Exercice A : voir
[`03-architecture.md`](03-architecture.md). Exercice C : voir
[`04-inventaire-previsionnel.md`](04-inventaire-previsionnel.md).

## Exercice B — distinguer les couches de diagnostic

| Symptôme | Test adapté | Ce que le test permet de conclure | Conclusion que le test **ne permet pas** de tirer |
|---|---|---|---|
| Adresse IP inaccessible | `ping -c 3 <IP>` puis `ip route` | Si le ping répond : la couche IP fonctionne entre les deux machines | Si le ping échoue : que la machine est éteinte (ICMP peut être filtré) |
| Nom non résolu | `getent hosts <nom>` / `Resolve-DnsName <nom>`, comparé à un test par IP | Si l'IP répond mais pas le nom : le problème est le DNS | Que le serveur DNS est arrêté (il peut répondre, mais sans l'enregistrement) |
| Port fermé | `nc -zv <IP> <port>` / `Test-NetConnection <IP> -Port <port>` | Si la connexion TCP aboutit : un processus écoute et le pare-feu laisse passer | Que l'application fonctionne correctement (le port peut être ouvert et le service en erreur) |
| Service arrêté | `systemctl status <svc>` / `Get-Service <svc>` puis les journaux | L'état du service et la raison de l'arrêt dans les journaux | Que le service est joignable à distance une fois redémarré (pare-feu, écoute locale seulement) |

- **Information donnée :** quatre symptômes de couches différentes.
- **Hypothèse :** chaque symptôme correspond à une couche distincte qu'il faut isoler dans l'ordre
  IP → nom → port → service.
- **Test futur :** en séance 2, reproduire volontairement un symptôme contrôlé (par exemple
  un DNS mal configuré) et vérifier que la séquence localise bien la couche fautive.

## Fiche 3 — passerelle

**Pourquoi une passerelle n'est pas toujours nécessaire :** deux VM du même sous-réseau
(192.168.50.0/24) communiquent directement : chacune sait, grâce au masque, que l'autre est sur le
même réseau et la joint au niveau Ethernet (ARP). **Elle devient nécessaire** pour atteindre une
adresse hors du sous-réseau (Internet, un autre réseau) : la machine envoie alors le trafic à la
passerelle, qui le route. On ne déclare donc une passerelle que si elle existe réellement (kit §6.1).

## Fiche 4 — connectivité, DNS et service

Situation fictive : depuis LINUX01, `ping 192.168.50.10` répond, mais `getent hosts WIN-DC01.infraready.test` ne renvoie rien.

| Test | Résultat (fictif) | Conclusion permise | Conclusion non permise |
|---|---|---|---|
| `ping -c 3 192.168.50.10` | Réponses reçues | La connectivité IP fonctionne | Que le service DNS de WIN-DC01 fonctionne |
| `getent hosts WIN-DC01.infraready.test` | Aucun résultat | La résolution de ce nom échoue depuis LINUX01 | Que WIN-DC01 est en panne |
| `resolvectl status` | DNS = résolveur public | **Hypothèse DNS prioritaire** : LINUX01 n'interroge pas le DNS du domaine | Que le serveur DNS de WIN-DC01 est correct |

## Fiche 6 — incident théorique : OPS01 ne collecte pas les métriques de LINUX01

| Hypothèse | Test discriminant | Résultat qui renforce l'hypothèse | Résultat qui l'écarte |
|---|---|---|---|
| H1 — node_exporter est arrêté sur LINUX01 | Sur LINUX01 : `systemctl status node_exporter` puis `curl -s localhost:9100/metrics \| head` | Service inactif, curl refusé | Service actif et métriques affichées en local |
| H2 — adresse ou port erroné dans la configuration Prometheus | Sur OPS01 : relire la cible dans `prometheus.yml`, comparer à l'inventaire | Cible ≠ `192.168.50.20:9100` | Cible conforme |
| H3 — le port 9100 est filtré entre OPS01 et LINUX01 | Sur OPS01 : `curl -s http://192.168.50.20:9100/metrics \| head` alors que H1 est écartée | Délai dépassé ou refus depuis OPS01, mais OK en local | Métriques reçues depuis OPS01 |
| H4 — nom incorrect (si la cible utilise un nom DNS) | Sur OPS01 : `getent hosts <nom de la cible>` | Nom non résolu ou mauvaise IP | Nom résolu vers 192.168.50.20 |

Le rapport distinguera : faits observés, hypothèses, cause confirmée, correction, prévention.
Sans preuve, on écrit « cause probable » et la vérification manquante.
