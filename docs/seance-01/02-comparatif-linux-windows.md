# Séance 1 — Étape 2 : comparer Linux et Windows Server

Référence : support pédagogique 1, §2.2 et étape 3.2.
Systèmes ciblés : Ubuntu Server 24.04 LTS et Windows Server 2025.

## Tableau comparatif

| Concept | Ubuntu Server (outil étudié plus tard) | Windows Server (outil étudié plus tard) |
|---|---|---|
| Comptes | `adduser`, `usermod`, `/etc/passwd`, `/etc/shadow` | Comptes locaux (`New-LocalUser`) puis comptes de domaine (`New-ADUser`, console « Utilisateurs et ordinateurs AD ») |
| Groupes | `groupadd`, `usermod -aG`, `/etc/group` | `New-ADGroup`, `Add-ADGroupMember`, groupes locaux |
| Permissions | Droits POSIX (`chmod`, `chown`), ACL (`setfacl`), `sudo` | ACL NTFS (`icacls`, `Get-Acl`), droits d'administration délégués |
| Processus | `ps`, `top`, `kill`, `/proc` | Gestionnaire des tâches, `Get-Process`, `Stop-Process` |
| Services | `systemctl` (unités systemd) | `services.msc`, `Get-Service`, `Set-Service` |
| Journaux | `journalctl`, `/var/log/` | Observateur d'événements, `Get-WinEvent` |
| Mises à jour | `apt update`, `apt upgrade` | Windows Update, `sconfig` |
| Réseau | Netplan (`/etc/netplan/*.yaml`), `ip`, `resolvectl` | `Get-NetIPConfiguration`, `New-NetIPAddress`, `Set-DnsClientServerAddress` |
| Configuration | Fichiers texte dans `/etc` | Registre, rôles et fonctionnalités, stratégies de groupe (GPO) |
| Administration distante | SSH | PowerShell Remoting (WinRM), RDP |
| Automatisation native | Shell (bash), scripts | PowerShell (langage de script complet) |

## Explications rédigées (trois concepts)

**Services.** Les deux systèmes font tourner des programmes en arrière-plan qui démarrent avec la
machine. Sous Ubuntu, `systemd` les décrit dans des fichiers d'unité texte. `systemctl status ssh`
montre l'état, `systemctl enable` contrôle le démarrage automatique et les dépendances entre unités sont
déclarées (`After=`, `Wants=`). Sous Windows, le Gestionnaire de contrôle des services joue ce rôle :
le type de démarrage (automatique, manuel, désactivé) et le compte d'exécution se règlent dans
`services.msc` ou avec `Set-Service`. Le concept est identique (démarrer, arrêter, surveiller
un service), mais l'outil et le stockage de la configuration diffèrent.

**Journaux.** Linux centralise les journaux dans `journald`, interrogé avec `journalctl`
(par exemple `journalctl -u ssh` pour un service, `-p warning` pour filtrer la gravité). Certains
fichiers texte restent aussi dans `/var/log`. Windows classe les événements dans des journaux
(Système, Application, Sécurité), chaque entrée portant un identifiant d'événement, une source et
un niveau. On les lit dans l'Observateur d'événements ou avec `Get-WinEvent`. Dans les deux cas,
on diagnostique en recherchant les entrées autour de l'heure du problème.

**Permissions.** Linux attribue à chaque fichier un propriétaire, un groupe et des droits de lecture,
d'écriture et d'exécution pour trois catégories (propriétaire, groupe, autres), complétés si besoin
par des ACL. L'élévation de privilèges passe par `sudo`, qui trace qui a fait quoi. Windows utilise
des ACL NTFS plus fines (contrôle total, modification, lecture…), avec héritage entre dossiers, et
une séparation entre compte standard et compte administrateur (UAC). Le principe du moindre
privilège s'applique de la même façon des deux côtés.

## Pourquoi deux systèmes rendent des services équivalents avec des mécanismes différents

Un service se définit par **ce qu'il rend** (résoudre un nom, authentifier, servir une page), pas
par l'outil qui le configure. Linux suit une philosophie de petits outils et de fichiers texte.
Windows Server suit une logique de rôles installables, de consoles graphiques et d'objets
manipulés par PowerShell. Un administrateur doit maîtriser les outils **natifs** de chaque système
plutôt que d'imposer à l'un les habitudes de l'autre (support 1, §2.2).

## Termes à savoir définir avant le premier TP

Serveur, rôle, service, flux, adresse IP, masque/préfixe, passerelle, DNS, enregistrement DNS,
port TCP/UDP, pare-feu, SSH, WinRM, AD DS, contrôleur de domaine, exporter, snapshot,
moindre privilège, compte nominatif, test de réception.
