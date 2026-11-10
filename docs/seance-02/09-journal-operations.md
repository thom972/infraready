# Séance 2 — Journal des opérations et difficultés

Références : support 2 (fiche 6, annexe B), kit (§18.3).

Chaque ligne indique : date et heure, auteur, machine, action, motif, état initial, résultat
**vérifié** (avec la commande de contrôle), impact, retour arrière, preuve.

**Exemple de bonne ligne** (fiche 6) : « correction de l'adresse DNS sur LINUX01 ;
`getent hosts WIN-DC01` renvoie l'adresse attendue ; accès SSH retesté. »
À éviter : « réseau réparé », « configuration terminée ».

> Les lignes ci-dessous suivent l'ordre des opérations prévues. **Compléter chaque ligne au moment
> où l'opération est faite** ; supprimer ou marquer `non réalisé` celles qui ne l'ont pas été.

| Date / heure | Auteur | Machine | Action | Motif | État initial | Résultat vérifié (commande) | Impact / redémarrage | Retour arrière | Preuve |
|---|---|---|---|---|---|---|---|---|---|
| | | Hôte | Installation de qemu-desktop, libvirt, virt-manager, dnsmasq | Hyperviseur du labo (E-01) | | `virsh list --all` | | Désinstallation des paquets | |
| | | Hôte | Création du réseau libvirt `infraready` | Réseau privé du labo (E-03) | | `virsh net-info infraready` | | `virsh net-destroy` / `net-undefine` | |
| | | LINUX01 | Création de la VM et installation d'Ubuntu Server | | | `lsb_release -a` | | Suppression de la VM | |
| | | LINUX01 | Mises à jour initiales | | | `apt list --upgradable` vide | Redémarrage : oui / non | Snapshot | |
| | | LINUX01 | IP fixe 192.168.50.20 (netplan) | Plan d'adressage |  | `ip -br address`, `ip route` | Coupure réseau brève | `/etc/netplan.backup-<date>` | S02_linux01_reception.txt |
| | | LINUX01 | Clé SSH de l'hôte ajoutée | Accès par clé | Mot de passe seul | `ssh ... hostname` sans mot de passe de compte | | Retirer la clé d'`authorized_keys` | S02_linux01_ssh-hote.txt |
| | | LINUX01 | Snapshot `00-installation-propre` | Point de retour | | Visible dans virt-manager | | — | |
| | | WIN-DC01 | Création de la VM et installation de Windows Server 2025 | | | `Get-ComputerInfo` | | Suppression de la VM | |
| | | WIN-DC01 | Installation de spice-guest-tools | Presse-papiers (E-07) | | Service « Spice Agent » démarré | Redémarrage | Désinstallation | |
| | | WIN-DC01 | Mises à jour Windows | | | `Get-HotFix` |  | Snapshot | |
| | | WIN-DC01 | Renommage en WIN-DC01 | Inventaire |  | `hostname` | Redémarrage | `Rename-Computer` | |
| | | WIN-DC01 | IP fixe 192.168.50.10, DNS .1, profil Privé | Plan d'adressage |  | `Get-NetIPConfiguration` | Coupure réseau brève | Réactiver DHCP | S02_win-dc01_ip.png |
| | | WIN-DC01 | Règle ICMP limitée au labo | Tests de connectivité | Ping bloqué | `ping` depuis LINUX01 | | `Remove-NetFirewallRule -Name InfraReady-ICMPv4-In` | |
| | | WIN-DC01 | WinRM limité à OPS01 | Administration distante (E-08) |  | R-16 OK et R-17 refusé | | Rétablir la portée initiale | S02_win-dc01_winrm.txt |
| | | OPS01 | Installation, mises à jour, IP 192.168.50.30 | | | `ip -br address` | | | S02_ops01_reception.txt |
| | | OPS01 | Installation de git et ansible | Outils d'exploitation | | `ansible --version` | | `apt remove` | S02_ops01_versions.txt |
| | | LINUX01 | Création du compte `ansible` (clé d'OPS01, sans sudo) | Automatisation (E-10) | | R-14 | | `deluser --remove-home ansible` | |
| | | OPS01 | Test `ansible linux -m ping` | Réception | | `SUCCESS` / `pong` | | — | S02_ops01_ansible-ping.txt |

## Difficultés rencontrées

| Difficulté | Cause identifiée ou hypothèse | Résolution | Temps perdu |
|---|---|---|---|
| | | | |
