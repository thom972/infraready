# Traçabilité : exigences → fichiers → preuves

*Mise à jour : séance 8.* Chaque exigence du sujet (§6, parties A à H) est reliée aux fichiers qui la réalisent
ou la documentent, puis aux preuves de `docs/preuves/` (index : [`preuves/README.md`](preuves/README.md)).
Statut **OK** : exigence réalisée et prouvée.

## A. Installation et réseau

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Créer les machines virtuelles | `docs/seance-02/0[2-5]-installation-*.md`, `docs/architecture.md` | `S02_*_reception.txt` (×3), `S04_linux01_disques-hyperviseur.txt`, `S08_hote_win-dc01-materiel.txt` | OK |
| Noms d'hôtes et adresses IP | `docs/adressage-ip.md`, `configs/*/netplan/01-lab.yaml` | `S02_linux01_reception.txt`, `S02_ops01_netplan-try-ip-fixe.png`, `S02_win-dc01_reception.txt` | OK |
| Réseau virtuel adapté | `infra/libvirt/infraready-network.xml`, écarts E-03, E-04 | `S02_hote_reseau-infraready.txt` | OK |
| Connectivité entre machines | `scripts/linux/verif-reception.sh`, `scripts/windows/Verif-Reception.ps1` | `S02_*_reception.txt` (ping), `S04_dns-clients-linux.txt` (rtt) | OK |
| Résolution DNS | `docs/adressage-ip.md`, netplan (`search infraready.test`) | `S04_dns-clients-linux.txt`, `S04_win-dc01_zone-dns.txt` ; contrôle automatique dans `playbooks/securite.yml` | OK |
| Schéma d'architecture | `docs/schemas/infraready-architecture.drawio`, `docs/architecture.md` | `S01_schema-architecture-cible-v1.png` (version initiale) | OK |

## B. Administration Windows

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Rôle AD DS, domaine de laboratoire | `docs/seance-02/03-installation-win-dc01.md` | `S04_win-dc01_test-et-promotion-adds.png`, `S04_win-dc01_dcdiag.txt` | OK |
| Configurer DNS | — | `S04_win-dc01_zone-dns.txt`, `S04_win-dc01_dns-srv.txt` | OK |
| Au moins deux groupes, plusieurs comptes | `playbooks/windows.yml`, `inventory/group_vars/windows/ad.yml` | `S04_win-dc01_ad-structure.txt`, `S04_win-dc01_aduc-groupes.png`, `S04_win-dc01_aduc-utilisateurs.png`, `S04_ops01_windows-run1.txt`, `-run2.txt` | OK |
| Documenter droits et accès | `docs/comptes-et-droits.md` | `S04_linux01_test-partage.txt`, `S04_ops01_windows-partage-run2.txt` | OK |
| Vérifier les journaux Windows | `docs/maintenance.md` (§5, journaux Windows) | `S08_win-dc01_journal-systeme.png`, `S08_win-dc01_journal-directory-service.png` | OK |

## C. Administration Linux

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Comptes, groupes, permissions | `playbooks/stockage.yml`, `docs/stockage.md`, `docs/securite.md` | `S04_linux01_stockage-verif.txt`, `S04_linux01_diagnostic-droits.txt` | OK |
| Service applicatif simple | `playbooks/nginx.yml`, `scripts/linux/check-nginx.sh` | `S03_linux01_check-nginx-avant.txt`, `-apres.txt`, `S03_linux01_nginx-verif.txt` | OK |
| Services et processus | `docs/stockage.md`, `docs/incident.md` | `S03_linux01_ps.txt`, `S05_linux01_nginx-processus.txt`, `S03_linux01_ssh-status.txt` | OK |
| Disque virtuel de test, système de fichiers | `playbooks/stockage.yml`, `inventory/host_vars/LINUX01.yml` | `S04_linux01_disque-identification.txt`, `S04_ops01_stockage-run5.txt` | OK |
| Montage du stockage | `docs/stockage.md` | `S04_linux01_stockage-verif.txt` (fstab UUID, persistance) | OK |
| Mise à jour contrôlée | `playbooks/maintenance.yml`, `docs/maintenance.md` | `S05_ops01_maintenance.txt` | OK |
| Journaux système | `docs/incident.md` (test 7), `docs/securite.md` | `S03_linux01_ssh-journal.txt`, `S03_linux01_nginx-journal.txt`, `S07_linux01_diagnostic.txt` | OK |

## D. Automatisation Ansible

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Inventaire des hôtes | `inventory/hosts.yml`, `ansible.cfg` | `S03_ops01_list-hosts.txt` ; `ansible-inventory --graph` en CI | OK |
| Variables nécessaires | `inventory/group_vars/`, `inventory/host_vars/LINUX01.yml` | `S03_ops01_variables-linux01.txt` | OK |
| Playbook Linux | `playbooks/linux.yml`, `nginx.yml`, `stockage.yml` | `S03_ops01_playbook-run1.txt`, `S04_ops01_stockage-run5.txt` | OK |
| Playbook Windows | `playbooks/windows.yml` | `S04_ops01_windows-partage-run1.txt` | OK |
| Plusieurs opérations automatisées | `playbooks/supervision.yml`, `securite.yml`, `maintenance.yml`, `verification.yml` | `S05_ops01_*.txt`, `S08_ops01_pare-feu-run1.txt` | OK |
| Vérifications après exécution | `assert` et tests réels en fin de playbook | `S04_ops01_stockage-run3.txt` (échec détecté), `S05_ops01_verification.txt` | OK |
| Dépendances et commandes documentées | `docs/ansible.md`, `README.md`, `collections/requirements.yml` | — | OK |
| Connexions Linux et Windows | `group_vars/linux/vars.yml`, `group_vars/windows/vars.yml` | `S02_ops01_ansible-ping.txt`, `S04_ops01_win-ping.txt` | OK |
| Second passage stable | — | `S03_ops01_playbook-run2.txt`, `S04_ops01_windows-run2.txt`, `S04_ops01_stockage-run6.txt`, `S06_ops01_supervision-run6.txt`, `S08_ops01_pare-feu-run2.txt` (tous `changed=0`) | OK |

