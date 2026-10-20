# Architecture (état courant)

*Mise à jour : séance 2. La version prévisionnelle de la séance 1 reste disponible dans
[`seance-01/03-architecture.md`](seance-01/03-architecture.md) et dans l'historique Git
(étiquette `v0.1-seance1`).*

Source modifiable : [`schemas/infraready-architecture.drawio`](schemas/infraready-architecture.drawio).

```mermaid
flowchart LR
    H["Poste hôte — Arch Linux<br/>QEMU/KVM · virt-manager<br/>192.168.50.1"]
    subgraph LAB["Réseau libvirt « infraready » (NAT) — 192.168.50.0/24 — infraready.test"]
        OPS["OPS01<br/>Ansible · Git<br/>(Prometheus · Grafana à venir)<br/>192.168.50.30"]
        DC["WIN-DC01<br/>Windows Server 2025<br/>(AD DS · DNS à venir)<br/>192.168.50.10"]
        LX["LINUX01<br/>Ubuntu Server 24.04<br/>192.168.50.20"]
    end
    H -- "SSH 22 · web 3000 / 9090" --> OPS
    H -- "SSH 22" --> LX
    OPS -- "Ansible · SSH 22" --> LX
    OPS -- "WinRM · TCP 5985" --> DC
    OPS -. "métriques TCP 9100 (à venir)" .-> LX
    OPS -. "métriques TCP 9182* (à venir)" .-> DC
    OPS -- "DNS 53 (après AD DS)" --> DC
    LX -- "DNS 53 (après AD DS)" --> DC
```

## Changements par rapport à la séance 1

| Changement | Écart |
|---|---|
| Hôte Arch Linux, hyperviseur QEMU/KVM (virt-manager) | E-01, E-02 |
| Réseau libvirt NAT avec passerelle 192.168.50.1 | E-03 |
| DNS temporaire 192.168.50.1 avant AD DS | E-04 |
| Flux WinRM OPS01 → WIN-DC01 (TCP 5985), limité à OPS01 | E-08 |
| RDP retiré (non activé) | E-09 |

Matrice des flux complète : [`securite.md`](securite.md).
