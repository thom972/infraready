# Sécurité et gestion des accès

## Secrets

- Mots de passe (comptes Linux, Administrateur Windows, futur DSRM) : **uniquement** dans le
  gestionnaire de mots de passe du binôme. Jamais dans Git, un message, une capture ou un fichier texte.
- Clés privées SSH : sur le poste qui les utilise (hôte pour l'administration, OPS01 pour Ansible),
  droits `600`, protégées par phrase de passe. Les clés publiques seules sont copiées sur les cibles.
- Futurs identifiants Windows pour Ansible : Ansible Vault, fournis à l'exécution.
- Avant chaque commit : `git diff --staged` relu ; le `.gitignore` bloque ISO, disques et clés.

## Comptes

| Machine | Compte | Usage | Authentification | Privilèges |
|---|---|---|---|---|
| LINUX01, OPS01 | Compte nominatif du binôme | Administration | Clé SSH (mot de passe en secours console) | sudo |
| LINUX01 | `ansible` | Automatisation depuis OPS01 | Clé SSH uniquement (pas de mot de passe) | Aucun sudo pour l'instant (E-10) |
| WIN-DC01 | Administrateur | Administration locale | Mot de passe robuste | Administrateur |

Pas de connexion root directe en SSH (comportement par défaut d'Ubuntu, kit §5.3).

## Flux autorisés (état séance 2)

| Source | Destination | Port | Motif |
|---|---|---|---|
| Hôte | LINUX01, OPS01 | TCP 22 | Administration SSH |
| OPS01 | LINUX01 | TCP 22 | Ansible |
| OPS01 | WIN-DC01 | TCP 5985 | WinRM (règle limitée à 192.168.50.30, E-08) |
| VM du labo | WIN-DC01 | ICMP echo | Tests de connectivité (règle limitée à 192.168.50.0/24) |
| VM du labo | Internet via NAT | TCP 80, 443, DNS | Mises à jour (miroirs APT en `http://`, Windows Update) |

## Interdits

- Désactiver globalement le pare-feu Windows pour « faire marcher » une connexion.
- `TrustedHosts = *`, authentification Basic ou `AllowUnencrypted` pour WinRM.
- Créer une règle « autoriser tout » au lieu de diagnostiquer le flux précis.
- Scanner ou tester des systèmes extérieurs au laboratoire.
