# Séance 2 — Étape 1 : préparer le laboratoire

Références : support 2 (§2.1, fiche 1), kit (§3, §4), écarts E-01 et E-02.

## 1. Relever l'état initial de l'hôte

À exécuter sur le poste hôte (Arch Linux), sorties à conserver dans `docs/preuves/S02_hote_etat-initial.txt` :

```bash
lscpu | grep -E 'Model name|Virtualization|^CPU\(s\)'   # VT-x / AMD-V présent ?
ls -l /dev/kvm                                           # KVM disponible ?
free -h                                                  # RAM physique et disponible
df -h /var/lib/libvirt                                   # place pour les disques virtuels
ip -br address                                           # réseaux déjà utilisés
ip route                                                 # routes (LAN, VPN)
```

**Contrôle :** `/dev/kvm` existe, la virtualisation est active, et **aucune** adresse ni route
n'utilise 192.168.50.0/24. Si c'est le cas, choisir un autre sous-réseau RFC1918 et mettre à jour
toute la documentation (kit §2).

## 2. Plan de ressources (fiche 1)

La somme des RAM virtuelles ne doit pas empêcher l'hôte de fonctionner (kit §3.1). Pour un hôte
de 16 Go de RAM (valeur à confirmer avec `free -h`) :

| VM | vCPU | RAM | Disque (qcow2, allocation dynamique) | Commentaire |
|---|---|---|---|---|
| WIN-DC01 | 2 | 4 Go | 50 Go | Bas de la fourchette du kit (4–6 Go) |
| LINUX01 | 2 | 2 Go | 30 Go | Bas de la fourchette du kit (2–4 Go) |
| OPS01 | 2 | 4 Go | 50 Go | Prometheus + Grafana plus tard |
| **Total** | 6 | **10 Go** | 130 Go maximum | Laisse environ 6 Go à l'hôte |

Si l'hôte peine avec les trois VM allumées, la solution prévue est de **regrouper OPS01 sur LINUX01
après accord du formateur**, pas de réduire la RAM de toutes les VM au hasard (fiche 1).

## 3. Installer la pile de virtualisation (hôte Arch)

```bash
sudo pacman -S --needed qemu-desktop libvirt virt-manager dnsmasq edk2-ovmf swtpm
sudo systemctl enable --now libvirtd.service
sudo usermod -aG libvirt "$USER"     # puis se déconnecter / reconnecter
virsh -c qemu:///system list --all   # doit répondre sans erreur
```

`dnsmasq` est nécessaire aux réseaux virtuels NAT de libvirt (DHCP et DNS du réseau) ; `edk2-ovmf`
fournit le firmware UEFI et `swtpm` le TPM virtuel que virt-manager ajoute aux VM Windows.

## 4. Créer le réseau privé du laboratoire

Le fichier [`infra/libvirt/infraready-network.xml`](../../infra/libvirt/infraready-network.xml)
définit le réseau. Voir l'étape suivante du dépôt pour sa création.

## 5. Télécharger et vérifier les images d'installation

| Image | Source officielle | Vérification |
|---|---|---|
| Ubuntu Server 24.04 LTS (amd64) | https://ubuntu.com/download/server | `sha256sum` comparé au fichier `SHA256SUMS` publié par Canonical |
| Windows Server 2025 Evaluation (ISO 64 bits) | Centre d'évaluation Microsoft | Lire les conditions de l'évaluation ; noter la date de téléchargement |

```bash
sha256sum ubuntu-24.04.*-live-server-amd64.iso
```

Les ISO restent **hors du dépôt Git** (voir `.gitignore`).

## 6. Dossier de projet

Le dépôt Git contient la documentation, les configurations et les preuves. Les disques virtuels
(`/var/lib/libvirt/images/`), les ISO et les secrets n'y entrent jamais (support 2, §2.1).
