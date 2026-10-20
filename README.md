# InfraReady — projet fil rouge

Administration systèmes Linux / Windows — Bachelor 3.
Laboratoire de trois VM (WIN-DC01, LINUX01, OPS01) sur QEMU/KVM, réseau privé 192.168.50.0/24,
domaine `infraready.test`.

> Règle absolue : aucun mot de passe, jeton, clé privée, ISO ou disque virtuel dans ce dépôt.


## État d'avancement

| Séance | Contenu | État | Étiquette |
|---|---|---|---|
| 1 | Conception : besoins, comparatif, schéma, inventaire, plan de tests, note | Livrables rédigés | `v0.1-seance1` |
| 2 | Installation des 3 VM, réseau, accès distant, réception | Procédures et configurations prêtes ; **preuves à produire** | `v0.2-seance2` (après preuves) |

## Organisation du dépôt

```
infraready/
├── README.md, CONTRIBUTING.md
├── ansible.cfg
├── inventory/hosts.yml              # inventaire Ansible (sans secret)
├── infra/libvirt/                   # réseau virtuel du labo
├── configs/                         # fichiers déployés sur les VM (netplan…)
├── scripts/
│   ├── linux/verif-reception.sh     # contrôles en lecture seule
│   └── windows/                     # contrôles et préparation WinRM
└── docs/
    ├── architecture.md, adressage-ip.md, securite.md, ecarts-et-decisions.md
    ├── schemas/                     # schéma draw.io
    ├── seance-01/                   # livrables de conception
    ├── seance-02/                   # procédures, réception, journal, bilan
    └── preuves/                     # sorties et captures (S02_<machine>_<test>)
```

## Documents de référence

| Thème | Document |
|---|---|
| Architecture actuelle | [`docs/architecture.md`](docs/architecture.md) |
| Plan d'adressage | [`docs/adressage-ip.md`](docs/adressage-ip.md) |
| Comptes, secrets, flux autorisés | [`docs/securite.md`](docs/securite.md) |
| Écarts au kit et au sujet | [`docs/ecarts-et-decisions.md`](docs/ecarts-et-decisions.md) |
| Preuves | [`docs/preuves/README.md`](docs/preuves/README.md) |
| Conventions de commit | [`CONTRIBUTING.md`](CONTRIBUTING.md) |
