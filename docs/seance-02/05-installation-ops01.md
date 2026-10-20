# Séance 2 — Étape 6 : installer et préparer OPS01

Références : support 2 (§2.6, fiche 5), kit (§5.4, §9, §10), écarts E-10 et E-11.

OPS01 centralise les outils d'exploitation. À cette séance : système installé, adressé, à jour,
**Git et Ansible installés**, et **accès SSH par clé vers LINUX01** prêt. Prometheus et Grafana
seront installés à la séance consacrée à la supervision.

## 1. Créer et installer la VM

Comme LINUX01 (voir [`02-installation-linux01.md`](02-installation-linux01.md)), avec ces valeurs :

| Paramètre | Valeur |
|---|---|
| Nom de la VM / nom du serveur | `OPS01` / `ops01` |
| RAM / vCPU / disque | 4096 Mo / 2 / 50 Go qcow2 |
| Réseau | `infraready` |
| Compte | Nominatif, mot de passe robuste dans le gestionnaire ; OpenSSH coché |
| IP fixe | 192.168.50.30/24 — fichier [`configs/ops01/netplan/01-lab.yaml`](../../configs/ops01/netplan/01-lab.yaml) |

Puis : mises à jour, IP fixe depuis la console (`netplan try`), contrôles, clé SSH depuis l'hôte
(`ssh-copy-id`), exactement comme pour LINUX01.

## 2. Installer les outils

```bash
sudo apt update
sudo apt install -y git ansible python3 openssh-client
git --version
ansible --version
```

Conserver ces deux sorties : la documentation des versions est demandée (support 2, §2.6).
Paquets issus des dépôts officiels Ubuntu : pas de script d'installation tiers.

## 3. Créer la clé d'automatisation (sur OPS01)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ansible -C "ansible@ops01"   # avec phrase de passe
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519_ansible
cat ~/.ssh/id_ed25519_ansible.pub                                         # clé PUBLIQUE à copier
```

La clé **privée** reste sur OPS01 et ne va **jamais** dans GitHub (support 2, §2.6).

## 4. Créer le compte `ansible` sur LINUX01

Depuis l'hôte, en SSH sur LINUX01 avec le compte d'administration :

```bash
sudo adduser --disabled-password --gecos "" ansible        # pas de mot de passe : clé uniquement
sudo install -d -m 700 -o ansible -g ansible /home/ansible/.ssh
sudo nano /home/ansible/.ssh/authorized_keys               # coller la clé PUBLIQUE d'OPS01
sudo chown ansible:ansible /home/ansible/.ssh/authorized_keys
sudo chmod 600 /home/ansible/.ssh/authorized_keys
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub           # empreinte de LINUX01, à comparer à l'étape 5
```

Pas de `sudo` pour ce compte à ce stade (E-10).

## 5. Tester SSH puis Ansible depuis OPS01

```bash
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible
ssh -i ~/.ssh/id_ed25519_ansible ansible@192.168.50.20 hostname
```

À la première connexion, **comparer l'empreinte affichée** à celle relevée sur LINUX01 avant de
répondre `yes` : c'est ce qui garantit qu'on parle à la bonne machine.

Copier ensuite la configuration Ansible du dépôt (depuis l'hôte) et tester :

```bash
# sur l'hôte, à la racine du dépôt
scp -r ansible.cfg inventory <compte>@192.168.50.30:~/infraready/
# sur OPS01
cd ~/infraready
ansible-inventory --graph
ansible linux -m ping
```

Attendu : `LINUX01 | SUCCESS` avec `"ping": "pong"`. Le module `ping` d'Ansible vérifie la
connexion SSH et Python, ce n'est **pas** un ping ICMP (kit §10).

Plus tard, le dépôt pourra être cloné directement sur OPS01 (clé de déploiement GitHub en lecture
seule) plutôt que copié avec `scp`.

## 6. Tester l'accès WinRM

Voir [`04-administration-distante-windows.md`](04-administration-distante-windows.md), §4.

## 7. Snapshot

`00-installation-propre` une fois tous les contrôles réussis.

## Preuves à produire

| Fichier | Contenu |
|---|---|
| `S02_ops01_reception.txt` | Sortie de `scripts/linux/verif-reception.sh` |
| `S02_ops01_versions.txt` | `git --version`, `ansible --version` |
| `S02_ops01_ssh-linux01.txt` | `ssh ... ansible@192.168.50.20 hostname` |
| `S02_ops01_ansible-ping.txt` | `ansible linux -m ping` |
