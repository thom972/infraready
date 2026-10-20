# infraready-ansible

Installation et vérification d'un service web (Nginx) sur les serveurs Linux du laboratoire InfraReady.

## Structure

| Fichier | Rôle |
|---|---|
| `inventory.ini` | Hôtes ciblés : groupe `linux` → LINUX01 (192.168.50.20), compte `ansible` |
| `group_vars/linux.yml` | Variables du groupe : élévation de droits, interpréteur Python, paquet et service web |
| `nginx.yml` | Playbook : installe le paquet et s'assure que le service est actif et activé au démarrage |

## Prérequis

- Exécution depuis **OPS01** (192.168.50.30), Ansible core 2.20.
- Clé SSH `~/.ssh/id_ed25519_ansible` sur OPS01 (chargée avec `ssh-add`), clé publique installée pour le compte `ansible` de LINUX01.
- Compte `ansible` autorisé à utiliser sudo sur LINUX01 (`/etc/sudoers.d/90-ansible`, mesure temporaire : écart E-14).

## Utilisation

```bash
cd ~/infraready-ansible
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible

# 1. Vérifier la syntaxe et la cible AVANT toute modification
ansible-playbook -i inventory.ini nginx.yml --syntax-check
ansible -i inventory.ini linux --list-hosts

# 2. Exécuter
ansible-playbook -i inventory.ini nginx.yml

# 3. Relancer pour vérifier l'idempotence (attendu : changed=0)
ansible-playbook -i inventory.ini nginx.yml
```

## Contrôles du résultat (indépendants d'Ansible)

```bash
ssh linux01 'systemctl is-active nginx; systemctl is-enabled nginx; curl -sI http://localhost | head -1'
```

Attendu : `active`, `enabled`, `HTTP/1.1 200 OK`.

## Sécurité

- Aucun mot de passe, jeton ni clé privée dans ce dossier.
- Un futur secret (identifiants Windows, par exemple) sera stocké avec `ansible-vault`.
- Ne jamais remplacer `hosts: linux` par `all` sans avoir vérifié l'inventaire avec `--list-hosts`.