## E. Maintenance et mises à jour

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Procédure de maintenance | `docs/maintenance.md` | — | OK |
| Mises à jour Linux automatisées | `playbooks/maintenance.yml` | `S05_ops01_maintenance.txt` | OK |
| Procédure Windows documentée et testée | `docs/maintenance.md` §5 | `S05_win-dc01_historique-wu.png`, `S05_ops01_maintenance-apres-windows.txt` | OK |
| Espace disque et état des services | `playbooks/verification.yml`, `inventory/group_vars/all.yml` | `S05_ops01_verification.txt`, `S05_ops01_extension-lv.txt` | OK |
| Précautions avant redémarrage | `docs/maintenance.md` §2, §7 | `S08_hote_erreur-iso-manquante.png` (incident de démarrage rencontré) | OK |

## F. Supervision

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Installer et configurer Prometheus | `playbooks/supervision.yml`, `monitoring/prometheus.yml` | `S06_ops01_supervision-run4.txt` à `-run6.txt`, `S06_prometheus-cibles.png` ; `promtool check config` en CI | OK |
| Collecteurs Linux et Windows | `playbooks/supervision.yml`, `group_vars/windows/vars.yml` | `S06_grafana-tableau-de-bord-4-cibles-up.png` | OK |
| Source de données Grafana | `monitoring/grafana/datasource.yml` | `S06_grafana-accueil.png` ; contrôle de santé dans `supervision.yml` | OK |
| Tableau de bord CPU, mémoire, stockage, disponibilité | `monitoring/dashboards/infraready.json`, `docs/supervision.md` | `S07_grafana-etat-initial.png` | OK |
| Provenance des métriques expliquée | `docs/supervision.md` (mode pull, étiquette `hote`) | — | OK |
| Seuil ou alerte démontré | `monitoring/alertes.yml` | `S06_demo-seuil.txt`, `S06_ops01_alerte-firing.json`, `S06_ops01_chronologie-seuil.txt`, `S06_grafana-seuil-disque-depasse.png` | OK |

## G. GitHub et intégration continue

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Dépôt GitHub organisé | `README.md` (organisation), `thom972/infraready` branche `Keo` | — | OK |
| Commits compréhensibles | `CONTRIBUTING.md` | `git log --oneline` (commits conventionnels) | OK |
| Workflow GitHub Actions sur push et pull request | `.github/workflows/validation.yml`, `.yamllint`, `collections/requirements.yml` | `S08_github_actions-validation.txt` (déclenché par un push), `S08_github_actions-executions.png` | OK |
| Preuve d'une exécution réussie | — | `S08_github_actions-validation.txt` (exécution 42783406785), `S08_github_actions-validation-scripts.txt` (exécution 42786343692, 14 contrôles) | OK |

## H. Diagnostic d'incident

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Symptôme observé | `docs/incident.md` §1 | `S07_grafana-pending.png`, `S07_grafana-firing.png`, `S07_prometheus-firing.png` | OK |
| Tests et journaux consultés | `docs/incident.md` §2 | `S07_ops01_diagnostic.txt`, `S07_linux01_diagnostic.txt`, `S07_ops01_chronologie-incident.txt` | OK |
| Cause identifiée | `docs/incident.md` §3 | `S07_linux01_diagnostic.txt` (règle `tcp dport 9100 drop`) | OK |
| Correction appliquée | `docs/incident.md` §4 | `S07_linux01_diagnostic.txt` | OK |
| Retour à la normale vérifié | `docs/incident.md` §5 | `S07_ops01_retour-normale.txt`, `S07_grafana-retour-normale.png`, `S07_prometheus-retour-normale.png` | OK |

## Exigences transversales

| Exigence | Fichiers | Preuves | Statut |
|---|---|---|---|
| Aucun secret commité ; secrets fournis à l'exécution | `inventory/group_vars/*/vault.yml` (chiffrés), `docs/securite.md`, `.gitignore` | gitleaks sur tout l'historique : aucun secret (`S08_github_actions-validation.txt`) ; contrôle du chiffrement en CI | OK |
| Moindre privilège, ports justifiés | `playbooks/securite.yml`, `docs/securite.md` | `S08_hote_tests-pare-feu.txt`, `S08_ops01_pare-feu-run1.txt`, `S08_ops01_durcissement-run3.txt`, `S08_ops01_controle-sudo-manuel.txt` | OK |
| Écarts documentés | `docs/ecarts-et-decisions.md` | — | OK |
| Dossier technique PDF | `docs/dossier-technique.pdf` (sources : `docs/livrables/`) | — | OK |
