# InfraReady — projet fil rouge

Administration systèmes Linux / Windows — Bachelor 3 Cybersécurité.
Laboratoire de trois VM sur QEMU/KVM, réseau privé `192.168.50.0/24`, domaine Active Directory `infraready.test`,
entièrement configuré par Ansible depuis OPS01 et supervisé par Prometheus et Grafana.

> **Règle absolue** : aucun mot de passe, jeton, clé privée, ISO ou disque virtuel dans ce dépôt.
> Les secrets sont dans trois coffres Ansible Vault chiffrés (`inventory/group_vars/{linux,ops,windows}/vault.yml`)
> et fournis à l'exécution par `--ask-vault-pass`.

## Architecture

| Machine | Système | Adresse | Rôle |
|---|---|---|---|
| WIN-DC01 | Windows Server 2025 | 192.168.50.10 | AD DS et DNS du domaine, partage SMB `Lab`, windows_exporter (9182) |
| LINUX01 | Ubuntu Server 26.04.1 LTS | 192.168.50.20 | Nginx (80), volume de données `/srv/infraready`, node_exporter (9100) |
| OPS01 | Ubuntu Server 26.04.1 LTS | 192.168.50.30 | Contrôleur Ansible, clone Git, Prometheus (9090), Grafana (3000) |
| Poste hôte | Arch Linux, QEMU/KVM | 192.168.50.1 | Passerelle NAT du réseau libvirt `infraready` |

Détails : [`docs/architecture.md`](docs/architecture.md), [`docs/adressage-ip.md`](docs/adressage-ip.md),
schéma modifiable [`docs/schemas/infraready-architecture.drawio`](docs/schemas/infraready-architecture.drawio).

## État d'avancement

