# Preuves de fonctionnement

Une preuve est un élément **observable** qui soutient une affirmation : sortie de commande,
capture lisible, résultat de workflow, état de service (support 2, annexe B).

## Convention de nommage

`S<séance>_<machine>_<objet>.<txt|png>` — exemples : `S02_linux01_reception.txt`, `S07_grafana-firing.png`.

## Produire une preuve

```bash
# Linux : sortie complète horodatée
./scripts/linux/verif-reception.sh 192.168.50.1 192.168.50.10 | tee S02_linux01_reception.txt
```

```powershell
# Windows
.\scripts\windows\Verif-Reception.ps1 | Tee-Object -FilePath S02_win-dc01_reception.txt
```

Les sorties Windows `S02_win-dc01_reception.txt` et `S04_win-dc01_dcdiag.txt` sont encodées en Windows-1252 :
`iconv -f CP1252 -t UTF-8 <fichier>` pour les lire.

## Avant de committer une preuve

- Aucun mot de passe, jeton, clé privée ni information personnelle.
- La preuve correspond à un test réellement exécuté ; un test non réalisé n'a pas de fichier.

## Index des preuves (90 sorties, 40 captures)

Colonne *Partie* : exigence du sujet (A à H, voir [`../tracabilite.md`](../tracabilite.md)) ou thème transversal.


### Séance 1 — conception

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S01_schema-architecture-cible-v1.png` | A | Première version du schéma d'architecture cible |

### Séance 2 — installation et réception

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S02_hote_reseau-infraready.txt` | A | Réseau libvirt `infraready` actif, persistant, autostart ; XML (NAT, DHCP .100–.199) |
| `S02_hote_virt-viewer-telechargement.png` | — | Outil de console SPICE sur l'hôte |
| `S02_installeur-ubuntu-profil.png` | A | Installeur Ubuntu : profil (mot de passe masqué) |
| `S02_linux01_compte-ansible-test-ssh.png` | D | Compte `ansible` sur LINUX01 et premier SSH depuis OPS01 |
| `S02_linux01_reception.txt` | A | Réception de LINUX01 : système, IP, route, DNS, ping |
| `S02_linux01_winrm-refuse.txt` | Sécurité | WinRM 5985 refusé depuis LINUX01 (délai dépassé) |
| `S02_ops01_ansible-ping-linux01.png` | D | `ansible linux -m ping` → pong |
| `S02_ops01_ansible-ping.txt` | D | Sortie de `ansible linux -m ping` |
| `S02_ops01_copie-config-ansible.png` | D | Copie de la configuration Ansible vers OPS01 |
| `S02_ops01_desactivation-cloud-init-reseau.png` | A | Désactivation du réseau cloud-init sur OPS01 |
| `S02_ops01_empreinte-ssh-compte-keo.png` | Sécurité | Empreinte SSH d'OPS01 vérifiée, compte nominatif |
| `S02_ops01_installeur-reseau-dhcp.png` | A | Installeur d'OPS01 en DHCP (adresse de la plage .100–.199) |
| `S02_ops01_netplan-00-installer-config.png` | A | Fichier netplan créé par l'installeur |
| `S02_ops01_netplan-01-lab-edition.png` | A | Édition de `/etc/netplan/01-lab.yaml` |
| `S02_ops01_netplan-erreur-indentation.png` | A | Erreur d'indentation détectée par `netplan generate` |
| `S02_ops01_netplan-try-ip-fixe.png` | A | `netplan try` : IP fixe 192.168.50.30 appliquée |
| `S02_ops01_reception.txt` | A | Réception d'OPS01 : système, IP, route, DNS, ping |
| `S02_ops01_versions.txt` | D | Versions de Git et d'Ansible sur OPS01 |
| `S02_ops01_winrm-port.txt` | D | WinRM joignable depuis OPS01 (port ouvert, HTTP 405) |
| `S02_ref_spice-guest-tools.png` | — | Référence : spice-guest-tools (source officielle) |
| `S02_ref_spice-telechargements.png` | — | Référence : page de téléchargement SPICE |
| `S02_win-dc01_reception.txt` | A | Réception de WIN-DC01 : version, IP, profil réseau, ping (encodage Windows-1252) |
| `S02_win-dc01_winrm.txt` | D | Service WinRM actif et règle de pare-feu limitée |
| `S02_winrm-ops01-ok-linux01-refuse.png` | Sécurité | WinRM accepté depuis OPS01, refusé depuis LINUX01 |

