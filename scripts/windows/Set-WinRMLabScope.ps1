<#
.SYNOPSIS
    Prépare l'administration distante de WIN-DC01 en la limitant à OPS01.

.DESCRIPTION
    - Vérifie que l'interface du labo est en profil Privé (WinRM ne doit pas être ouvert sur un réseau public).
    - Vérifie le service WinRM et son écouteur HTTP (5985) ; active PowerShell Remoting s'il ne l'est pas.
    - Restreint la règle de pare-feu WinRM entrante à l'adresse d'OPS01 et désactive la variante "Public".
    - Ne désactive jamais le pare-feu, n'active ni Basic ni le trafic non chiffré, ne touche pas à TrustedHosts.

.PARAMETER OpsIp
    Adresse autorisée à joindre WinRM (OPS01 par défaut).

.EXAMPLE
    Set-ExecutionPolicy -Scope Process Bypass
    .\Set-WinRMLabScope.ps1 -WhatIf      # simulation, rien n'est modifié
    .\Set-WinRMLabScope.ps1              # application
#>
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$OpsIp = '192.168.50.30'
)

$ErrorActionPreference = 'Stop'

Write-Host "== État initial ==" -ForegroundColor Cyan
Get-NetConnectionProfile | Format-Table InterfaceAlias, NetworkCategory -AutoSize
Get-Service WinRM | Format-Table Name, Status, StartType -AutoSize

# 1. Refuser de continuer si une interface est en profil Public
$public = Get-NetConnectionProfile | Where-Object NetworkCategory -eq 'Public'
if ($public) {
    throw "Interface(s) en profil Public : $($public.InterfaceAlias -join ', '). Passer le réseau du labo en Privé avant d'activer WinRM."
}

# 2. Service WinRM et écouteur
$svc = Get-Service WinRM
if ($svc.Status -ne 'Running' -or $svc.StartType -ne 'Automatic') {
    if ($PSCmdlet.ShouldProcess('WinRM', 'Enable-PSRemoting')) {
        Enable-PSRemoting -Force
    }
}

# 3. Restreindre la règle entrante WinRM HTTP à OPS01
$rule = Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -ErrorAction SilentlyContinue
if (-not $rule) { throw "Règle WINRM-HTTP-In-TCP introuvable : vérifier Enable-PSRemoting." }
if ($PSCmdlet.ShouldProcess('WINRM-HTTP-In-TCP', "Limiter RemoteAddress à $OpsIp")) {
    Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress $OpsIp -Enabled True
}
$publicRule = Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP-PUBLIC' -ErrorAction SilentlyContinue
if ($publicRule -and $PSCmdlet.ShouldProcess('WINRM-HTTP-In-TCP-PUBLIC', 'Désactiver')) {
    Disable-NetFirewallRule -Name 'WINRM-HTTP-In-TCP-PUBLIC'
}

Write-Host "== État final ==" -ForegroundColor Cyan
Get-Service WinRM | Format-Table Name, Status, StartType -AutoSize
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' |
    ForEach-Object {
        [pscustomobject]@{
            Name          = $_.Name
            Enabled       = $_.Enabled
            Profile       = $_.Profile
            RemoteAddress = ($_ | Get-NetFirewallAddressFilter).RemoteAddress -join ','
        }
    } | Format-Table -AutoSize
Test-WSMan -ComputerName localhost
