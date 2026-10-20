# Séance 2 — Étape 4 : installer WIN-DC01

Références : support 2 (§2.4, fiche 4), kit (§4.2, §5.2, §7, §7.1).

> AD DS n'est **pas** installé à cette séance : on prépare un serveur nommé, adressé et à jour.
> Le DNS est pensé pour la future promotion (kit §7.1, fiche 4).

## 1. Créer la VM dans virt-manager

| Paramètre | Valeur | Remarque |
|---|---|---|
| Nom de la VM | `WIN-DC01` | |
| Média | ISO Windows Server 2025 Evaluation (64 bits) | Centre d'évaluation Microsoft |
| RAM / vCPU | 4096 Mo / 2 | Plan de ressources, étape 1 |
| Disque | 50 Go, qcow2, bus **SATA** | Reconnu par l'installeur Windows sans pilote supplémentaire |
| Carte réseau | Réseau `infraready`, modèle **e1000e** | Pilote intégré à Windows |
| Affichage / vidéo | Spice / QXL ou Virtio | Le canal `com.redhat.spice.0` doit exister (presse-papiers) |

Alternative plus performante : bus disque et carte **virtio**, à condition de monter l'ISO
`virtio-win` pendant l'installation pour charger les pilotes. Le choix réel est consigné en E-06.

## 2. Installer Windows Server 2025

1. Langue / clavier, puis **Installer maintenant**.
2. Édition **Windows Server 2025 Standard Evaluation (Desktop Experience)**.
3. Installation **personnalisée** sur le disque virtuel vide de la VM.
4. Mot de passe **Administrateur** robuste, stocké uniquement dans le gestionnaire de mots de passe.

## 3. Intégration à l'hyperviseur (presse-papiers)

Installer **spice-guest-tools** depuis https://www.spice-space.org/download.html, section
*Guest → Windows binaries* (fichier `spice-guest-tools-latest.exe`, exécuté en administrateur),
puis redémarrer. Vérifier dans `services.msc` que **Spice Agent** est en cours d'exécution.
Logiciel ajouté → consigné en E-07.

## 4. Mises à jour initiales

Paramètres → Windows Update → rechercher et installer, redémarrer, **recommencer** jusqu'à ce
qu'aucune mise à jour ni aucun redémarrage ne soit en attente.

## 5. Renommer le serveur (PowerShell administrateur)

```powershell
Rename-Computer -NewName "WIN-DC01" -Restart
```

## 6. Adresse IP fixe (fiche 4) — depuis la console de la VM

Identifier d'abord l'interface et vérifier que l'adresse est libre :

```powershell
Get-NetAdapter                                   # noter le nom exact (souvent "Ethernet")
Get-NetIPConfiguration                           # état initial, à conserver comme preuve
```

Depuis l'hôte, avant d'appliquer : `ping -c 2 192.168.50.10` ne doit **pas** répondre (adresse libre).

```powershell
$if = "Ethernet"    # remplacer par le nom relevé avec Get-NetAdapter
Set-NetIPInterface -InterfaceAlias $if -AddressFamily IPv4 -Dhcp Disabled
Get-NetIPAddress -InterfaceAlias $if -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false
Get-NetRoute -InterfaceAlias $if -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false
New-NetIPAddress -InterfaceAlias $if -IPAddress 192.168.50.10 -PrefixLength 24 -DefaultGateway 192.168.50.1
Set-DnsClientServerAddress -InterfaceAlias $if -ServerAddresses 192.168.50.1
Set-NetConnectionProfile -InterfaceAlias $if -NetworkCategory Private
```

- Les deux lignes `Remove-...` suppriment l'adresse et la route obtenues par DHCP, pour éviter une
  configuration concurrente (kit §7.1).
- **DNS avant / après** (à documenter) : avant AD DS → 192.168.50.1 (permet les mises à jour) ;
  après installation du rôle DNS → `127.0.0.1` / 192.168.50.10. Jamais un DNS public comme
  unique serveur d'un membre du domaine (fiche 4).
- Profil **Privé** : le réseau du labo n'est pas un réseau public ; c'est aussi le profil sur
  lequel les règles WinRM s'appliquent.

## 7. Autoriser le ping depuis le labo uniquement

Windows bloque l'ICMP entrant par défaut. Règle limitée au sous-réseau du labo, sans toucher au
reste du pare-feu :

```powershell
New-NetFirewallRule -Name 'InfraReady-ICMPv4-In' -DisplayName 'InfraReady - Echo ICMPv4 depuis le labo' `
  -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress 192.168.50.0/24 -Profile Private -Action Allow
```

## 8. Vérifier

```powershell
Get-ComputerInfo | Select-Object CsName, WindowsProductName, OsVersion
Get-NetIPConfiguration
Get-DnsClientServerAddress -AddressFamily IPv4
Get-NetConnectionProfile
Test-Connection 192.168.50.1 -Count 2
Resolve-DnsName www.microsoft.com
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
slmgr /dlv                                        # durée restante de l'évaluation, à noter
```

Le script [`scripts/windows/Verif-Reception.ps1`](../../scripts/windows/Verif-Reception.ps1)
regroupe ces contrôles. Depuis LINUX01 : `ping -c 3 192.168.50.10`.

## 9. Snapshot de référence

`00-installation-propre`, **avant** toute installation de rôle (AD DS viendra ensuite).

## Preuves à produire

| Fichier | Contenu |
|---|---|
| `S02_win-dc01_reception.txt` | Sortie de `Verif-Reception.ps1` |
| `S02_win-dc01_ip.png` | `Get-NetIPConfiguration` après configuration |
| `S02_linux01_ping-win-dc01.txt` | Ping de LINUX01 vers 192.168.50.10 |
