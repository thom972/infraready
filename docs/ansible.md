# Automatisation Ansible - InfraReady

*Mis à jour : séance 5 (réorganisation du dépôt selon le §7 du sujet).*

Toutes les commandes se lancent **depuis la racine du dépôt**, sur **OPS01** (contrôleur Ansible),
dans le clone Git `~/infraready` : le fichier `ansible.cfg` y désigne l'inventaire et les options.

## Structure

    infraready/
    ├── ansible.cfg                      inventaire, pipelining
    ├── inventory/
    │   ├── hosts.yml                    hôtes et groupes (aucun secret)
    │   ├── group_vars/
    │   │   ├── all.yml                  seuil d'espace libre commun
    │   │   ├── linux.yml                LINUX01 : élévation, Nginx, services et volumes surveillés
    │   │   ├── ops.yml                  OPS01 : exécution locale, sudo d'origine (E-17)
    │   │   └── windows/
    │   │       ├── vars.yml             connexion WinRM (NTLM, port 5985), services surveillés
    │   │       ├── ad.yml               annuaire (OU, groupes, comptes) et partage Lab
    │   │       └── vault.yml            secrets CHIFFRÉS (Ansible Vault)
    │   └── host_vars/
    │       └── LINUX01.yml              disque de données INFRA-DATA, montage /srv/infraready
    └── playbooks/
        ├── linux.yml                    configuration complète de LINUX01 (importe nginx.yml + stockage.yml)
        ├── nginx.yml                    service web
        ├── stockage.yml                 disque de données, montage persistant, droits
        ├── windows.yml                  annuaire et partage sur WIN-DC01
        ├── verification.yml             contrôles en lecture seule (services, disque, HTTP)
        └── maintenance.yml              vérification → mises à jour → vérification

## Inventaire

| Groupe | Hôte | Connexion | Compte | Élévation de privilèges |
|---|---|---|---|---|
| `linux` (dans `serveurs_linux`) | LINUX01 (192.168.50.20) | SSH, clé `~/.ssh/id_ed25519_ansible` | `ansible` | sudo sans mot de passe (temporaire, E-14) |
| `ops` (dans `serveurs_linux`) | OPS01 | locale | `keo` | sudo **avec** mot de passe (`-K`), via `sudo.ws` (E-17) |
| `windows` | WIN-DC01 (192.168.50.10) | WinRM HTTP 5985, NTLM | `svc-ansible@infraready.test` | compte de domaine (E-15) |

## Prérequis sur OPS01

| Élément | Installation / vérification |
|---|---|
| Ansible core 2.20 et collections `ansible.windows`, `microsoft.ad`, `community.general`, `ansible.posix` | `sudo apt install ansible` (collections fournies par le paquet) ; `ansible-galaxy collection list` |
| Bibliothèque WinRM | `sudo apt install python3-winrm` |
| Clé SSH d'automatisation | `~/.ssh/id_ed25519_ansible` (droits `600`, phrase de passe), clé publique dans `~ansible/.ssh/authorized_keys` sur LINUX01 |
| Mot de passe du coffre | dans le gestionnaire de mots de passe du binôme, **jamais** dans le dépôt |

Avant chaque session : `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible`.

## Playbooks

| Playbook | Cible | Rôle | Commande |
|---|---|---|---|
| `linux.yml` | LINUX01 | Nginx + volume de données | `ansible-playbook playbooks/linux.yml` |
| `nginx.yml` | groupe `linux` | Installe Nginx, service actif et activé au démarrage | `ansible-playbook playbooks/nginx.yml` |
| `stockage.yml` | LINUX01 | Disque `INFRA-DATA` → ext4 → `/srv/infraready` (fstab par UUID), groupe `infraready`, tests d'écriture | `ansible-playbook playbooks/stockage.yml` |
| `windows.yml` | WIN-DC01 | OU, groupes, comptes de test, partage `Lab` (NTFS + SMB), vérifications | `ansible-playbook playbooks/windows.yml --ask-vault-pass` |
| `verification.yml` | tous | Services critiques, espace disque (seuil 15 %), volumes montés, HTTP | `ansible-playbook playbooks/verification.yml -K --ask-vault-pass` |
| `maintenance.yml` | tous | Mises à jour Linux une machine à la fois, recherche Windows, vérifications avant/après | `ansible-playbook playbooks/maintenance.yml -K --ask-vault-pass` (ajouter `-e autoriser_redemarrage=true` pour autoriser un redémarrage requis) |

## Procédure standard d'exécution

1. Vérifier la syntaxe : `ansible-playbook playbooks/<nom>.yml --syntax-check`.
2. Vérifier les cibles : `ansible-playbook playbooks/<nom>.yml --list-hosts`.
3. Exécuter, puis relire le PLAY RECAP (`failed=0`, `unreachable=0`).
4. **Relancer** : la seconde exécution doit afficher `changed=0` (idempotence).

Chaque playbook de configuration se termine par des **vérifications après exécution** (`assert`, tests réels
d'écriture, lecture des droits du partage) : un état incorrect fait échouer l'exécution au lieu de passer inaperçu.

## Secrets (Ansible Vault)

`inventory/group_vars/windows/vault.yml` est chiffré (AES256) et peut être versionné. Il contient
le mot de passe de connexion du compte `svc-ansible` et le mot de passe initial des comptes de test.

    EDITOR=nano ansible-vault edit inventory/group_vars/windows/vault.yml   # modifier
    ansible-vault view inventory/group_vars/windows/vault.yml               # lire
    head -1 inventory/group_vars/windows/vault.yml                          # doit être $ANSIBLE_VAULT;1.1;AES256

Les tâches manipulant un mot de passe utilisent `no_log: true`.

## Mettre à jour le projet sur OPS01

Le dépôt est cloné sur OPS01 : les modifications se font sur le poste du binôme, sont poussées sur GitHub,
puis récupérées sur OPS01 avec `git pull`. Il n'existe qu'**une seule source** des fichiers.

## Limites connues

- Compte `ansible` en sudo sans mot de passe (E-14) et `svc-ansible` membre de « Admins du domaine » (E-15) : à restreindre.
- OPS01 utilise le sudo d'origine (`sudo.ws`) pour Ansible, sudo-rs modifiant l'invite de mot de passe (E-17).
- La collection `ansible.posix` 2.1.0 affiche des avertissements de dépréciation (sans effet sur le résultat).
