# Automatisation Ansible - InfraReady

*Mis à jour : séance 8 (sécurité transversale, coffres par groupe, validation continue).*

Toutes les commandes se lancent **depuis la racine du dépôt**, sur **OPS01** (contrôleur Ansible),
dans le clone Git `~/infraready` : le fichier `ansible.cfg` y désigne l'inventaire et les options.

## Structure

    infraready/
    ├── ansible.cfg                      inventaire, pipelining (section [defaults])
    ├── collections/requirements.yml     collections utilisées (installation ci-dessous)
    ├── inventory/
    │   ├── hosts.yml                    hôtes et groupes (aucun secret)
    │   ├── group_vars/
    │   │   ├── all.yml                  seuil d'espace libre commun (15 %)
    │   │   ├── linux/
    │   │   │   ├── vars.yml             élévation (sudo.ws), Nginx, services et volumes surveillés, règles ufw
    │   │   │   └── vault.yml            CHIFFRÉ : mot de passe sudo du compte ansible
    │   │   ├── ops/
    │   │   │   ├── vars.yml             exécution locale, sudo.ws, règles ufw
    │   │   │   └── vault.yml            CHIFFRÉ : mot de passe administrateur Grafana
    │   │   └── windows/
    │   │       ├── vars.yml             connexion WinRM (NTLM, port 5985), services surveillés, windows_exporter
    │   │       ├── ad.yml               annuaire (OU, groupes, comptes) et partage Lab
    │   │       └── vault.yml            CHIFFRÉ : mot de passe de svc-ansible, mot de passe initial des comptes de test
    │   └── host_vars/
    │       └── LINUX01.yml              disque de données INFRA-DATA, montage /srv/infraready
    └── playbooks/
        ├── linux.yml                    configuration complète de LINUX01 (importe nginx.yml + stockage.yml)
        ├── nginx.yml                    service web
        ├── stockage.yml                 disque de données, montage persistant, droits
        ├── windows.yml                  annuaire et partage sur WIN-DC01
        ├── supervision.yml              node_exporter, windows_exporter, Prometheus, Grafana
        ├── securite.yml                 pare-feu ufw, sudo protégé, durcissement de WIN-DC01, tests des flux
        ├── verification.yml             contrôles en lecture seule (services, disque, HTTP)
        └── maintenance.yml              vérification → mises à jour → vérification

## Inventaire

| Groupe | Hôte | Connexion | Compte | Élévation de privilèges |
|---|---|---|---|---|
| `linux` (dans `serveurs_linux`) | LINUX01 (192.168.50.20) | SSH, clé `~/.ssh/id_ed25519_ansible` | `ansible` | sudo **avec** mot de passe, lu dans `linux/vault.yml`, via `sudo.ws` (E-14 résolu, E-17) |
| `ops` (dans `serveurs_linux`) | OPS01 | locale | `keo` | sudo **avec** mot de passe saisi par `-K`, via `sudo.ws` (E-17) |
| `windows` | WIN-DC01 (192.168.50.10) | WinRM HTTP 5985, NTLM | `svc-ansible@infraready.test` | compte du domaine (E-15) |

Le groupe parent `serveurs_linux` permet de viser LINUX01 et OPS01 ensemble (supervision, sécurité, maintenance).

## Prérequis sur OPS01

| Élément | Installation / vérification |
|---|---|
| Ansible core 2.20 ou plus | `sudo apt install ansible` ; `ansible --version` |
| Collections `ansible.windows`, `community.windows`, `microsoft.ad`, `community.general`, `ansible.posix` | `ansible-galaxy collection install -r collections/requirements.yml` ; `ansible-galaxy collection list` |
| Bibliothèque WinRM | `sudo apt install python3-winrm` |
| Hachage des mots de passe (`securite.yml`) | `python3-passlib`, installé par le playbook lui-même |
| Clé SSH d'automatisation | `~/.ssh/id_ed25519_ansible` (droits `600`, phrase de passe), clé publique dans `~ansible/.ssh/authorized_keys` sur LINUX01 |
| Mots de passe (coffre, sudo de `keo`) | dans le gestionnaire de mots de passe du binôme, **jamais** dans le dépôt |

Avant chaque session : `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible`.

## Secrets : trois coffres Ansible Vault

Chaque groupe a son propre `vault.yml`, chiffré en AES256 avec **le même mot de passe de coffre**.
Ansible charge le coffre d'un groupe dès qu'un hôte de ce groupe est visé : **toute commande qui touche
LINUX01, OPS01 ou WIN-DC01 demande donc `--ask-vault-pass`**.

