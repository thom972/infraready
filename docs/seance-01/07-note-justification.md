# Séance 1 — Note de justification de l'architecture

*Date : 19/10/2026 — statut : prévisionnel.*

## Choix retenus

1. **Trois VM aux rôles séparés** (annuaire Windows, service Linux, administration/supervision).
   Séparer les rôles limite l'impact d'une panne et clarifie les flux : la supervision et
   l'automatisation restent disponibles même si un serveur supervisé tombe.
2. **Réseau privé de laboratoire 192.168.50.0/24.** Les services du labo ne sont pas publiés sur
   le réseau réel ; l'accès Internet, s'il est nécessaire aux mises à jour, sera organisé de façon
   contrôlée. Ce plan est un exemple du kit, à valider contre le LAN et le VPN.
3. **Adresses fixes pour les serveurs.** Un contrôleur de domaine et des cibles de supervision
   doivent rester joignables à une adresse stable.
4. **Domaine `infraready.test`.** Le suffixe `.test` est réservé aux tests et ne peut pas entrer
   en conflit avec un domaine public réel (kit §8).
5. **Flux minimaux et nommés.** Chaque flèche du schéma correspond à un besoin (matrice F1 à F7).
   RDP est marqué facultatif ; aucun flux « autoriser tout ».
6. **OPS01 centralise l'exploitation.** Ansible, Prometheus et Grafana sur une même VM : un seul
   point d'administration à protéger, et Grafana interroge Prometheus en local.
7. **Flux SSH OPS01 → LINUX01 ajouté** à la matrice du kit : le kit installe Ansible sur OPS01
   avec un inventaire qui cible LINUX01 (kit §10). Ansible se connecte en SSH, ce flux est donc
   indispensable.

## Points restant à valider (séance 2)

- Mode du réseau virtuel de l'hyperviseur.
- Absence de chevauchement du plan IP avec le LAN, le VPN et les réseaux virtuels existants.
- Ressources de l'hôte (RAM, disque) suffisantes pour les trois VM, sinon regroupement OPS01/LINUX01
  après accord du formateur.
- Disponibilité et intégrité des images d'installation officielles.
- Port réel de windows_exporter (9182 supposé) et nature exacte du service Linux.

## Points relevés en lisant les documents

- **Mises à jour Ubuntu :** la matrice du kit n'autorise que le TCP 443 sortant, mais les miroirs
  APT d'Ubuntu 24.04 sont en `http://` par défaut (TCP 80). À traiter en séance 2.
- **Administration Windows par Ansible :** le kit (§10) indique que WinRM/PSRP n'est pas activé
  au départ, alors que le sujet fil rouge (§5.3, §6.4) impose un playbook Windows et un transport
  WinRM ou PSRP testé. Le kit précise que le sujet prime en cas de conflit : le flux
  OPS01 → WIN-DC01 (WinRM) sera ajouté lors de la préparation de l'administration distante.

## Risques

- Saturation de la RAM de l'hôte si les trois VM tournent avec les valeurs hautes.
- Configuration DNS incohérente avant la promotion du contrôleur de domaine.
- Coupure d'accès lors du passage en IP fixe (à faire depuis la console de la VM).
