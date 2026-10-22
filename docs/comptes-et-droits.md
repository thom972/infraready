# Comptes, groupes et droits - domaine infraready.test

*Mis à jour : séance 4. Créés et vérifiés par le playbook `playbooks/windows.yml`.*

> Aucun mot de passe dans ce document. Les mots de passe sont dans le gestionnaire du binôme
> et, pour l'automatisation, dans `inventory/group_vars/windows/vault.yml` (Ansible Vault, chiffré).

## Organisation de l'annuaire

    infraready.test
    └── OU=InfraReady
        ├── OU=Utilisateurs   a.martin, b.durand, c.petit, d.invite
        └── OU=Groupes        GG-Admins-Infra, GG-Utilisateurs-Lab

## Comptes

| Compte | Type | Emplacement | Groupes | Usage |
|---|---|---|---|---|
| `Administrateur` | Administrateur intégré | CN=Users | Admins du domaine | Administration manuelle du domaine |
| `svc-ansible` | Compte de service | CN=Users | Admins du domaine (E-15) | Automatisation Ansible depuis OPS01 (WinRM, NTLM) |
| `a.martin` | Compte de test | OU=Utilisateurs | GG-Admins-Infra, GG-Utilisateurs-Lab | Administrateur de l'infrastructure |
| `b.durand` | Compte de test | OU=Utilisateurs | GG-Utilisateurs-Lab | Utilisateur standard |
| `c.petit` | Compte de test | OU=Utilisateurs | GG-Utilisateurs-Lab | Utilisateur standard |
| `d.invite` | Compte de test | OU=Utilisateurs | *(aucun)* | Témoin pour le test d'accès refusé |

Comptes Linux (hors domaine) : compte nominatif `keo` (sudo) sur LINUX01 et OPS01 ; compte `ansible`
sur LINUX01 (clé SSH uniquement, sudo sans mot de passe temporaire : E-14).

## Groupes

| Groupe | Portée / type | Membres | Rôle |
|---|---|---|---|
| `GG-Admins-Infra` | Global / sécurité | a.martin | Administration des ressources InfraReady |
| `GG-Utilisateurs-Lab` | Global / sécurité | a.martin, b.durand, c.petit | Utilisation des ressources du laboratoire |

Les droits sont attribués aux **groupes**, jamais directement aux comptes : ajouter ou retirer un
utilisateur d'un groupe suffit à modifier ses accès.

## Droits sur le partage \\\\WIN-DC01\\Lab (C:\\Partages\\Lab)

L'accès effectif est le **plus restrictif** des deux niveaux : autorisations du partage **et** droits NTFS.

| Principal | Autorisation du partage | Droit NTFS |
|---|---|---|
| `GG-Admins-Infra` | Contrôle total | Contrôle total |
| `GG-Utilisateurs-Lab` | Modification | Modification |
| SYSTEM, Administrateurs (BUILTIN) | — | Contrôle total (gestion locale du serveur) |
| Tout autre compte | Aucune | Aucun (héritage NTFS coupé) |

## Tests d'accès (depuis LINUX01, smbclient)

| Test | Compte | Attendu | Obtenu | Statut |
|---|---|---|---|---|
| Écriture d'un fichier | b.durand | Autorisé | Fichier `test-b.durand.txt` créé | OK |
| Lecture et suppression | a.martin | Autorisé | Fichier listé puis supprimé | OK |
| Lecture | d.invite | Refusé | `NT_STATUS_ACCESS_DENIED` | OK |

Preuves : `docs/preuves/S04_linux01_test-partage.txt`, `S04_ops01_windows-partage-run1.txt` et `-run2.txt`.

## Limites et évolutions

- `svc-ansible` est membre de « Admins du domaine » : à restreindre par délégation sur `OU=InfraReady` (E-15).
- Comptes de test sans changement de mot de passe imposé (E-16).
- Le partage n'est pas chiffré au niveau SMB : acceptable dans le réseau privé du labo.
