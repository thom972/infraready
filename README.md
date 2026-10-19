# infraready
Projet fil rouge Bachelor 3 - Administration systèmes Linux / Windows
1. Présentation du projet

InfraReady est un projet pédagogique visant à concevoir, déployer, administrer, automatiser et superviser une infrastructure informatique composée de serveurs Linux et Windows.

Le projet se déroule en binôme sur huit séances, pour une durée totale de 35 heures.

L'objectif est de mettre en place une infrastructure fonctionnelle, sécurisée, documentée et reproductible.
2. Architecture prévisionnelle

L'infrastructure repose sur trois machines virtuelles hébergées avec VMware Workstation Pro.
Machine	Système d'exploitation	Adresse IP proposée	Rôle
WIN-DC01	Windows Server 2025	192.168.50.10	Active Directory et DNS
LINUX01	Ubuntu Server 24.04 LTS	192.168.50.20	Services Linux et stockage
OPS01	Ubuntu Server 24.04 LTS	192.168.50.30	Ansible, Prometheus et Grafana

Réseau prévisionnel : 192.168.50.0/24

Domaine Active Directory proposé : infraready.test

Ces paramètres devront être validés avant leur application.
3. Technologies utilisées

    VMware Workstation Pro

    Windows Server 2025

    Ubuntu Server 24.04 LTS

    Active Directory Domain Services (AD DS)

    DNS

    Ansible

    Git et GitHub

    GitHub Actions

    Prometheus et Grafana

    Node Exporter et Windows Exporter

4. Organisation du dépôt
Dossier	Description
docs/	Documentation technique
inventory/	Inventaire des hôtes et variables Ansible
playbooks/	Automatisation Linux et Windows
roles/	Rôles Ansible
monitoring/	Supervision et tableaux de bord
scripts/	Scripts d'administration
preuves/	Captures et résultats de tests
.github/workflows/	Validation GitHub Actions
5. Étapes du projet

    Installation et configuration réseau

    Administration Windows Server et Active Directory

    Administration Linux, stockage et permissions

    Automatisation Linux et Windows avec Ansible

    Maintenance et mises à jour

    Supervision avec Prometheus et Grafana

    Validation automatique avec GitHub Actions

    Diagnostic d'incident et livraison finale

6. Sécurité

Le laboratoire est réservé aux machines virtuelles autorisées.

Les accès d'administration seront limités et les permissions seront attribuées selon le principe du moindre privilège.

Aucun mot de passe, jeton ou clé privée ne sera enregistré en clair dans le dépôt.

Les opérations risquées devront être précédées d'une vérification et, lorsque cela est adapté, d'un snapshot.
7. État d'avancement
Partie	Statut
Conception de l'architecture	En cours
Installation des VM	À faire
Administration Windows	À faire
Administration Linux	À faire
Automatisation Ansible	À faire
Maintenance	À faire
Supervision	À faire
GitHub Actions	À faire
Diagnostic d'incident	À faire
8. Livrables attendus

    Dépôt GitHub contenant les configurations, scripts et playbooks

    Dossier technique PDF

    Preuves de fonctionnement

    Rapport d'incident

    Présentation PowerPoint avec démonstration finale

État actuel : phase de conception et de préparation. Aucune fonctionnalité de l'infrastructure n'est encore déclarée comme déployée ou validée.