### Séance 3 — Linux et premier playbook

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S03_ansible_arborescence.txt` | D | Première arborescence du projet Ansible |
| `S03_linux01_check-nginx-apres.txt` | C | `check-nginx.sh` après installation : actif, code 0 |
| `S03_linux01_check-nginx-avant.txt` | C | `check-nginx.sh` avant installation : inactif, code 1 |
| `S03_linux01_df-logs.txt` | C | État avant stockage : `/srv/infraready/logs` absent |
| `S03_linux01_df.txt` | C, E | Occupation des systèmes de fichiers de LINUX01 |
| `S03_linux01_findmnt-T-srv.txt` | C | État avant stockage : `/srv` sur la racine |
| `S03_linux01_findmnt-logs.txt` | C | État avant stockage : aucun montage dédié |
| `S03_linux01_findmnt.txt` | C | Arborescence des montages de LINUX01 |
| `S03_linux01_fstab.txt` | C | `/etc/fstab` initial |
| `S03_linux01_ls-logs.txt` | C | État avant stockage : répertoire absent |
| `S03_linux01_lsblk.txt` | C | Disques et partitions de LINUX01 |
| `S03_linux01_lvm.txt` | C | Volumes LVM de LINUX01 |
| `S03_linux01_memoire.txt` | C | Mémoire de LINUX01 (`free -h`) |
| `S03_linux01_nginx-journal.txt` | C | Journal de Nginx vu par un compte hors `adm` : accès restreint |
| `S03_linux01_nginx-status.txt` | C | Nginx absent avant le playbook |
| `S03_linux01_nginx-verif.txt` | C | Nginx actif, activé, HTTP 200 |
| `S03_linux01_ps.txt` | C | Processus de LINUX01 (`ps`) |
| `S03_linux01_quota.txt` | C | Quotas non installés (option facultative du sujet) |
| `S03_linux01_srv.txt` | C | État avant stockage : `/srv/infraready` absent |
| `S03_linux01_ssh-journal.txt` | C | Journal SSH : connexions par clé |
| `S03_linux01_ssh-status.txt` | C | État du service SSH |
| `S03_ops01_list-hosts.txt` | D | `--list-hosts` : cibles du playbook |
| `S03_ops01_playbook-run1.txt` | D | Playbook Nginx, 1er passage : `changed=1` |
| `S03_ops01_playbook-run2.txt` | D | Playbook Nginx, 2e passage : `changed=0` (idempotence) |
| `S03_ops01_playbook-vars.txt` | D | Playbook Nginx paramétré par variables de groupe |
| `S03_ops01_syntax-check.txt` | D | `--syntax-check` du playbook |
| `S03_ops01_variables-linux01.txt` | D | Variables résolues pour LINUX01 (`ansible-inventory --host`) |

### Séance 4 — Active Directory, stockage, playbooks

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S04_dns-clients-linux.txt` | A, B | Résolution du domaine depuis LINUX01 et OPS01 via 192.168.50.10 |
| `S04_linux01_diagnostic-droits.txt` | C | Diagnostic du faux négatif de `test -w` (écriture réelle OK) |
| `S04_linux01_disque-identification.txt` | C, Sécurité | Identification de la cible : `vdb` 5 Go, série INFRA-DATA, vierge |
| `S04_linux01_disques-hyperviseur.txt` | C | Disques de LINUX01 vus par l'hyperviseur (`virsh domblklist`) |
| `S04_linux01_stockage-verif.txt` | C | ext4 monté sur `/srv/infraready`, fstab par UUID, droits 2775, persistance |
| `S04_linux01_test-partage.txt` | B | Partage Lab : écriture b.durand, lecture a.martin, refus d.invite |
| `S04_ops01_stockage-run1.txt` | D | Playbook stockage, échec `become_user` (corrigé par `pipelining`) |
| `S04_ops01_stockage-run2.txt` | D | Même échec, avant correction |
| `S04_ops01_stockage-run3.txt` | D | Échec du test `test -w` (faux négatif) |
| `S04_ops01_stockage-run4.txt` | D | Même échec, avant correction |
| `S04_ops01_stockage-run5.txt` | D | Playbook stockage corrigé : `changed=0`, `failed=0` |
| `S04_ops01_stockage-run6.txt` | D | Second passage : `changed=0` (idempotence) |
| `S04_ops01_win-ping.txt` | D | `win_ping` WinRM → pong |
| `S04_ops01_windows-partage-run1.txt` | B, D | Playbook Windows + partage, 1er passage : `changed=5` |
| `S04_ops01_windows-partage-run2.txt` | B, D | 2e passage : `changed=0` |
| `S04_ops01_windows-run1.txt` | B, D | Playbook annuaire, 1er passage : `changed=4` |
| `S04_ops01_windows-run2.txt` | B, D | 2e passage : `changed=0` |
| `S04_win-dc01_aduc-groupes.png` | B | Console « Utilisateurs et ordinateurs AD » : OU `InfraReady/Groupes`, groupes GG-Admins-Infra et GG-Utilisateurs-Lab |
| `S04_win-dc01_aduc-utilisateurs.png` | B | OU `InfraReady/Utilisateurs` : comptes a.martin, b.durand, c.petit, d.invite |
| `S04_win-dc01_ad-structure.txt` | B | OU, comptes et membres des groupes |
| `S04_win-dc01_dcdiag.txt` | B | `dcdiag` : tests du contrôleur réussis (encodage Windows-1252) |
| `S04_win-dc01_dns-srv.txt` | B | Enregistrements SRV du domaine (LDAP, Kerberos) |
| `S04_win-dc01_test-et-promotion-adds.png` | B | Test puis promotion AD DS |
| `S04_win-dc01_zone-dns.txt` | A, B | Zone directe et inverse `infraready.test` |