| Coffre | Contenu | Utilisé par |
|---|---|---|
| `inventory/group_vars/linux/vault.yml` | `ansible_become_password` du compte `ansible` (12 caractères minimum, vérifié par `securite.yml`) | toutes les tâches avec sudo sur LINUX01 |
| `inventory/group_vars/ops/vault.yml` | `grafana_admin_password` | `supervision.yml` |
| `inventory/group_vars/windows/vault.yml` | mot de passe de connexion de `svc-ansible`, `lab_user_initial_password` | toutes les connexions WinRM, `windows.yml` |

    EDITOR=nano ansible-vault edit inventory/group_vars/linux/vault.yml    # modifier (idem ops/, windows/)
    ansible-vault view inventory/group_vars/ops/vault.yml                  # lire
    head -1 inventory/group_vars/*/vault.yml                               # chaque ligne : $ANSIBLE_VAULT;1.1;AES256

Les tâches manipulant un mot de passe utilisent `no_log: true`. La CI refuse un `vault.yml` non chiffré
et recherche les secrets dans tout l'historique (gitleaks).

## Playbooks

| Playbook | Cible | Rôle | Commande |
|---|---|---|---|
| `linux.yml` | LINUX01 | Nginx + volume de données | `ansible-playbook playbooks/linux.yml --ask-vault-pass` |
| `nginx.yml` | groupe `linux` | Installe Nginx, service actif et activé au démarrage | `ansible-playbook playbooks/nginx.yml --ask-vault-pass` |
| `stockage.yml` | LINUX01 | Disque `INFRA-DATA` → ext4 → `/srv/infraready` (fstab par UUID), groupe `infraready`, tests d'écriture | `ansible-playbook playbooks/stockage.yml --ask-vault-pass` |
| `windows.yml` | WIN-DC01 | OU, groupes, comptes de test, partage `Lab` (NTFS + SMB), vérifications | `ansible-playbook playbooks/windows.yml --ask-vault-pass` |
| `supervision.yml` | tous | Exporters Linux et Windows, Prometheus, Grafana provisionné, vérification des cibles | `ansible-playbook playbooks/supervision.yml -K --ask-vault-pass` |
| `securite.yml` | tous | Pare-feu ufw, sudo protégé du compte `ansible`, durcissement de WIN-DC01, tests des flux | `ansible-playbook playbooks/securite.yml -K --ask-vault-pass` |
| `verification.yml` | tous | Services critiques, espace disque (seuil 15 %), volumes montés, HTTP | `ansible-playbook playbooks/verification.yml -K --ask-vault-pass` |
| `maintenance.yml` | tous | Mises à jour Linux une machine à la fois, recherche Windows, vérifications avant/après | `ansible-playbook playbooks/maintenance.yml -K --ask-vault-pass` (ajouter `-e autoriser_redemarrage=true` pour autoriser un redémarrage requis) |

`-K` (mot de passe sudo de `keo`) n'est nécessaire que pour les playbooks qui visent OPS01.

### `supervision.yml`

1. **Linux** (`serveurs_linux`) : paquet `prometheus-node-exporter`, service actif, vérification de `http://localhost:9100/metrics`.
2. **Windows** : MSI officiel de windows_exporter 0.31.8, service automatique, règle de pare-feu 9182 **limitée à OPS01**,
   désactivation de toute autre règle ouvrant 9182, vérification de `http://localhost:9182/metrics`.
3. **OPS01** : Prometheus (paquet Ubuntu), configuration et règles déployées depuis `monitoring/` après validation
   `promtool check config` / `promtool check rules` ; Grafana depuis le dépôt APT officiel (clé vérifiée), source de
   données et tableau de bord provisionnés ; mot de passe administrateur défini une seule fois depuis le coffre.
4. **Vérifications** : Prometheus prêt, les 4 cibles `up`, règles d'alerte chargées, Grafana interroge bien Prometheus.

Détails et requêtes PromQL : [`supervision.md`](supervision.md).

### `securite.yml`

1. **Prérequis** du contrôleur (`python3-passlib`).
2. **Pare-feu ufw** de LINUX01 et OPS01, une machine à la fois : les flux de `regles_pare_feu` sont autorisés
   **avant** l'activation (la session SSH d'Ansible n'est jamais coupée), puis refus par défaut en entrée,
   journalisation des refus.
3. **Compte `ansible` de LINUX01** : SSH par clé uniquement (`Match User ansible`, `sshd -t` avant rechargement),
   mot de passe défini depuis le coffre, sudo **avec** mot de passe (règle validée par `visudo -cf`).
4. **WIN-DC01** : règles entrantes SMB (445) et DNS (53) limitées à `192.168.50.0/24` ; `svc-ansible` marqué
   « sensible et non délégable ».
5. **Vérifications** : sudo sans mot de passe refusé, sudo avec mot de passe accepté, SSH par mot de passe refusé ;
   flux autorisés fonctionnels depuis OPS01 (Nginx, SSH, SMB, toutes les cibles Prometheus `up`), résolution DNS du
   domaine, flux non autorisés refusés depuis LINUX01 (9090 et 3000 d'OPS01).

Simulation conseillée avant tout changement : `ansible-playbook playbooks/securite.yml --check --diff -K --ask-vault-pass`.
Retour arrière du pare-feu, depuis la console de la VM : `sudo ufw disable`. Détails : [`securite.md`](securite.md).

## Procédure standard d'exécution

1. Vérifier la syntaxe : `ansible-playbook playbooks/<nom>.yml --syntax-check`.
2. Vérifier les cibles : `ansible-playbook playbooks/<nom>.yml --list-hosts`.
3. Simuler : `ansible-playbook playbooks/<nom>.yml --check --diff --ask-vault-pass` (ajouter `-K` si OPS01 est visé).
4. Exécuter, puis relire le PLAY RECAP (`failed=0`, `unreachable=0`).
5. **Relancer** : la seconde exécution doit afficher `changed=0` (idempotence).

Chaque playbook de configuration se termine par des **vérifications après exécution** (`assert`, tests réels
d'écriture, lecture des droits du partage, état des cibles Prometheus) : un état incorrect fait échouer l'exécution
au lieu de passer inaperçu.

## Résultats d'idempotence

| Playbook | Premier passage | Second passage | Preuves |
|---|---|---|---|
| `nginx.yml` | `changed=1` | `changed=0` | `S03_ops01_playbook-run1.txt`, `-run2.txt` |
| `windows.yml` (annuaire) | `changed=4` | `changed=0` | `S04_ops01_windows-run1.txt`, `-run2.txt` |
| `windows.yml` (partage) | `changed=5` | `changed=0` | `S04_ops01_windows-partage-run1.txt`, `-run2.txt` |
| `stockage.yml` | échecs corrigés (runs 1 à 4) | `changed=0` (runs 5 et 6) | `S04_ops01_stockage-run1.txt` à `-run6.txt` |
| `supervision.yml` | échecs corrigés (runs 1 à 3), puis `failed=0` | `changed=0` (run 6) | `S06_ops01_supervision-run1.txt` à `-run6.txt` |
| `securite.yml` (pare-feu) | `changed=3` par hôte | `changed=0` | `S08_ops01_pare-feu-run1.txt`, `-run2.txt` |
| `securite.yml` (complet) | contrôle `sudo -n` en échec (runs 1 et 2, corrigé : `c95cb74`) | `failed=0` sur les 3 hôtes (run 3) | `S08_ops01_durcissement-*.txt` |

## Validation continue

Le workflow `.github/workflows/validation.yml` rejoue à chaque `push` et `pull_request` : `yamllint --strict`,
`ansible-lint` (profil `production` atteint), `--syntax-check` de tous les playbooks, `promtool check config/rules`,
contrôle du chiffrement des coffres et `gitleaks`. Première exécution réussie : `preuves/S08_github_actions-validation.txt`. Il ne se connecte à aucune VM : voir [`../README.md`](../README.md#validation-du-dépôt).

## Mettre à jour le projet sur OPS01

Le dépôt est cloné sur OPS01 : les modifications se font sur le poste du binôme, sont poussées sur GitHub,
puis récupérées sur OPS01 avec `git pull`. Il n'existe qu'**une seule source** des fichiers.

## Limites connues

- `svc-ansible` membre de « Admins du domaine » : risque accepté, mesures compensatoires (E-15).
- LINUX01 et OPS01 utilisent le sudo d'origine (`sudo.ws`) pour Ansible, sudo-rs modifiant l'invite de mot de passe (E-17).
- La collection `ansible.posix` 2.1.0 affiche des avertissements de dépréciation (sans effet sur le résultat).
