# Séance 1 — Étape 4 : plan de tests prévisionnel (à exécuter en séance 2)

*Les colonnes « Résultat réel » et « Statut » restent **vides** : les tests n'ont pas encore été
exécutés (support 1, étape 3.4).*

Références : support 1 (étape 3.4, annexe A), kit (§15, §18.2).

**Ordre d'exécution** (réduit les ambiguïtés) : configuration locale → connectivité IP → route →
résolution de nom → accès au port → service.

| ID | Test (formulation observable) | Cible | Prérequis | Méthode | Résultat attendu | Limite du test | Résultat réel | Statut |
|---|---|---|---|---|---|---|---|---|
| T-01 | Le nom d'hôte de LINUX01 est celui de l'inventaire | LINUX01 | VM installée, accès console | `hostnamectl` | `Static hostname` = nom inventorié | Ne prouve pas que le nom est résolu par le DNS | | |
| T-02 | Le nom d'hôte de WIN-DC01 est `WIN-DC01` | WIN-DC01 | VM renommée et redémarrée | `hostname` | `WIN-DC01` | Idem | | |
| T-03 | LINUX01 porte l'adresse 192.168.50.20/24 sur l'interface du labo | LINUX01 | Netplan appliqué | `ip -br address` | `192.168.50.20/24` sur l'interface `UP` attendue | Une adresse configurée n'est pas forcément utilisée par un service | | |
| T-04 | WIN-DC01 porte l'adresse 192.168.50.10/24 | WIN-DC01 | IP statique configurée | `Get-NetIPConfiguration` | `IPv4Address 192.168.50.10` | Idem | | |
| T-05 | La route par défaut de LINUX01 est celle du plan (si une passerelle existe) | LINUX01 | Plan réseau validé | `ip route` | `default via <passerelle validée>` | Ne prouve pas que la passerelle achemine réellement vers Internet | | |
| T-06 | LINUX01 joint WIN-DC01 en IP | LINUX01 → WIN-DC01 | T-03, T-04 ; ICMP autorisé sur WIN-DC01 | `ping -c 3 192.168.50.10` | 3 réponses, 0 % de perte | Un échec peut venir d'un filtrage ICMP, pas d'une coupure réseau | | |
| T-07 | LINUX01 utilise le DNS prévu | LINUX01 | Netplan avec `nameservers` | `resolvectl status` | Serveur DNS = valeur de l'inventaire | Ne prouve pas que ce serveur répond | | |
| T-08 | Le nom WIN-DC01 se résout vers 192.168.50.10 | LINUX01 | DNS de WIN-DC01 opérationnel (après AD DS) | `getent hosts WIN-DC01.infraready.test` | `192.168.50.10 WIN-DC01.infraready.test` | Ne prouve pas que les enregistrements de services AD sont corrects | | |
| T-09 | Le service SSH de LINUX01 est actif et écoute | LINUX01 | OpenSSH installé | `systemctl status ssh` puis `ss -lntp \| grep :22` | `active (running)`, écoute sur 22 | Ne prouve pas que l'authentification fonctionne | | |
| T-10 | Le poste d'administration ouvre une session SSH sur LINUX01 | Hôte → LINUX01 | T-09, compte nominatif | `ssh <compte>@192.168.50.20` | Session ouverte, sans afficher de secret | Prouve l'accès pour ce compte depuis cette source seulement | | |
| T-11 | Un port de service Windows est joignable depuis le labo | OPS01 → WIN-DC01 | Service et règle de pare-feu en place | `nc -zv 192.168.50.10 <port>` | `succeeded` / `open` | Port ouvert ≠ service applicatif fonctionnel | | |

## Règles d'exécution (séance 2)

- Noter l'**heure**, la **commande exacte** et la **sortie pertinente** de chaque test.
- En cas d'échec : ne modifier **qu'un paramètre à la fois**, puis rejouer le test.
- Les preuves sont nommées `S02_<machine>_<test>.txt` ou `.png` et rangées dans `docs/preuves/`.
