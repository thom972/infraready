<#
.SYNOPSIS
    Vérifications de réception de WIN-DC01 - LECTURE SEULE, ne modifie rien.

.EXAMPLE
    Set-ExecutionPolicy -Scope Process Bypass
    .\Verif-Reception.ps1 | Tee-Object -FilePath S02_win-dc01_reception.txt

    Relire la sortie avant de la committer : elle ne doit contenir aucun secret.
#>
[CmdletBinding()]
param(
    [string[]]$Targets = @('192.168.50.1', '192.168.50.20', '192.168.50.30')
)

function Section([string]$Title) { "`n### $Title" }

"=== Réception $env:COMPUTERNAME - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="

# 1. Configuration locale
Section 'Système'
Get-ComputerInfo | Select-Object CsName, WindowsProductName, OsVersion, OsBuildNumber | Format-List | Out-String
Section 'Durée restante de l''évaluation'
cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dlv | Select-String -Pattern 'expiration|Expiration|Description' | Out-String
Section 'Configuration IP'
Get-NetIPConfiguration | Select-Object InterfaceAlias,
    @{n='IPv4';       e={ $_.IPv4Address.IPAddress -join ', ' }},
    @{n='Passerelle'; e={ $_.IPv4DefaultGateway.NextHop -join ', ' }},
    @{n='DNS';        e={ ($_.DNSServer | Where-Object AddressFamily -eq 2).ServerAddresses -join ', ' }} |
    Format-List | Out-String
Section 'Profil réseau'
Get-NetConnectionProfile | Format-Table InterfaceAlias, NetworkCategory -AutoSize | Out-String

# 2. Connectivité
foreach ($t in $Targets) {
    Section "Ping $t"
    $r = Test-Connection -ComputerName $t -Count 2 -ErrorAction SilentlyContinue
    if ($r) { $r | Format-Table Address, ResponseTime, StatusCode -AutoSize | Out-String }
    else    { "Aucune réponse de $t" }
}

# 3. Résolution de noms
Section 'Résolution www.microsoft.com'
Resolve-DnsName www.microsoft.com -ErrorAction SilentlyContinue | Select-Object -First 3 | Out-String

# 4. Administration distante
Section 'WinRM'
Get-Service WinRM | Format-Table Name, Status, StartType -AutoSize | Out-String
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' -ErrorAction SilentlyContinue | ForEach-Object {
    [pscustomobject]@{
        Name          = $_.Name
        Enabled       = $_.Enabled
        RemoteAddress = ($_ | Get-NetFirewallAddressFilter).RemoteAddress -join ','
    }
} | Format-Table -AutoSize | Out-String
Section 'Règle ICMP du labo'
Get-NetFirewallRule -Name 'InfraReady-ICMPv4-In' -ErrorAction SilentlyContinue |
    Format-Table Name, Enabled, Profile -AutoSize | Out-String

# 5. Mises à jour et services
Section 'Dernières mises à jour installées'
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID, InstalledOn | Out-String
Section 'Services automatiques arrêtés'
Get-CimInstance Win32_Service -Filter "StartMode='Auto' AND State<>'Running'" |
    Select-Object Name, State | Format-Table -AutoSize | Out-String