### Séance 5 — maintenance

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S05_linux01_nginx-processus.txt` | C | Service et processus Nginx (maître, workers) |
| `S05_ops01_extension-lv.txt` | E | Extension à chaud du volume racine d'OPS01 (10 → 18,22 Gio) |
| `S05_ops01_maintenance-apres-windows.txt` | E | Maintenance après mises à jour Windows : 0 restante, `failed=0` |
| `S05_ops01_maintenance.txt` | E | Playbook maintenance sur les 3 hôtes, `failed=0` |
| `S05_ops01_reorg-linux.txt` | D | Après réorganisation du dépôt : `linux.yml`, `changed=0` |
| `S05_ops01_reorg-verification.txt` | D, E | Après réorganisation : `verification.yml` sur les 3 hôtes, `failed=0` |
| `S05_ops01_reorg-windows.txt` | D | Après réorganisation : `windows.yml`, `changed=0` |
| `S05_ops01_verification.txt` | E | Playbook vérification : services, disques, HTTP, `failed=0` |
| `S05_win-dc01_historique-wu.png` | E | Historique Windows Update de WIN-DC01 |

### Séance 6 — supervision et seuil

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S06_demo-seuil.txt` | F | Démonstration du seuil : `/srv/infraready` 1 % → 92 % → 1 % |
| `S06_grafana-accueil.png` | F | Connexion à Grafana |
| `S06_grafana-seuil-disque-depasse.png` | F | Seuil dépassé : 7,68 % libres, barre rouge |
| `S06_grafana-tableau-de-bord-4-cibles-up.png` | F | Tableau de bord : 4 cibles UP |
| `S06_ops01_alerte-firing.json` | F | API Prometheus : `EspaceDisqueFaibleLinux` en `firing`, 7,68 % libres |
| `S06_ops01_chronologie-seuil.txt` | F | Chronologie du seuil disque : pending 09:07:13, firing 09:12:13, résolue 09:16:43 UTC |
| `S06_ops01_supervision-run1.txt` | F, D | Playbook supervision, 1er passage : échec du mot de passe Grafana (corrigé) |
| `S06_ops01_supervision-run2.txt` | F, D | Même échec, avant correction |
| `S06_ops01_supervision-run3.txt` | F, D | Même échec, avant correction |
| `S06_ops01_supervision-run4.txt` | F, D | Playbook supervision corrigé : `failed=0`, 4 cibles UP |
| `S06_ops01_supervision-run5.txt` | F, D | Rejeu après modification des alertes : `changed=1` |
| `S06_ops01_supervision-run6.txt` | F, D | Second passage : `changed=0` (idempotence) |
| `S06_prometheus-cibles.png` | F | Cibles Prometheus du job linux UP |
| `S06_prometheus-classic-graph.png` | F | Interface classique de Prometheus |
| `S06_prometheus-graph-vide.png` | F | Page Graph de Prometheus |
| `S06_prometheus-paquet-sans-interface-moderne.png` | F | Limite du paquet Ubuntu : interface classique seulement |

