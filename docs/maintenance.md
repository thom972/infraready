# InfraReady — Maintenance des serveurs

## 1. Objectif

Maintenir les serveurs Linux et Windows à jour,
contrôler les services essentiels et surveiller
l'espace disque.

## 2. Maintenance Linux — LINUX01

La maintenance est automatisée avec Ansible depuis OPS01.

Playbook : playbooks/maintenance.yml

Commande d'exécution :

ansible-playbook -i inventory/hosts.yml \
playbooks/maintenance.yml --ask-become-pass

Le playbook réalise :
- La mise à jour des paquets Ubuntu.
- La vérification du serveur web InfraReady.
- La vérification de Node Exporter.
- Le contrôle du montage /mnt/infraready-data.
- Le contrôle de l'espace disque.

Résultat obtenu :
- 7 tâches réussies.
- 1 modification effectuée.
- 0 erreur.
- Disque système utilisé à 33 % lors du contrôle.

Un snapshot VMware a été créé avant la maintenance.

## 3. Maintenance Windows — WIN-DC01

Système : Windows Server 2025.

Procédure :
1. Créer un snapshot VMware avant intervention.
2. Ouvrir Paramètres > Windows Update.
3. Rechercher les mises à jour.
4. Examiner les mises à jour proposées.
5. Planifier tout redémarrage nécessaire.
6. Vérifier Active Directory et DNS.

Résultat obtenu le 9 novembre 2026 :
Windows Update indique « Vous êtes à jour ».

Commande de vérification des services :

Get-Service NTDS,DNS

Résultat :
- DNS : Running.
- NTDS : Running.

## 4. Précautions

- Créer un snapshot avant les changements importants.
- Vérifier l'état des services avant intervention.
- Ne pas interrompre les mises à jour en cours.
- Éviter les redémarrages non planifiés.
- Vérifier les services après intervention.
- Documenter toute erreur rencontrée.

## 5. Supervision

Prometheus et Grafana supervisent :
- WIN-DC01
- LINUX01
- OPS01

Les métriques concernent :
- CPU
- RAM
- Stockage
- Disponibilité

Une alerte Grafana surveille la disponibilité
du collecteur de métriques de LINUX01.