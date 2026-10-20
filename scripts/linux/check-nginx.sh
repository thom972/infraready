#!/usr/bin/env bash
# check-nginx.sh - Contrôle NON destructif de l'état d'un service systemd.
# Codes de sortie : 0 = service actif ; 1 = service inactif ou absent.
# Limite : vérifie l'état local du service, pas qu'il répond en HTTP.

set -u                          # erreur si une variable non définie est utilisée
SERVICE="nginx"                 # nom du service à contrôler

# systemctl is-active renvoie le code 0 si le service est actif ; --quiet n'affiche rien
if systemctl is-active --quiet "$SERVICE"; then
    echo "OK : le service $SERVICE est actif"
    exit 0                      # succès, exploitable par un autre script ou par Ansible
else
    echo "ERREUR : le service $SERVICE n'est pas actif"
    exit 1                      # échec ; le script ne tente AUCUNE réparation
fi
