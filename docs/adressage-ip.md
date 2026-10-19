# Plan d'adressage IP — InfraReady

## 1. Présentation du réseau

L'infrastructure InfraReady utilisera un réseau virtuel privé sous VMware Workstation Pro afin de permettre la communication entre les serveurs Linux et Windows.

Le plan d'adressage présenté est prévisionnel et devra être validé avant le déploiement.

## 2. Paramètres réseau

| Paramètre | Valeur prévisionnelle |
|---|---|
| Réseau | `192.168.50.0/24` |
| Masque de sous-réseau | `255.255.255.0` |
| Adresse réseau | `192.168.50.0` |
| Adresse de diffusion | `192.168.50.255` |
| Domaine Active Directory | `infraready.test` |
| Serveur DNS | `192.168.50.10` |
| Passerelle | À définir si nécessaire |
| Mode réseau VMware | Host-only ou Custom à valider |

## 3. Adressage des serveurs

| Machine | Adresse IPv4 | Préfixe | DNS prévu |
|---|---|---|---|
| WIN-DC01 | `192.168.50.10` | `/24` | DNS local du contrôleur de domaine |
| LINUX01 | `192.168.50.20` | `/24` | `192.168.50.10` |
| OPS01 | `192.168.50.30` | `/24` | `192.168.50.10` |

Les trois serveurs utiliseront des adresses IPv4 statiques.

## 4. Résolution DNS

WIN-DC01 hébergera le service DNS du domaine `infraready.test`.

Les machines Linux pourront utiliser ce serveur afin de résoudre les noms du laboratoire, sous réserve des enregistrements configurés.

La résolution DNS sera testée après l'installation et la configuration des systèmes.

## 5. Routage et passerelle

Les trois machines appartiendront au même sous-réseau.

Leurs communications internes ne nécessiteront donc pas de passerelle, à condition que le réseau virtuel permette leurs échanges directs.

Une passerelle sera configurée uniquement si un accès vers un autre réseau est nécessaire et qu'un routeur approprié existe.

L'accès Internet destiné aux mises à jour devra respecter les règles de sécurité du laboratoire.

## 6. Plan de tests prévisionnel

| ID | Vérification | Méthode prévue | Résultat attendu |
|---|---|---|---|
| T-01 | Adresse IP | `ip address` / `ipconfig /all` | Adresse conforme au plan |
| T-02 | Connectivité IP | `ping` | Communication ICMP si autorisée |
| T-03 | Résolution DNS | `getent hosts` / `Resolve-DnsName` | Nom résolu vers l'adresse attendue |
| T-04 | Accès au service | `curl` / `Test-NetConnection` | Service ou port attendu accessible |
| T-05 | Supervision | Interface Prometheus Targets | Cibles UP et métriques collectées |

**Résultats réels : non renseignés. Tests à exécuter après déploiement.**

## 7. Points à valider

- Absence de conflit avec le réseau local, les VPN ou les réseaux VMware existants.
- Choix définitif du réseau virtuel.
- Confirmation des adresses IP.
- Vérification du fonctionnement du DNS interne.
- Définition éventuelle d'une passerelle.
- Vérification des règles de pare-feu.
- Validation des communications entre les serveurs.

## 8. Conclusion

Ce plan d'adressage constitue la référence prévisionnelle de configuration réseau du projet InfraReady.

Les paramètres seront appliqués et vérifiés au moment du déploiement. Toute modification devra être reportée dans la documentation technique.