# Séance 1 — Étape 1 : identifier les besoins du SI

*Statut : conception, aucune VM installée. Date : 19/10/2026.*

Référence : support pédagogique 1, étape 3.1 et fiche 1.

## Besoins relevés dans le scénario InfraReady

L'entreprise fictive veut **standardiser** ses configurations, rendre l'administration
**reproductible** et **surveiller** l'état de ses serveurs (sujet fil rouge, §1).
Exprimé en services rendus (et non en logiciels), le besoin comprend :

1. un **annuaire** pour gérer comptes et groupes de façon centralisée ;
2. une **résolution de noms** interne au domaine de laboratoire ;
3. un **service Linux** à administrer ;
4. un **point d'administration** pour automatiser les configurations ;
5. une **supervision** de l'état des serveurs.

## Matrice besoin / service / dépendances / risque / test futur

| # | Besoin | Service proposé | Machine prévue | Utilisateurs | Dépendances | Risque si indisponible | Niveau | Test de réception futur |
|---|---|---|---|---|---|---|---|---|
| B1 | Annuaire, comptes et groupes centralisés | AD DS | WIN-DC01 | Administrateurs, comptes de test | IP fixe, DNS | Plus d'authentification de domaine ni de gestion centralisée des comptes | Socle | `Get-ADDomain` renvoie `infraready.test` |
| B2 | Résolution des noms du domaine | DNS | WIN-DC01 | Toutes les VM | IP fixe de WIN-DC01, AD DS | Noms non résolus, contrôleur de domaine introuvable | Socle | `getent hosts WIN-DC01.infraready.test` renvoie 192.168.50.10 |
| B3 | Service applicatif Linux | Service à définir | LINUX01 | Utilisateurs du service | Réseau, DNS, stockage | Service rendu indisponible | Socle | `systemctl status <service>` actif + test applicatif |
| B4 | Administration reproductible | Ansible | OPS01 | Binôme | Accès SSH à LINUX01, DNS ou IP | Retour aux configurations manuelles, non reproductibles | Socle | `ansible linux -m ping` répond `pong` |
| B5 | Supervision des serveurs | Prometheus + Grafana + exporters | OPS01 (+ exporters sur LINUX01 et WIN-DC01) | Binôme | Exporters joignables (9100, 9182) | Incidents détectés tardivement ou pas du tout | Socle | Cibles `UP` dans Prometheus |
| B6 | Administration distante | SSH (Linux), RDP (facultatif) | Toutes | Binôme, depuis le poste hôte | Réseau du labo, comptes nominatifs | Intervention possible uniquement en console | SSH : socle · RDP : option | Connexion SSH authentifiée |
| B7 | Hébergement du laboratoire | Hyperviseur | Poste hôte | Tout le labo | RAM, disque et CPU de l'hôte | Tout le laboratoire est indisponible | Socle | Les 3 VM démarrent sans saturer l'hôte |

## Exigences du cas et propositions techniques

| Exigences du cas (imposées par le scénario) | Propositions techniques (choix de laboratoire) |
|---|---|
| Un annuaire, un service Linux, un point d'administration, une supervision | AD DS, Ansible, Prometheus, Grafana, node_exporter, windows_exporter |
| Un environnement Linux et Windows | Ubuntu Server 24.04 LTS, Windows Server 2025 Evaluation |
| Un laboratoire isolé, sans risque pour un réseau réel | Réseau privé 192.168.50.0/24, domaine `infraready.test` |
| Des opérations reproductibles | Dépôt Git, playbooks, scripts de vérification |

Le kit le rappelle (§1) : les outils sont une **proposition de laboratoire**, pas une
prescription. Ils peuvent être remplacés si l'écart est documenté.

## Question de contrôle (fiche 1)

**Si WIN-DC01 est indisponible, quels services sont affectés ?**

- **Affectés (dépendance réelle) :** l'authentification de domaine et la gestion des comptes (B1),
  la résolution des noms `infraready.test` pour toutes les VM (B2), et tout ce qui s'appuie sur
  un **nom** plutôt qu'une adresse IP (par exemple un inventaire Ansible qui utiliserait des noms DNS).
- **Non affectés :** la collecte des métriques de LINUX01 par OPS01 si la cible Prometheus
  est déclarée par adresse IP (`192.168.50.20:9100`), et l'accès SSH par IP.

**Dépendance réelle ou simple proximité ?** Sur le schéma, LINUX01 et WIN-DC01 sont dans la même
zone, mais cette proximité ne crée aucune dépendance. LINUX01 ne dépend de WIN-DC01 **que** par le DNS,
et seulement une fois qu'il est configuré pour l'utiliser. Une dépendance réelle se prouve par un
flux nécessaire au fonctionnement, pas par la position sur un dessin.
