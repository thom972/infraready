# InfraReady — Rapport d'incident

## 1. Incident
Interruption volontaire de la collecte des métriques
du serveur LINUX01 (192.168.50.20).

## 2. Contexte
LINUX01 est supervisé par Prometheus sur OPS01.
Node Exporter expose les métriques sur le port 9100.

Une alerte Grafana surveille la métrique :
up{job="linux01"}

## 3. Symptôme
Après l'arrêt du collecteur, Prometheus ne peut plus
récupérer les métriques de LINUX01.

## 4. Cause
Arrêt volontaire du service prometheus-node-exporter,
afin de simuler un incident de supervision.

Commande utilisée :
sudo systemctl stop prometheus-node-exporter

## 5. Correction
Redémarrage du collecteur :

sudo systemctl start prometheus-node-exporter

## 6. Vérification
L'alerte Grafana est revenue à l'état Normal
après le rétablissement de la collecte.

## 7. Prévention
- Surveiller la disponibilité des collecteurs.
- Maintenir l'activation automatique du service.
- Contrôler les journaux en cas d'interruption.

## 8. Preuves
À joindre :
- Capture de la règle d'alerte Grafana.
- Capture du retour à l'état Normal.
- Extrait des journaux du service.