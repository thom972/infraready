# Check-Dnscache.ps1 - Controle NON destructif de l'etat d'un service Windows.
# Codes de sortie : 0 = service en cours d'execution ; 1 = arrete ou introuvable.
# Limite : verifie l'etat local du client DNS, pas qu'un nom precis se resout.

$serviceName = "Dnscache"   # nom interne du client DNS Windows

# -ErrorAction SilentlyContinue : pas d'erreur rouge si le service n'existe pas, $service vaut alors $null
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {                       # cas 1 : service introuvable
    Write-Output "ERREUR : service introuvable : $serviceName"
    exit 1
}
if ($service.Status -eq "Running") {            # cas 2 : service actif
    Write-Output "OK : le service $serviceName est actif"
    exit 0
}
Write-Output "ERREUR : etat du service $serviceName : $($service.Status)"   # cas 3 : arrete, en pause...
exit 1
