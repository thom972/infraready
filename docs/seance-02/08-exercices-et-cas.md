# Séance 2 — Exercices et cas de diagnostic

Références : support 2 (§4, §9). Les parties « Obtenu » / « Conclusion » se remplissent avec ce
qui a été **réellement observé**.

## Exercice A — réception d'une VM

Répondre pour chaque VM à partir du tableau de réception :

| Question | WIN-DC01 | LINUX01 | OPS01 |
|---|---|---|---|
| Nom d'hôte, version, adresse, route, DNS relevés | | | |
| Conforme au plan d'adressage ? | | | |
| Quel était l'état initial ? | | | |
| Quelle preuve confirme le résultat ? | | | |
| Quelle limite reste-t-il ? | | | |

## Exercice B — diagnostiquer un échec de résolution

Cas réel attendu à cette séance : `getent hosts WIN-DC01.infraready.test` échoue depuis LINUX01 (R-18).

| Étape | Commande | Obtenu | Conclusion |
|---|---|---|---|
| 1. Configuration DNS | `resolvectl status` | | Quel serveur est interrogé ? |
| 2. Nom connu | `getent hosts ubuntu.com` | | Le résolveur fonctionne-t-il ? |
| 3. Test IP | `ping -c 3 192.168.50.10` | | La machine est-elle joignable ? |
| 4. Hypothèse | — | — | *Ex. : le serveur interrogé (192.168.50.1) ne connaît pas la zone `infraready.test`, qui n'existe pas encore.* |
| 5. Vérification supplémentaire | `resolvectl query WIN-DC01.infraready.test` | | |

- **État initial :** DNS temporaire 192.168.50.1, AD DS non installé.
- **Preuve :** sorties des étapes 1 à 3.
- **Limite :** la cause ne sera confirmée qu'en rejouant le test après la création de la zone.

## Exercice C — administration distante

| Cible | Mécanisme | Compte | Point d'entrée | Règle réseau nécessaire | Résultat |
|---|---|---|---|---|---|
| LINUX01 | SSH (clé) | compte nominatif | hôte → 192.168.50.20:22 | TCP 22 depuis l'hôte | |
| LINUX01 | SSH (clé) | `ansible` | OPS01 → 192.168.50.20:22 | TCP 22 depuis OPS01 | |
| OPS01 | SSH (clé) | compte nominatif | hôte → 192.168.50.30:22 | TCP 22 depuis l'hôte | |
| WIN-DC01 | WinRM | Administrateur | OPS01 → 192.168.50.10:5985 | Règle `WINRM-HTTP-In-TCP` limitée à 192.168.50.30 | |

Aucun mot de passe ni clé dans ce tableau.

## Cas 1 — adresse IP inattendue

Exemple : LINUX01 affiche une adresse en 192.168.50.1xx au lieu de .20.

| Question | Réponse |
|---|---|
| Fait observable | `ip -br address` montre une adresse DHCP |
| Hypothèse | Un fichier netplan avec `dhcp4: true` (ex. `50-cloud-init.yaml`) est encore actif ou régénéré par cloud-init |
| Test | `ls /etc/netplan/` ; `sudo netplan get` ; présence de `/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg` |
| Résultat obtenu et conclusion | |

Comparer adresse active, fichier de configuration et inventaire ; ne pas corriger d'après une capture ancienne.

## Cas 2 — SSH échoue

Séquence qui localise la couche défaillante (à exécuter dans l'ordre, en s'arrêtant au premier échec) :

| # | Couche | Test | Si échec |
|---|---|---|---|
| 1 | IP | `ping -c 3 <IP>` | Problème réseau / adresse |
| 2 | Port | `nc -zv <IP> 22` | Service arrêté ou filtré |
| 3 | Service (console de la cible) | `systemctl status ssh` ; `ss -lnt \| grep :22` | Démarrer / corriger le service |
| 4 | Clé (source) | `ls -l ~/.ssh/` : clé privée en `600` | `chmod 600` |
| 5 | Clé (cible) | `authorized_keys` : propriétaire, droits `600`, dossier `700` | Corriger droits / contenu |
| 6 | Détail | `ssh -v <compte>@<IP>` ; `journalctl -u ssh --since "10 min ago"` sur la cible | Lire le motif du refus |

## Cas 3 — remoting Windows échoue

| # | Vérification | Commande |
|---|---|---|
| 1 | Profil réseau | `Get-NetConnectionProfile` (doit être Privé) |
| 2 | Service WinRM | `Get-Service WinRM` |
| 3 | Écouteur | `winrm enumerate winrm/config/listener` |
| 4 | Règle de pare-feu et portée | `Get-NetFirewallRule -Name WINRM-HTTP-In-TCP \| Get-NetFirewallAddressFilter` |
| 5 | Depuis la source | `nc -zv 192.168.50.10 5985` depuis OPS01 |
| 6 | Identifiants et dépendances client | Compte utilisé ; bibliothèque `pywinrm` côté OPS01 (séance Ansible) |

**Ne jamais** désactiver le pare-feu global. Livrable : état de chaque vérification et prochaine action justifiée.
