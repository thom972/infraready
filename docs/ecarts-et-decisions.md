# Écarts et décisions

Le kit (§1) précise que ses outils sont une proposition de laboratoire et que toute modification
doit être consignée. Chaque écart ci-dessous est à **présenter au formateur** pour validation.

| ID | Date | Écart / décision | Référence | Justification | Impact | Validation formateur |
|---|---|---|---|---|---|---|
| E-01 | Séance 2 | Hyperviseur **QEMU/KVM avec virt-manager (libvirt)** au lieu de VMware Workstation Pro | Kit §1, §3 | Hyperviseur natif de l'hôte Linux, libre, avec snapshots (qcow2), réseaux virtuels isolés et console SPICE | Les procédures VMware du kit sont transposées (réseau libvirt, snapshots virt-manager) | À demander |
| E-02 | Séance 2 | Poste hôte sous **Arch Linux** | Schéma séance 1 | Machine réellement utilisée par le binôme | Mise à jour de la carte « poste hôte » du schéma | À demander |
| E-03 | Séance 2 | Réseau libvirt **NAT** `infraready` (192.168.50.0/24, passerelle .1, DHCP .100–.199) au lieu d'un Host-only pur | Kit §2, §3.2, §5.1 | Équivaut au « chemin NAT contrôlé » du kit : mises à jour possibles, services non publiés sur le LAN | La passerelle 192.168.50.1 existe réellement et peut être déclarée | À demander |
| E-04 | Séance 2 | DNS **temporaire** 192.168.50.1 (dnsmasq de libvirt) sur toutes les VM avant la promotion AD DS | Kit §6.1, §7.1 | Le kit prévoit de conserver un DNS fonctionnel jusqu'à la mise en service de WIN-DC01 | Bascule vers 192.168.50.10 après installation d'AD DS / DNS | Prévu par le kit |
| E-05 | Séance 2 | Noms d'hôte système en **minuscules** (`linux01`, `ops01`) ; noms d'inventaire en majuscules | Kit §6 (`hostnamectl set-hostname LINUX01`) | Convention Linux ; DNS et Ansible ne tiennent pas compte de la casse | Aucun : `LINUX01` et `linux01` désignent la même machine | À signaler |
| E-06 | Séance 2 | Matériel virtuel de WIN-DC01 : disque **SATA**, carte **e1000e** (ou virtio + ISO virtio-win) — *choix réel à confirmer ici* | Kit §5.2 | Pilotes intégrés à l'installeur Windows | Performances un peu moindres qu'en virtio | À signaler |
| E-07 | Séance 2 | Installation de **spice-guest-tools** sur WIN-DC01 | Kit §1 (sources officielles) | Presse-papiers partagé avec la console de la VM ; source officielle spice-space.org | Logiciel ajouté sur un serveur : version à noter | À signaler |
| E-08 | Séance 2 | Flux **OPS01 → WIN-DC01 TCP 5985 (WinRM)** ajouté, limité à l'IP d'OPS01 | Kit §10 (WinRM non activé) vs sujet §5.3, §6.4 | Le sujet impose un transport Windows testé ; le kit indique que le sujet prime | Règle de pare-feu dédiée ; schéma et matrice des flux mis à jour | À demander |
| E-09 | Séance 2 | **RDP non activé** sur WIN-DC01 | Kit §2.2 (RDP facultatif) | La console SPICE suffit ; un port d'administration de moins | Aucun | À signaler |
| E-10 | Séance 2 | Compte dédié **`ansible`** sur LINUX01 : authentification par clé uniquement, **sans sudo** pour l'instant | Kit §10, support 2 §2.6 | Moindre privilège : `ansible -m ping` ne demande pas de droits root ; sudo sera accordé quand un playbook en aura besoin | À documenter dans `docs/securite.md` | À signaler |
| E-11 | Séance 2 | Inventaire au format **YAML** (`inventory/hosts.yml`) au lieu de `hosts.ini` | Kit §9, §10 vs sujet §7 | Le sujet propose `hosts.yml` et prime sur le kit | Aucun | Prévu par le sujet |
