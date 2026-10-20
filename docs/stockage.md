# Stockage de données - LINUX01

*Mis à jour : séance 4. Réalisé par le playbook `infraready-ansible/stockage.yml`.*

## Disque de données

| Élément | Valeur |
|---|---|
| Disque virtuel | `/var/lib/libvirt/images/LINUX01-data.qcow2`, 5 Gio, bus VirtIO |
| Identifiant | Numéro de série `INFRA-DATA` → `/dev/disk/by-id/virtio-INFRA-DATA` (vu comme `/dev/vdb`) |
| Partition | `vdb1`, table GPT, partition unique |
| Système de fichiers | ext4, étiquette `infradata`, UUID `bd3813fb-b629-45a6-be2e-34dba82bca03` |
| Montage | `/srv/infraready`, persistant dans `/etc/fstab` par UUID, options `defaults,nofail` |
| Permissions | `root:infraready`, mode `2775` (setgid) ; sous-dossier `logs` identique |
| Groupe `infraready` | Membres : `keo` |

## Identification de la cible (avant toute écriture)

La cible est `/dev/vdb` : 5 Gio comme créé dans l'hyperviseur (`virsh domblklist`), numéro de série
`INFRA-DATA` attribué à l'ajout, aucune partition ni système de fichiers ; la racine `/` est sur `vda3` (LVM).
Le playbook désigne le disque par son numéro de série (jamais par `/dev/vdX`) et s'arrête si la cible
est absente ou porte la racine.

## Sécurités

- **Jamais de reformatage** : `filesystem` avec `force: false` ne crée un système de fichiers que s'il n'en existe aucun.
- **Démarrage protégé** : l'option `nofail` permet à la VM de démarrer même si le disque est absent.
- **Retour arrière** : sauvegarde de `/etc/fstab` par le module `mount` (`backup: true`) et snapshot `04-avant-disque-donnees`.
- **Permissions minimales** : seul le groupe `infraready` écrit ; pas de `chmod 777`.

## Vérifications

| Test | Méthode | Résultat |
|---|---|---|
| Montage actif | `findmnt /srv/infraready` | `/dev/vdb1` ext4 |
| Configuration persistante | `findmnt --verify`, puis redémarrage de LINUX01 | Montage présent après redémarrage |
| Écriture autorisée | `keo` crée puis supprime un fichier | OK |
| Écriture refusée | `ansible` (hors groupe) tente d'écrire | Refusée (attendu) |
| Idempotence | Deux exécutions successives du playbook | `changed=0` |

## Difficultés rencontrées et corrections

| Symptôme | Cause confirmée | Correction |
|---|---|---|
| Échec de `become_user: keo` (« chmod: invalid operator ») | Ansible ne peut pas transmettre ses fichiers temporaires à un compte non privilégié sans `setfacl` | `pipelining = True` dans `ansible.cfg` |
| Test « keo peut écrire » en échec alors que les droits sont corrects | Faux négatif de `/usr/bin/test -w` avec un groupe secondaire ; le test intégré au shell et une écriture réelle réussissent | Le playbook teste par une écriture réelle (`touch` puis `rm`) |

Preuves : `docs/preuves/S04_linux01_disque-identification.txt`, `S04_ops01_stockage-run*.txt`,
`S04_linux01_diagnostic-droits.txt`, `S04_linux01_stockage-verif.txt`.
