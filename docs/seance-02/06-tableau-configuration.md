# Séance 2 — Tableau de configuration

*À tenir à jour à chaque changement (support 2, livrables). Les cases « à relever » se remplissent
avec la valeur **observée** sur la machine, pas avec la valeur prévue.*

Dernière mise à jour : _____ (date) — par : _____

| Champ | WIN-DC01 | LINUX01 | OPS01 |
|---|---|---|---|
| Nom de la VM (virt-manager) | WIN-DC01 | LINUX01 | OPS01 |
| Nom d'hôte système | WIN-DC01 | linux01 | ops01 |
| OS / édition | Windows Server 2025 Standard Evaluation, Desktop Experience | Ubuntu Server 24.04 LTS | Ubuntu Server 24.04 LTS |
| Version exacte | à relever (`OsVersion`, build) | à relever (`lsb_release -a`) | à relever |
| Fin d'évaluation | à relever (`slmgr /dlv`) | — | — |
| vCPU / RAM / disque | 2 / 4 Go / 50 Go | 2 / 2 Go / 30 Go | 2 / 4 Go / 50 Go |
| Matériel virtuel | disque SATA, carte e1000e (E-06, à confirmer) | virtio | virtio |
| Réseau virtuel | `infraready` (NAT, E-03) | `infraready` | `infraready` |
| Interface | à relever (`Get-NetAdapter`) | à relever (`ip -br link`) | à relever |
| IP / masque | 192.168.50.10/24 | 192.168.50.20/24 | 192.168.50.30/24 |
| Passerelle | 192.168.50.1 | 192.168.50.1 | 192.168.50.1 |
| DNS actuel | 192.168.50.1 (temporaire, E-04) | 192.168.50.1 (temporaire) | 192.168.50.1 (temporaire) |
| DNS après AD DS | 127.0.0.1 / 192.168.50.10 | 192.168.50.10 + `search infraready.test` | idem |
| Domaine | `infraready.test` (à créer) | — | — |
| Comptes (noms seulement) | Administrateur | compte nominatif : _____ ; `ansible` (clé, sans sudo) | compte nominatif : _____ |
| Accès d'administration | Console SPICE ; WinRM 5985 depuis OPS01 | SSH 22 (clé) depuis l'hôte et OPS01 | SSH 22 (clé) depuis l'hôte |
| Ports entrants autorisés | 5985 (OPS01), ICMP (labo) | 22 | 22 |
| Logiciels ajoutés | spice-guest-tools (version : _____) | — | git, ansible (versions : _____) |
| Mises à jour | à relever (dernière KB, date) | à relever (date) | à relever (date) |
| Snapshot de référence | `00-installation-propre` (date : _____) | idem | idem |
| Statut de réception | à faire | à faire | à faire |
