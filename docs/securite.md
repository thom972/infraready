# Sécurité et gestion des accès

*Mis à jour : séance 8. Mesures appliquées par `playbooks/securite.yml` (sauf mention contraire).*

## Secrets

- Mots de passe (comptes Linux, Administrateur Windows, DSRM, `svc-ansible`, Grafana) : **uniquement** dans le
  gestionnaire de mots de passe du binôme et, pour l'automatisation, dans trois coffres **Ansible Vault** chiffrés
  en AES256 : `inventory/group_vars/linux/vault.yml`, `ops/vault.yml`, `windows/vault.yml` (contenu : [`ansible.md`](ansible.md#secrets--trois-coffres-ansible-vault)).
  Le mot de passe du coffre est saisi à l'exécution (`--ask-vault-pass`), jamais écrit.
- Tâches manipulant un mot de passe : `no_log: true`. Le mot de passe Grafana passé en ligne de commande est
  protégé par le filtre `quote`.
- Clés privées SSH : sur le poste qui les utilise (hôte pour l'administration, OPS01 pour Ansible),
  droits `600`, protégées par phrase de passe. Les clés publiques seules sont copiées sur les cibles.
- Avant chaque commit : `git diff --staged` relu ; le `.gitignore` bloque ISO, disques et clés.
- Contrôle automatique à chaque push : chiffrement des trois coffres vérifié et recherche de secrets dans tout
  l'historique (gitleaks : aucun secret trouvé au 10/11/2026).

## Comptes et privilèges

| Machine | Compte | Usage | Authentification | Privilèges |
|---|---|---|---|---|
| LINUX01, OPS01 | `keo` (nominatif) | Administration | Clé SSH (mot de passe en secours console) | sudo avec mot de passe |
| LINUX01 | `ansible` | Automatisation depuis OPS01 | **Clé SSH uniquement** : connexion par mot de passe refusée (`Match User ansible`) | sudo **avec** mot de passe (coffre `linux`) |
| WIN-DC01 | `Administrateur` | Administration manuelle | Mot de passe robuste | Admins du domaine |
| WIN-DC01 | `svc-ansible` | Automatisation WinRM depuis OPS01 | Mot de passe (coffre `windows`), NTLM | Admins du domaine, **non délégable** (E-15) |
| Domaine | comptes de test | Tests d'accès au partage | Mot de passe initial (coffre `windows`) | Selon leurs groupes : [`comptes-et-droits.md`](comptes-et-droits.md) |

Pas de connexion root directe en SSH (comportement par défaut d'Ubuntu). Les droits sont donnés à des
**groupes** (AD : `GG-Admins-Infra`, `GG-Utilisateurs-Lab` ; Linux : `infraready`), jamais directement aux comptes.

### sudo du compte `ansible` (E-14 résolu)

De la séance 3 (premier playbook avec sudo) à la séance 7, `ansible` disposait d'un sudo sans mot de passe
(`NOPASSWD`) : quiconque obtenait sa clé SSH devenait root sur LINUX01. Depuis la séance 8 :

- `/etc/sudoers.d/90-ansible` : `ansible ALL=(ALL:ALL) ALL`, mode `0440`, validé par `visudo -cf` avant écriture ;
- le mot de passe vient du coffre `linux` (au moins 12 caractères, vérifié par le playbook) ;
- `/etc/ssh/sshd_config.d/20-ansible.conf` interdit toute authentification par mot de passe à ce compte
  (`sshd -t` avant rechargement) : il faut **la clé et le mot de passe** pour devenir root ;
- contrôles automatiques : `sudo -n true` échoue, l'élévation avec le mot de passe du coffre donne `root`,
  `sshd -T` confirme `passwordauthentication no` pour `ansible`.

Ansible utilise le sudo d'origine (`sudo.ws`) sur LINUX01 et OPS01 : sudo-rs d'Ubuntu 26.04 modifie l'invite de
mot de passe qu'Ansible attend (E-17).

### `svc-ansible` (E-15, risque accepté)

Le compte crée des OU, des groupes, des comptes et des partages : il est membre de « Admins du domaine ».
Une délégation limitée à `OU=InfraReady` est la bonne pratique ; elle n'est pas faite. Mesures compensatoires :
compte marqué **« sensible et non délégable »** (`AccountNotDelegated`, ses jetons ne peuvent pas être relayés),
connexion WinRM acceptée **depuis OPS01 seulement**, transport NTLM chiffré, mot de passe uniquement dans le coffre,
`no_log` sur les tâches sensibles. Détail : [`ecarts-et-decisions.md`](ecarts-et-decisions.md).

## Pare-feu des serveurs Linux (ufw)

Politique : **refus par défaut en entrée**, sortie autorisée (mises à jour, DNS, WinRM, collecte), journalisation
des refus au niveau `low` (`/var/log/ufw.log`). Les règles sont des variables versionnées
(`regles_pare_feu` dans `inventory/group_vars/linux/vars.yml` et `ops/vars.yml`) : aucune règle n'est ajoutée à la main.

| Hôte | Port TCP | Source autorisée | Motif |
|---|---|---|---|
| LINUX01 | 22 | 192.168.50.1 (hôte) | SSH d'administration |
| LINUX01 | 22 | 192.168.50.30 (OPS01) | SSH d'Ansible |
| LINUX01 | 80 | 192.168.50.0/24 | Nginx depuis le labo |
| LINUX01 | 9100 | 192.168.50.30 (OPS01) | Collecte node_exporter par Prometheus |
| OPS01 | 22 | 192.168.50.1 (hôte) | SSH d'administration |
| OPS01 | 3000 | 192.168.50.1 (hôte) | Grafana |
| OPS01 | 9090 | 192.168.50.1 (hôte) | Prometheus |

Prometheus collecte le node_exporter d'OPS01 par `localhost` : l'interface de bouclage est toujours autorisée.

Ordre d'application : les flux nécessaires sont autorisés **avant** l'activation du pare-feu, une machine à la fois
(`serial: 1`), pour ne jamais couper la session SSH d'Ansible. Retour arrière depuis la console de la VM : `sudo ufw disable`.

## Pare-feu de WIN-DC01 (pare-feu Windows)

| Port | Source autorisée | Motif | Géré par |
|---|---|---|---|
| TCP 5985 (WinRM) | 192.168.50.30 (OPS01) | Ansible | `scripts/windows/Set-WinRMLabScope.ps1` (E-08) |
| TCP 9182 | 192.168.50.30 (OPS01) | Collecte windows_exporter ; toute autre règle sur 9182 désactivée | `supervision.yml` |
| TCP/UDP 53 (DNS) | 192.168.50.0/24 | Résolution du domaine pour le labo | `securite.yml` |
| TCP 445 (SMB) | 192.168.50.0/24 | Partage `Lab`, SYSVOL/NETLOGON | `securite.yml` |
| ICMP echo | 192.168.50.0/24 | Tests de connectivité | installation (séance 2) |

RDP n'est pas activé (E-09) : la console SPICE suffit.

## Matrice des flux (état séance 8)

| Source | Destination | Port | Motif |
|---|---|---|---|
| Hôte | LINUX01, OPS01 | TCP 22 | Administration SSH |
| Hôte | OPS01 | TCP 3000, 9090 | Grafana, Prometheus |
| OPS01 | LINUX01 | TCP 22 | Ansible |
| OPS01 | LINUX01 | TCP 9100 | Collecte des métriques |
| OPS01 | WIN-DC01 | TCP 5985 | WinRM (Ansible) |
| OPS01 | WIN-DC01 | TCP 9182 | Collecte des métriques |
| VM du labo | WIN-DC01 | 53, 445, ICMP | DNS, SMB, tests |
| VM du labo | LINUX01 | TCP 80 | Nginx |
| VM du labo | Internet via NAT | TCP 80, 443, DNS | Mises à jour (miroirs APT, Windows Update) |

Vérifications versionnées : `docs/preuves/S08_hote_tests-pare-feu.txt` (depuis l'hôte : SSH et Grafana autorisés,
node_exporter de LINUX01 refusé) ; `securite.yml` vérifie à chaque passage les flux autorisés depuis OPS01 et le refus
de 9090 et 3000 depuis LINUX01 (`S08_ops01_pare-feu-run1.txt`, `-run2.txt`).

## Sécurité des opérations

- **Partitionnement et formatage** : le disque est désigné par son numéro de série ; `stockage.yml` s'arrête si la
  cible est absente ou porte la racine, et ne reformate jamais (`force: false`). Voir [`stockage.md`](stockage.md).
- **Changements majeurs** : snapshot de la VM concernée, simulation `--check --diff`, une machine à la fois.
- **Rejeu** : les playbooks sont idempotents (second passage `changed=0`), donc sans effet sur un système conforme.
- **Mises à jour** : jamais de redémarrage implicite ; WIN-DC01 en dernier. Voir [`maintenance.md`](maintenance.md).

## Interdits

- Désactiver globalement un pare-feu (Windows ou ufw) pour « faire marcher » une connexion.
- `TrustedHosts = *`, authentification Basic ou `AllowUnencrypted` pour WinRM.
- Créer une règle « autoriser tout » au lieu de diagnostiquer le flux précis.
- Ajouter une règle de pare-feu à la main sans la versionner (cause de l'incident simulé : [`incident.md`](incident.md)).
- Scanner ou tester des systèmes extérieurs au laboratoire.
