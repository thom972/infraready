# Séance 2 — Étapes 2 et 3 : installer et vérifier LINUX01

Références : support 2 (§2.2, §2.3, fiches 2 et 3), kit (§5.3, §6, §6.1).

Ordre reproductible (fiche 2) : création de la VM → installation → nom d'hôte → réseau →
mises à jour → accès d'administration → validation.

## 1. Créer la VM dans virt-manager

| Paramètre | Valeur |
|---|---|
| Nom de la VM | `LINUX01` |
| Média | ISO Ubuntu Server 24.04 LTS vérifiée |
| OS détecté | Ubuntu 24.04 |
| RAM / vCPU | 2048 Mo / 2 |
| Disque | 30 Go, qcow2 (permet les snapshots) |
| Réseau | Réseau virtuel `infraready` |
| Affichage | Spice (par défaut) |

## 2. Installer Ubuntu Server

| Écran de l'installeur | Choix |
|---|---|
| Langue / clavier | Français / clavier français |
| Type d'installation | Ubuntu Server (pas « minimized ») |
| Réseau | DHCP pour l'instant (adresse en .100–.199) : l'IP fixe est posée après |
| Proxy / miroir | Aucun proxy, miroir proposé |
| Stockage | Disque virtuel entier, partitionnement guidé (LVM par défaut) ; **aucun disque de l'hôte** |
| Profil | Nom du serveur `linux01` ; **compte nominatif** (pas « admin » ni « administrateur ») ; mot de passe robuste, rangé dans le gestionnaire de mots de passe |
| SSH | Cocher **Install OpenSSH server** ; import de clé : non (la clé est ajoutée après) |
| Snaps | Aucun |

> Le mot de passe n'apparaît **jamais** dans le dépôt, une capture ou un message (support 2, §2.2).

Retirer l'ISO au redémarrage, puis se connecter en console.

## 3. Mises à jour initiales

```bash
sudo apt update
sudo apt full-upgrade        # lire la liste avant de confirmer
sudo reboot                  # si demandé ; consigner le redémarrage dans le journal
lsb_release -a               # noter la version exacte (24.04.x)
```

## 4. Passer en adresse fixe (depuis la console, pas en SSH)

```bash
ip -br link                                             # nom de l'interface (souvent enp1s0)
sudo cp -a /etc/netplan /etc/netplan.backup-$(date +%F) # état initial sauvegardé
echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo mv /etc/netplan/50-cloud-init.yaml /root/50-cloud-init.yaml.orig
sudo nano /etc/netplan/01-lab.yaml                      # contenu : configs/linux01/netplan/01-lab.yaml
sudo chmod 600 /etc/netplan/01-lab.yaml
sudo netplan generate                                   # vérifie la syntaxe
sudo netplan try                                        # retour arrière automatique sans confirmation
```

Pourquoi déplacer `50-cloud-init.yaml` : netplan **fusionne** tous les fichiers du dossier ;
son `dhcp4: true` entrerait en conflit avec l'adresse fixe. La ligne `cloud-init` empêche la
régénération de ce fichier au démarrage.

**Contrôle (fiche 3)** — ne pas confondre configuration enregistrée et configuration active :

```bash
ip -br address          # 192.168.50.20/24 sur l'interface UP
ip route                # default via 192.168.50.1
resolvectl status       # DNS 192.168.50.1
getent hosts ubuntu.com # un nom connu se résout
sudo reboot             # puis refaire les contrôles : la VM reste-t-elle joignable ?
```

## 5. Vérifier SSH

```bash
systemctl status ssh --no-pager
ss -lntp | grep ':22'
```

## 6. Accès par clé depuis le poste hôte

Sur l'hôte (Arch) :

```bash
ssh-keygen -t ed25519 -C "infraready-admin"          # avec phrase de passe
ssh-copy-id -i ~/.ssh/id_ed25519.pub <compte>@192.168.50.20
ssh <compte>@192.168.50.20 'hostnamectl'
```

Désactiver ensuite l'authentification par mot de passe est **facultatif à ce stade** ; si c'est
fait, garder une console ouverte pendant le test :

```bash
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/50-cloud-init.conf
sudo sshd -t && sudo systemctl reload ssh
sudo sshd -T | grep -i passwordauthentication     # attendu : passwordauthentication no
```

## 7. Snapshot de référence

Dans virt-manager : **Afficher → Instantanés → +**, nom `00-installation-propre`, description
datée. À prendre une fois les contrôles réussis (kit §5.1).

## Preuves à produire

| Fichier | Contenu |
|---|---|
| `S02_linux01_reception.txt` | Sortie de `scripts/linux/verif-reception.sh` |
| `S02_linux01_ssh-hote.txt` | Connexion SSH par clé depuis l'hôte (`ssh ... hostnamectl`) |
