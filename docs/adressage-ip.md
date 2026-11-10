# Plan d'adressage IP

Réseau : **192.168.50.0/24** — réseau libvirt `infraready`, mode NAT (E-03).

| Adresse | Usage | Attribution |
|---|---|---|
| 192.168.50.1 | Hôte (passerelle NAT, DNS temporaire dnsmasq) | libvirt |
| 192.168.50.10 | WIN-DC01 — AD DS, DNS | Fixe |
| 192.168.50.20 | LINUX01 — service Linux | Fixe |
| 192.168.50.30 | OPS01 — Ansible, supervision | Fixe |
| 192.168.50.100 – .199 | DHCP (installations uniquement) | Dynamique |
| Autres | Réservées | — |

**DNS :** 192.168.50.1 jusqu'à la promotion de WIN-DC01, puis 192.168.50.10 pour les VM Linux
et 127.0.0.1 sur WIN-DC01 lui-même (kit §6.1, §7.1). Domaine : `infraready.test`.