### Séance 7 — incident

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S07_etat-initial.txt` | H | Heure de l'état initial de l'incident |
| `S07_grafana-alertes-pending.png` | H | Panneau des alertes : HoteInjoignable pending |
| `S07_grafana-etat-initial.png` | H, F | État initial : 4 UP, aucune alerte (CPU, mémoire, disque visibles) |
| `S07_grafana-firing.png` | H | LINUX01 DOWN, alerte firing |
| `S07_grafana-pending.png` | H | LINUX01 DOWN, alerte pending |
| `S07_grafana-retour-normale.png` | H | Retour à la normale : 4 UP |
| `S07_linux01_diagnostic.txt` | H | Diagnostic sur LINUX01 : service actif, écoute, journaux, règle `drop 9100` |
| `S07_ops01_chronologie-incident.txt` | H | Chronologie de l'incident : DOWN 09:34:03, firing 09:35:18, résolue 09:38:48 UTC |
| `S07_ops01_diagnostic.txt` | H | Tests depuis OPS01 : ping OK, `curl :9100` délai dépassé, erreur Prometheus |
| `S07_ops01_retour-normale.txt` | H | Retour à la normale : métriques de LINUX01 de nouveau reçues |
| `S07_prometheus-firing.png` | H | Prometheus : alerte FIRING |
| `S07_prometheus-pending.png` | H | Prometheus : alerte PENDING depuis 09:34:09 UTC |
| `S07_prometheus-retour-normale.png` | H | Prometheus : 4 règles inactives |

### Séance 8 — sécurité

| Fichier | Partie | Ce qu'il démontre |
|---|---|---|
| `S08_github_actions-validation.txt` | G | Exécution réussie du workflow GitHub Actions (11 étapes, gitleaks, lint, promtool) |
| `S08_github_actions-executions.png` | G | Onglet *Actions* : exécutions réussies du workflow sur les branches `Keo` et `thomas` |
| `S08_hote_erreur-iso-manquante.png` | Maintenance | WIN-DC01 ne démarre plus : ISO d'installation introuvable |
| `S08_hote_tests-pare-feu.txt` | Sécurité | Depuis l'hôte : SSH et Grafana autorisés, node_exporter refusé |
| `S08_hote_win-dc01-lecteur-cdrom.png` | Maintenance | Lecteur CD de WIN-DC01 encore relié à l'ISO (cause du point précédent) |
| `S08_hote_win-dc01-materiel.txt` | A | Matériel virtuel réel de WIN-DC01 : q35, 2 vCPU, 4 Gio, disque SATA, carte e1000e (E-06) |
| `S08_win-dc01_journal-systeme.png` | B | Observateur d'événements, journal *Système* (7 145 événements) : démarrages de services (7036), avertissement `disk` 153 |
| `S08_win-dc01_journal-directory-service.png` | B | Journal *Directory Service* (282 événements) : catalogue global trouvé (1869), avertissements de sécurité AD |
| `S08_ops01_controle-sudo-manuel.txt` | Sécurité | `sudo -n` refusé au compte `ansible` (authentification exigée) |
| `S08_ops01_durcissement-run1.txt` | Sécurité, D | 1er passage : contrôle `sudo -n` en échec (élévation non désactivée, corrigé) |
| `S08_ops01_durcissement-run2.txt` | Sécurité, D | Même échec, avant correction |
| `S08_ops01_durcissement-run3.txt` | Sécurité, D | Playbook sécurité complet : `failed=0` sur les 3 hôtes |
| `S08_ops01_durcissement-simulation.txt` | Sécurité, D | Simulation `--check --diff` de `securite.yml` (sudo, SSH, WIN-DC01) |
| `S08_ops01_pare-feu-run1.txt` | Sécurité, D | Playbook sécurité, 1er passage : `changed=3` par hôte |
| `S08_ops01_pare-feu-run2.txt` | Sécurité, D | 2e passage : `changed=0` |
| `S08_ops01_pare-feu-simulation.txt` | Sécurité, D | Simulation `--check --diff` avant application |

## Remarques

- Les sorties produites sur OPS01 (chronologies d'alerte, exécutions de `supervision.yml` et `securite.yml`) ont été
  récupérées et versionnées le 10/11/2026.
- Plusieurs fichiers prévus en séance 2 (`S02_*_ip.png`, `S02_reception_tableau.png`…) n'ont pas été produits :
  les sorties `S02_*_reception.txt` les remplacent.
- Les captures des états `firing` et résolu de la démonstration du seuil disque n'ont pas été prises ;
  `S06_ops01_alerte-firing.json` et `S06_ops01_chronologie-seuil.txt` en tiennent lieu.
