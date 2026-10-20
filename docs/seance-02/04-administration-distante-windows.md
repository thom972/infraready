# Séance 2 — Étape 5 : préparer l'administration distante de Windows

Références : support 2 (§2.5, fiche 5, cas 3), sujet fil rouge (§5.3, §6.4), écarts E-08 et E-09.

## Principe

Le sujet impose un transport Windows (WinRM ou PSRP) **configuré et testé** pour les playbooks
Windows. À cette séance, on prépare ce transport de façon **limitée** :

- seul OPS01 (192.168.50.30) peut joindre WinRM (TCP 5985) ;
- uniquement sur le profil réseau Privé ;
- **sans** désactiver le pare-feu, sans authentification Basic, sans trafic non chiffré, sans
  `TrustedHosts = *`.

On valide d'abord l'accès PowerShell **natif** (en local), puis l'accès réseau depuis OPS01.
L'automatisation Ansible de Windows viendra à la séance dédiée (support 2, §2.5).

## 1. État initial (sur WIN-DC01, PowerShell administrateur)

```powershell
Get-NetConnectionProfile
Get-Service WinRM
winrm enumerate winrm/config/listener
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' | Format-Table Name, Enabled, Profile
```

Sur Windows Server, WinRM est en général déjà actif avec un écouteur HTTP sur 5985 : le travail
consiste surtout à **restreindre** qui peut s'y connecter.

## 2. Appliquer la configuration limitée

Copier `scripts/windows/Set-WinRMLabScope.ps1` dans la VM (presse-papiers SPICE), puis :

```powershell
Set-ExecutionPolicy -Scope Process Bypass   # uniquement pour cette session PowerShell
.\Set-WinRMLabScope.ps1 -WhatIf            # simulation : lire ce qui serait modifié
.\Set-WinRMLabScope.ps1                    # application
```

## 3. Tester l'accès natif, en local

```powershell
Test-WSMan -ComputerName localhost
Invoke-Command -ComputerName localhost -ScriptBlock { hostname }
```

Attendu : réponse de `Test-WSMan` (version du protocole) et `WIN-DC01`.

## 4. Tester depuis le réseau

| Source | Commande | Attendu | Ce que ça prouve |
|---|---|---|---|
| OPS01 | `nc -zv 192.168.50.10 5985` | `succeeded` | Le port est ouvert pour OPS01 |
| OPS01 | `curl -s -o /dev/null -w '%{http_code}\n' http://192.168.50.10:5985/wsman` | Un code HTTP (souvent `405`) | Le service WinRM répond (la méthode GET n'est simplement pas acceptée) |
| LINUX01 | `nc -zv -w 3 192.168.50.10 5985` | Échec (délai dépassé) | La restriction à OPS01 fonctionne |

Le dernier test est important : il prouve que la règle est **limitée**, pas seulement ouverte.

## 5. Ce qui est volontairement reporté

| Élément | Quand | Pourquoi |
|---|---|---|
| Connexion Ansible (`win_ping`) via `pywinrm`, NTLM, identifiants dans Ansible Vault | Séance Ansible | Dépend des bibliothèques Python et du compte retenu (support 2, §2.5) |
| WinRM HTTPS (5986) avec certificat | Option | Nécessite un certificat ; à étudier si le temps le permet |
| RDP (3389) | Non activé | La console SPICE suffit ; moindre privilège (E-09) |

## Preuves à produire

| Fichier | Contenu |
|---|---|
| `S02_win-dc01_winrm.txt` | Sortie de `Set-WinRMLabScope.ps1` (état initial et final) |
| `S02_ops01_winrm-port.txt` | `nc` et `curl` depuis OPS01 |
| `S02_linux01_winrm-refuse.txt` | Échec attendu depuis LINUX01 |
