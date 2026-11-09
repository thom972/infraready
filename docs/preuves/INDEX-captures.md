# Index des captures d'écran

| Fichier | Contenu |
|---|---|
| `S01_schema-architecture-cible-v1.png` | Séance 1 - première version du schéma d'architecture cible |
| `S02_installeur-ubuntu-profil.png` | Installeur Ubuntu Server : écran du profil (nom, serveur, compte ; mot de passe masqué) |
| `S02_hote_virt-viewer-telechargement.png` | Téléchargement de virt-viewer (presse-papiers SPICE) |
| `S02_ref_spice-telechargements.png` | Référence : page de téléchargement SPICE (clients) |
| `S02_ref_spice-guest-tools.png` | Référence : spice-guest-tools pour Windows |
| `S02_ops01_installeur-reseau-dhcp.png` | Installeur d'OPS01 : carte enp1s0 en DHCP (192.168.50.114) |
| `S02_ops01_desactivation-cloud-init-reseau.png` | OPS01 : désactivation de la configuration réseau cloud-init |
| `S02_ops01_netplan-00-installer-config.png` | OPS01 : fichier netplan créé par l'installeur (00-installer-config.yaml) |
| `S02_ops01_netplan-01-lab-edition.png` | OPS01 : édition de /etc/netplan/01-lab.yaml |
| `S02_ops01_netplan-erreur-indentation.png` | OPS01 : erreur d'indentation YAML détectée par netplan generate |
| `S02_ops01_netplan-try-ip-fixe.png` | OPS01 : netplan try accepté, IP fixe 192.168.50.30, passerelle et DNS OK |
| `S02_ops01_empreinte-ssh-compte-keo.png` | Empreinte SSH d'OPS01 vérifiée, compte keo, administrateur verrouillé |
| `S02_linux01_compte-ansible-test-ssh.png` | Compte ansible sur LINUX01 (sans sudo) et premier SSH depuis OPS01 |
| `S02_ops01_copie-config-ansible.png` | Copie de la configuration Ansible vers OPS01 |
| `S02_ops01_ansible-ping-linux01.png` | R-15 : ansible linux -m ping -> pong |
| `S02_winrm-ops01-ok-linux01-refuse.png` | R-16 / R-17 : WinRM accepté depuis OPS01 (405), refusé depuis LINUX01 (timeout) |
| `S04_win-dc01_test-et-promotion-adds.png` | Test-ADDSForestInstallation réussi puis Install-ADDSForest (avertissements de délégation DNS) |
| `S06_grafana-accueil.png` | Grafana : connexion réussie (mot de passe du coffre), page d'accueil |
| `S06_prometheus-graph-vide.png` | Prometheus : page Graph sans requête |
| `S06_prometheus-paquet-sans-interface-moderne.png` | Prometheus : le paquet Ubuntu ne fournit que l'interface classique (limite connue) |
| `S06_grafana-tableau-de-bord-4-cibles-up.png` | Grafana : tableau de bord InfraReady, 4 cibles UP |
| `S06_prometheus-classic-graph.png` | Prometheus : interface classique, page Graph |
| `S06_prometheus-cibles.png` | Prometheus : cibles du job linux UP (étiquettes hote) |
| `S06_grafana-seuil-disque-depasse.png` | Démonstration du seuil : /srv/infraready à 7,68 % libre (barre rouge), alerte encore pending |
| `S07_grafana-etat-initial.png` | Incident - état initial : 4 cibles UP, aucune alerte |
| `S07_grafana-pending.png` | Incident : LINUX01 DOWN, alerte HoteInjoignable pending |
| `S07_grafana-alertes-pending.png` | Incident : panneau des alertes, HoteInjoignable pending |
| `S07_prometheus-pending.png` | Incident : Prometheus, alerte PENDING depuis 09:34:09 UTC |
| `S07_grafana-firing.png` | Incident : LINUX01 DOWN, alerte firing |
| `S07_prometheus-firing.png` | Incident : Prometheus, alerte FIRING (règle up == 0, for: 1m) |
| `S07_grafana-retour-normale.png` | Incident : retour à la normale (4 UP), fausse montée du processeur visible |
| `S07_prometheus-retour-normale.png` | Incident : retour à la normale, 4 règles inactives |
| `S08_hote_erreur-iso-manquante.png` | WIN-DC01 refuse de démarrer : ISO d'installation introuvable |
| `S08_hote_win-dc01-lecteur-cdrom.png` | Lecteur CD de WIN-DC01 encore relié à l'ISO (à vider) |