| Partie du sujet | État | Où le vérifier |
|---|---|---|
| A. Installation et réseau | Réalisé | [`docs/tracabilite.md`](docs/tracabilite.md#a-installation-et-réseau) |
| B. Administration Windows | Réalisé | [`docs/comptes-et-droits.md`](docs/comptes-et-droits.md) |
| C. Administration Linux | Réalisé | [`docs/stockage.md`](docs/stockage.md) |
| D. Automatisation Ansible | Réalisé (8 playbooks, second passage `changed=0`) | [`docs/ansible.md`](docs/ansible.md) |
| E. Maintenance et mises à jour | Réalisé | [`docs/maintenance.md`](docs/maintenance.md) |
| F. Supervision | Réalisé (4 cibles, alerte de seuil démontrée) | [`docs/supervision.md`](docs/supervision.md) |
| G. GitHub et intégration continue | Workflow en place ; preuve d'exécution à capturer après le premier push | [`.github/workflows/validation.yml`](.github/workflows/validation.yml) |
| H. Diagnostic d'incident | Réalisé | [`docs/incident.md`](docs/incident.md) |

La correspondance complète exigence → fichiers → preuves est dans [`docs/tracabilite.md`](docs/tracabilite.md).
Aucune étiquette de séance n'a encore été posée (règle 4 de [`CONTRIBUTING.md`](CONTRIBUTING.md)).

## Organisation du dépôt

```
infraready/
├── README.md · CONTRIBUTING.md
├── ansible.cfg                        inventaire par défaut, pipelining
├── .github/workflows/validation.yml   CI : yamllint, ansible-lint, syntax-check, promtool, gitleaks
├── .yamllint                          règles yamllint (compatibles ansible-lint)
├── collections/requirements.yml       collections Ansible utilisées
├── inventory/
│   ├── hosts.yml                      hôtes et groupes (aucun secret)
│   ├── group_vars/
│   │   ├── all.yml                    seuil d'espace libre (15 %)
│   │   ├── linux/   vars.yml · vault.yml (chiffré)
│   │   ├── ops/     vars.yml · vault.yml (chiffré)
│   │   └── windows/ vars.yml · ad.yml · vault.yml (chiffré)
│   └── host_vars/LINUX01.yml          disque de données INFRA-DATA
├── playbooks/
│   ├── linux.yml                      LINUX01 complet (importe nginx.yml et stockage.yml)
│   ├── nginx.yml · stockage.yml       service web · volume /srv/infraready
│   ├── windows.yml                    annuaire AD et partage Lab
│   ├── supervision.yml                exporters, Prometheus, Grafana
│   ├── securite.yml                   pare-feu ufw, sudo protégé, durcissement de WIN-DC01
│   ├── verification.yml               contrôles en lecture seule
│   └── maintenance.yml                vérification → mises à jour → vérification
├── monitoring/                        prometheus.yml, alertes.yml, grafana/, dashboards/
├── scripts/linux/ · scripts/windows/  contrôles de réception, chronologie d'alerte, WinRM
├── infra/libvirt/                     réseau virtuel du labo
├── configs/                           netplan de LINUX01 et OPS01
└── docs/
    ├── architecture.md · adressage-ip.md · securite.md · comptes-et-droits.md
    ├── ansible.md · stockage.md · maintenance.md · supervision.md · incident.md
    ├── ecarts-et-decisions.md · tracabilite.md
    ├── dossier-technique.pdf · soutenance.pdf · livrables/ (sources Typst)
    ├── seance-01/ · seance-02/        livrables de conception et d'installation
    ├── schemas/                       schéma draw.io
    └── preuves/                       sorties et captures S<séance>_<machine>_<objet> (index : README.md)
```

## Prérequis

| Où | Élément |
|---|---|
| Poste hôte | QEMU/KVM, libvirt, virt-manager ; réseau `infraready` créé depuis [`infra/libvirt/infraready-network.xml`](infra/libvirt/infraready-network.xml) |
| OPS01 | `ansible` (core 2.20 ou plus), `python3-winrm`, collections de [`collections/requirements.yml`](collections/requirements.yml) |
| OPS01 | Clé SSH d'automatisation `~/.ssh/id_ed25519_ansible` (droits 600, phrase de passe) ; clé publique chez `ansible@LINUX01` |
| OPS01 | Mot de passe du coffre et mot de passe sudo de `keo` : dans le gestionnaire de mots de passe du binôme, jamais dans le dépôt |
| WIN-DC01 | WinRM HTTP 5985 accepté depuis OPS01 uniquement ([`scripts/windows/Set-WinRMLabScope.ps1`](scripts/windows/Set-WinRMLabScope.ps1)) |

## Commandes

Toutes les commandes Ansible se lancent **sur OPS01, depuis la racine du clone** `~/infraready`
(`ansible.cfg` y désigne l'inventaire).

```bash
git pull                                                   # une seule source : ce dépôt
ansible-galaxy collection install -r collections/requirements.yml
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible

ansible-inventory --graph                                  # groupes et hôtes
ansible linux -m ping --ask-vault-pass
ansible windows -m ansible.windows.win_ping --ask-vault-pass

# Ordre de déploiement d'un labo neuf
ansible-playbook playbooks/windows.yml     --ask-vault-pass
ansible-playbook playbooks/linux.yml       --ask-vault-pass
ansible-playbook playbooks/supervision.yml -K --ask-vault-pass
ansible-playbook playbooks/securite.yml    -K --ask-vault-pass
ansible-playbook playbooks/verification.yml -K --ask-vault-pass

# Exploitation
ansible-playbook playbooks/maintenance.yml -K --ask-vault-pass          # sans redémarrage
ansible-playbook playbooks/maintenance.yml -K --ask-vault-pass -e autoriser_redemarrage=true
```

Avant toute exécution : `--syntax-check`, puis `--check --diff` pour simuler ; après : relire le `PLAY RECAP`
(`failed=0`, `unreachable=0`) et relancer pour vérifier `changed=0`. Procédure complète : [`docs/ansible.md`](docs/ansible.md).

## Validation du dépôt

Le workflow [`validation.yml`](.github/workflows/validation.yml) s'exécute à chaque `push` et `pull_request`.
Il **valide les fichiers** et ne déploie rien : le runner hébergé par GitHub n'a pas accès au réseau du labo.
Mêmes contrôles en local :

```bash
yamllint --strict .
ansible-lint
for p in playbooks/*.yml; do ansible-playbook "$p" --syntax-check; done
docker run --rm -v "$PWD/monitoring:/etc/prometheus:ro" --entrypoint promtool prom/prometheus \
  check config /etc/prometheus/prometheus.yml
docker run --rm -v "$PWD:/repo" ghcr.io/gitleaks/gitleaks git /repo
```

## Documents de référence

| Thème | Document |
|---|---|
| Architecture et adressage | [`docs/architecture.md`](docs/architecture.md), [`docs/adressage-ip.md`](docs/adressage-ip.md) |
| Comptes, groupes et droits (AD, partage) | [`docs/comptes-et-droits.md`](docs/comptes-et-droits.md) |
| Automatisation | [`docs/ansible.md`](docs/ansible.md) |
| Stockage, maintenance | [`docs/stockage.md`](docs/stockage.md), [`docs/maintenance.md`](docs/maintenance.md) |
| Supervision | [`docs/supervision.md`](docs/supervision.md) |
| Sécurité, secrets, flux autorisés | [`docs/securite.md`](docs/securite.md) |
| Rapport d'incident | [`docs/incident.md`](docs/incident.md) |
| Écarts au kit et au sujet | [`docs/ecarts-et-decisions.md`](docs/ecarts-et-decisions.md) |
| Traçabilité exigences → preuves | [`docs/tracabilite.md`](docs/tracabilite.md) |
| Index des preuves | [`docs/preuves/README.md`](docs/preuves/README.md) |
| Livrables | [`docs/dossier-technique.pdf`](docs/dossier-technique.pdf), [`docs/soutenance.pdf`](docs/soutenance.pdf) |
| Conventions de commit | [`CONTRIBUTING.md`](CONTRIBUTING.md) |

## Limites connues

- `svc-ansible` reste membre de « Admins du domaine » : risque accepté avec mesures compensatoires (E-15).
- Les alertes sont visibles dans Prometheus et Grafana, sans notification externe (pas d'Alertmanager).
- Les mises à jour Windows sont recherchées par Ansible mais installées manuellement (redémarrage du contrôleur de domaine).
- Aucune capture de l'Observateur d'événements Windows n'est versionnée.
