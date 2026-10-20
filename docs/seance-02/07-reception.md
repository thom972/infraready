# Séance 2 — Étape 7 : réception des trois VM

Références : support 2 (§2.7, fiche 7, annexe A), plan de tests de la séance 1.

> **Ne cocher aucun élément sans preuve.** Un état « partiel » vaut mieux qu'une validation
> incorrecte (fiche 7). Les colonnes « Obtenu » et « Statut » se remplissent **pendant** les tests.

Statuts possibles : `OK` · `Échec` · `Partiel` · `Bloqué` · `À faire`.

## 1. Tableau de réception

| ID | Test | Source → cible | Commande | Attendu | Obtenu | Statut | Action corrective |
|---|---|---|---|---|---|---|---|
| R-01 | Nom d'hôte | LINUX01 | `hostnamectl` | `linux01` | | | |
| R-02 | Adresse active | LINUX01 | `ip -br address` | `192.168.50.20/24` sur l'interface UP | | | |
| R-03 | Route par défaut | LINUX01 | `ip route` | `default via 192.168.50.1` | | | |
| R-04 | DNS utilisé | LINUX01 | `resolvectl status` | `192.168.50.1` | | | |
| R-05 | Résolution d'un nom connu | LINUX01 | `getent hosts ubuntu.com` | Une adresse renvoyée | | | |
| R-06 | IP fixe persistante | LINUX01 | `sudo reboot` puis R-02 | Même adresse après redémarrage | | | |
| R-07 | SSH par clé depuis l'hôte | Hôte → LINUX01 | `ssh <compte>@192.168.50.20 hostname` | `linux01`, sans mot de passe de compte | | | |
| R-08 | Nom d'hôte | WIN-DC01 | `hostname` | `WIN-DC01` | | | |
| R-09 | Adresse et DNS | WIN-DC01 | `Get-NetIPConfiguration` | 192.168.50.10, passerelle .1, DNS .1 | | | |
| R-10 | Connectivité entre VM | LINUX01 → WIN-DC01 | `ping -c 3 192.168.50.10` | 0 % de perte | | | |
| R-11 | WinRM en local | WIN-DC01 | `Test-WSMan -ComputerName localhost` | Réponse WS-Management | | | |
| R-12 | Nom d'hôte et adresse | OPS01 | `hostnamectl` ; `ip -br address` | `ops01` ; `192.168.50.30/24` | | | |
| R-13 | SSH par clé depuis l'hôte | Hôte → OPS01 | `ssh <compte>@192.168.50.30 hostname` | `ops01` | | | |
| R-14 | SSH Ansible | OPS01 → LINUX01 | `ssh -i ~/.ssh/id_ed25519_ansible ansible@192.168.50.20 hostname` | `linux01` | | | |
| R-15 | Ansible | OPS01 → LINUX01 | `ansible linux -m ping` | `SUCCESS` / `pong` | | | |
| R-16 | Port WinRM autorisé | OPS01 → WIN-DC01 | `nc -zv 192.168.50.10 5985` | `succeeded` | | | |
| R-17 | Port WinRM refusé | LINUX01 → WIN-DC01 | `nc -zv -w 3 192.168.50.10 5985` | Échec (délai dépassé) | | | |
| R-18 | Nom du DC | LINUX01 | `getent hosts WIN-DC01.infraready.test` | **Échec attendu** : AD DS / DNS pas encore installés → `Partiel`, à refaire après la promotion | | | |

## 2. Checklists par machine (fiche 7)

### WIN-DC01

- [ ] Système démarré, version et fin d'évaluation relevées
- [ ] Nom `WIN-DC01` (R-08)
- [ ] IP conforme (R-09)
- [ ] DNS vérifié (résolution d'un nom externe ; DNS du domaine : séance suivante)
- [ ] Accès administrateur contrôlé (console ; WinRM limité à OPS01 : R-11, R-16, R-17)
- [ ] Mises à jour consignées (dernières KB)
- [ ] Services attendus identifiés (AD DS / DNS à installer)
- [ ] Snapshot `00-installation-propre`

### LINUX01

- [ ] Système démarré, version relevée
- [ ] Nom `linux01` (R-01)
- [ ] IP conforme et persistante (R-02, R-03, R-06)
- [ ] DNS vérifié (R-04, R-05)
- [ ] Accès administrateur contrôlé (R-07 ; compte `ansible` sans sudo)
- [ ] Mises à jour consignées
- [ ] Services attendus identifiés (SSH actif ; service applicatif à choisir)
- [ ] Snapshot `00-installation-propre`

### OPS01

- [ ] Système démarré, version relevée
- [ ] Nom `ops01`, IP conforme (R-12)
- [ ] DNS vérifié
- [ ] Accès administrateur contrôlé (R-13) ; clé Ansible protégée (`600`)
- [ ] Outils installés et versions notées (git, ansible)
- [ ] Ansible opérationnel vers LINUX01 (R-14, R-15)
- [ ] Mises à jour consignées
- [ ] Snapshot `00-installation-propre`

## 3. Captures ciblées (3 à 5, fiche 7)

1. `S02_reception_tableau.png` — ce tableau complété (ou le fichier en lui-même).
2. `S02_ops01_ansible-ping.png` — `ansible linux -m ping` réussi.
3. `S02_win-dc01_ip.png` — `Get-NetIPConfiguration`.
4. `S02_linux01_ip.png` — `ip -br address` et `ip route`.
5. `S02_win-dc01_winrm.png` — règle WinRM limitée à 192.168.50.30.

Vérifier qu'aucune capture ne montre de mot de passe, de clé privée ou de jeton.

## 4. Points à traiter à la séance suivante

- Installer AD DS et DNS sur WIN-DC01, créer `infraready.test` (kit §8).
- Basculer le DNS des VM Linux vers 192.168.50.10 et rejouer R-18.
- Faire valider les écarts E-01 à E-11 par le formateur.
- Choisir le service applicatif de LINUX01.
