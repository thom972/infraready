# Procédure de maintenance - InfraReady

*Mis à jour : séance 5. Partie E du sujet fil rouge.*

## 1. Objectif et périmètre

Maintenir les trois serveurs à jour et en bon état, sans interruption non maîtrisée :

| Serveur | Mises à jour | Méthode |
|---|---|---|
| LINUX01 | Paquets Ubuntu | **Automatisées** : `infraready-ansible/maintenance.yml` |
| OPS01 | Paquets Ubuntu | **Automatisées** (exécution locale), redémarrage manuel |
| WIN-DC01 | Windows Update | **Recherche automatisée** par Ansible, **installation manuelle** (procédure §5) |

Contrôles en lecture seule, avant et après chaque maintenance : `infraready-ansible/verification.yml`
(services critiques, espace disque, réponse HTTP du service web).

## 2. Précautions avant toute maintenance ou changement majeur

1. **Prévenir** les utilisateurs du laboratoire (binôme) et choisir un créneau.
2. **Relever l'état initial** : `ansible-playbook verification.yml -K --ask-vault-pass`. Ne pas lancer
   de maintenance sur un système déjà en erreur : diagnostiquer d'abord.
3. **Snapshot** de chaque VM concernée (VM éteinte de préférence) :
   `virsh snapshot-create-as <VM> maint-AAAA-MM-JJ "Avant maintenance"`.
4. **Vérifier l'espace disque** : au moins 15 % libres sur chaque volume surveillé (contrôlé par `verification.yml`).
5. **Une machine à la fois** (`serial: 1`) : si une mise à jour pose problème, les autres serveurs restent intacts.
6. **Ordre de redémarrage** : LINUX01, puis OPS01, puis **WIN-DC01 en dernier**. WIN-DC01 porte l'annuaire et le DNS :
   pendant son redémarrage, la résolution `infraready.test` est indisponible pour tout le labo.
7. **Jamais de redémarrage automatique implicite** : il doit être demandé explicitement (`-e autoriser_redemarrage=true`).

## 3. Mises à jour Linux (automatisées)

Depuis OPS01, dans `~/infraready-ansible` :

    eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_ansible
    ansible-playbook maintenance.yml --syntax-check
    ansible-playbook maintenance.yml -K --ask-vault-pass                               # sans redémarrage
    ansible-playbook maintenance.yml -K --ask-vault-pass -e autoriser_redemarrage=true # avec redémarrage si requis

Déroulement : vérification initiale → `apt` en mode **safe** (aucune suppression de paquet) sur chaque
serveur l'un après l'autre → détection de `/var/run/reboot-required` → redémarrage seulement s'il est requis
**et** autorisé (jamais OPS01, qui exécute Ansible) → vérification finale.

OPS01 : si un redémarrage est signalé, le faire à la main après la fin du playbook (`sudo reboot`), puis relancer
`verification.yml`.

## 4. Contrôle de l'espace disque et des services

| Serveur | Services critiques | Volumes surveillés |
|---|---|---|
| LINUX01 | ssh, nginx | `/`, `/boot`, `/srv/infraready` |
| OPS01 | ssh | `/`, `/boot` |
| WIN-DC01 | NTDS, DNS, Netlogon, Kdc, WinRM, LanmanServer | `C:` |

Seuil : 15 % d'espace libre minimum (`group_vars/all.yml`). Le service web est aussi testé en HTTP (code 200).

## 5. Mises à jour Windows (WIN-DC01) - procédure manuelle testée

1. Recherche automatisée (aucune installation) : la partie Windows de `maintenance.yml` affiche les mises à jour disponibles.
2. Éteindre WIN-DC01 et prendre un snapshot `maint-AAAA-MM-JJ`.
3. Redémarrer, ouvrir **Paramètres → Windows Update**, installer les mises à jour, redémarrer.
4. Recommencer jusqu'à ce qu'il ne reste ni mise à jour ni redémarrage en attente.
5. Contrôler : `Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5`, puis
   `dcdiag /test:Services /test:Advertising /test:NetLogons /test:SysVolCheck` et `verification.yml`.

Le contrôleur de domaine n'est pas mis à jour automatiquement : un redémarrage interrompt l'annuaire et le DNS
du laboratoire, il doit donc rester une décision humaine, dans un créneau annoncé.

## 6. Gestion de la capacité

| Date | Serveur | Action | Résultat |
|---|---|---|---|
| 21/10/2026 | OPS01 | Extension du volume racine avec l'espace libre du groupe LVM (`lvextend -r -l +100%FREE`) | 10 Gio → 18,22 Gio ; `/` de 60 % à 33 % utilisés, à chaud |

## 7. Retour arrière

| Problème après maintenance | Action |
|---|---|
| Service critique arrêté | Journaux (`journalctl -u <service>`, Observateur d'événements), correction ciblée, puis `verification.yml` |
| Système instable après mise à jour | Retour au snapshot `maint-AAAA-MM-JJ` de la VM concernée |
| Redémarrage bloqué | Console virt-manager ; si besoin, retour au snapshot |

## 8. Historique des maintenances

| Date | Serveurs | Mises à jour | Redémarrage | Vérification finale | Preuve |
|---|---|---|---|---|---|
| 21/10/2026 | LINUX01, OPS01 | Paquets Ubuntu appliqués (mode safe) | Non requis | `failed=0` sur les 3 hôtes | `S05_ops01_maintenance.txt` |
