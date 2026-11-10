#import "theme.typ": *

// Présentation de soutenance : 10 diapositives, 15 minutes. Contenu tiré de docs/ uniquement.
#set document(title: "InfraReady — Soutenance", author: "Kéo")
#set text(font: sans, size: 14.5pt, fill: ink, lang: "fr", region: "FR")
#set par(leading: 0.6em, spacing: 0.85em, justify: false)
#show raw: set text(font: mono, features: ("calt": 0))
#show raw.where(block: false): it => box(fill: surface, radius: 4pt, inset: (x: 3pt), outset: (y: 2.5pt), text(size: 0.9em, it))
#show raw.where(block: true): set block(fill: surface, radius: 12pt, inset: 11pt, width: 100%)
#show raw.where(block: true): set text(size: 10pt)
#show figure.caption: set text(size: 9.5pt, fill: ink2)
#show: apple-tables
#set table(inset: (x: 6pt, y: 5pt))

#let total = 10
#set page(paper: "presentation-16-9", margin: (x: 1.8cm, top: 1.35cm, bottom: 1.3cm),
  footer: context {
    let n = counter(page).get().first()
    if n > 1 {
      set text(size: 9pt, fill: ink3)
      grid(columns: (1fr, auto), [InfraReady · Soutenance · Bachelor 3 Cybersécurité], [#n / #total])
    }
  })

#let slide(eyebrow: none, time: none, title: none, body) = {
  pagebreak(weak: true)
  grid(columns: (1fr, auto),
    text(size: 10.5pt, weight: 700, fill: blue, tracking: 0.09em, upper(eyebrow)),
    if time != none { info(time) })
  v(-0.45em)
  text(size: 27pt, weight: 700, tracking: -0.03em, title)
  v(0.25em)
  body
}
#let small(t) = text(size: 11pt, fill: ink2, t)

// =====================================================================
// 1. Titre et besoin
#page(footer: none, margin: (x: 2.1cm, y: 1.6cm))[
  #text(size: 10.5pt, weight: 700, fill: ink2, tracking: 0.09em, "BACHELOR 3 · CYBERSÉCURITÉ · PROJET FIL ROUGE 2026")
  #v(1fr)
  #text(size: 76pt, weight: 800, tracking: -0.05em, "InfraReady.")
  #v(-1.5em)
  #text(size: 24pt, weight: 600, tracking: -0.02em, fill: ink2, "Déployer. Automatiser. Superviser. Diagnostiquer.")
  #v(0.5em)
  #text(size: 14pt)[Un SI Linux/Windows configuré à la main, sans trace, aux pannes détectées trop tard : nous l'avons rendu *reproductible*, *sécurisé*, *supervisé* et *documenté*.]
  #v(1fr)
  #grid(columns: (1fr,) * 5, gutter: 12pt,
    stat("3", "VM · 1 domaine"), stat("8", "playbooks Ansible"), stat("4", "cibles supervisées"),
    stat("131", "preuves versionnées"), stat("0", "secret dans Git"))
  #v(0.8em)
  #text(size: 11pt, fill: ink3)[Dépôt `thom972/infraready`, branche `Keo` · dossier technique : `docs/dossier-technique.pdf`]
]

// =====================================================================
// 2. Architecture, adressage, DNS
#slide(eyebrow: "Critère 1 · Infrastructure, réseau, DNS", time: "2 min", title: "Trois VM, un réseau privé, un domaine")[
  #grid(columns: (1.55fr, 1fr), gutter: 14pt,
    schema(w: 15.2cm, ts: 0.95),
    [
      #set text(size: 11.5pt)
      #table(columns: (auto, 1fr),
        [Adresse], [Rôle],
        [`.1`], [hôte : NAT, DNS temporaire],
        [`.10`], [WIN-DC01 : AD DS, DNS],
        [`.20`], [LINUX01 : Nginx, données],
        [`.30`], [OPS01 : Ansible, supervision],
        [`.100–.199`], [DHCP d'installation],
      )
      #small[Pas de conflit : pont `virbr50` dédié, DHCP hors des adresses fixes.]
      #v(0.2em)
      #note([DNS : un échec, puis la preuve], text(size: 10.5pt)[Avant AD DS, `getent hosts WIN-DC01.infraready.test` → *code 2* : le DNS de libvirt ne connaît pas la zone. Après bascule vers .10 : résolu (`S04_dns-clients-linux.txt`).])
    ],
  )
]

// =====================================================================
// 3. Windows
#slide(eyebrow: "Critère 2 · Administration Windows", time: "1 min 30", title: "Active Directory : des droits par groupe")[
  #grid(columns: (1fr, 1fr), gutter: 16pt,
    [
      #shot("S04_win-dc01_aduc-utilisateurs.png", caption: [OU `InfraReady` : 4 comptes, 2 groupes, créés par `playbooks/windows.yml`.])
      #small[`dcdiag` : Connectivity, Advertising, SysVolCheck, NetLogons, Services, FsmoCheck réussis.]
    ],
    [
      #text(size: 12.5pt, weight: 700, [Partage `\\WIN-DC01\Lab` — partage *et* NTFS])
      #v(-0.3em)
      #table(columns: (1fr, auto, auto),
        [Compte], [Attendu], [Obtenu],
        [b.durand (Utilisateurs)], [écrit], ok(l: "fichier créé"),
        [a.martin (Admins)], [lit, supprime], ok(l: "OK"),
        [d.invite (aucun groupe)], [refusé], ok(l: "ACCESS_DENIED"),
      )
      #small[Héritage NTFS coupé. Services surveillés : NTDS, DNS, Netlogon, Kdc, WinRM, LanmanServer. WinRM accepté depuis OPS01 seulement.]
      #v(0.1em)
      #note([Journaux relus], text(size: 10.5pt)[Observateur d'événements : *Système* (7 145 événements, aucune erreur affichée) et *Directory Service* (catalogue global trouvé). `Get-WinEvent` pour les filtrer par niveau.], kind: "ok")
    ],
  )
]

// =====================================================================
// 4. Linux et stockage
#slide(eyebrow: "Critères 2 et 4 · Linux et stockage", time: "1 min 30", title: "Service, droits et disque dédié")[
  #grid(columns: (1fr, 1fr), gutter: 16pt,
    [
      #term(title: "check-nginx.sh — avant / après nginx.yml", size: 9.8pt)[
        ```
ERREUR : le service nginx n'est pas actif (code 1)
OK : le service nginx est actif           (code 0)
        ```
      ]
      #v(0.15em)
      #small[Maître Nginx en `root`, workers en `www-data` (`S05_linux01_nginx-processus.txt`). Journaux : `journalctl -u nginx`, `-u ssh`.]
      #v(0.15em)
      #term(title: "S04_linux01_stockage-verif.txt", size: 9.8pt)[
        ```
drwxrwsr-x root infraready /srv/infraready
UUID=bd3813fb-… /srv/infraready ext4 defaults,nofail
MONTAGE PERSISTANT OK
        ```
      ]
    ],
    [
      #note([Testé, pas supposé], text(size: 11pt)[`test -w` donnait un faux négatif : le playbook prouve le droit par une *écriture réelle*. `keo` (groupe `infraready`) écrit, `ansible` est refusé.], kind: "ok")
      #v(0.2em)
      #text(weight: 700, "Un disque qu'on ne formate pas par erreur") \
      #small[Désigné par son numéro de série `INFRA-DATA`, jamais `/dev/vdX`. `assert` : arrêt si le disque est absent ou porte la racine. `force: false` : jamais de reformatage. Snapshot avant, `fstab` sauvegardé. *UUID* stable, *nofail* : la VM démarre même sans le disque.]
    ],
  )
]

// =====================================================================
// 5. Ansible
#slide(eyebrow: "Critère 3 · Ansible et reproductibilité", time: "2 min", title: "Rejouer ne change rien : changed=0")[
  #grid(columns: (1fr, 1.15fr), gutter: 16pt,
    [
      #set text(size: 11.5pt)
      #table(columns: (auto, 1fr, auto),
        [Cible], [Connexion], [Compte],
        vm("LINUX01"), [SSH, clé, sudo (coffre)], [`ansible`],
        vm("OPS01"), [locale, sudo `-K`], [`keo`],
        vm("WIN-DC01"), [WinRM 5985, NTLM], [`svc-ansible`],
      )
      #small[Variables par portée : `all`, `linux/`, `ops/`, `windows/`, `host_vars/LINUX01`. Trois coffres chiffrés : *`--ask-vault-pass` partout*.]
      #v(0.2em)
      ```
--syntax-check → --list-hosts
→ --check --diff → exécution
→ rejeu : changed=0 failed=0
      ```
    ],
    [
      #set text(size: 11.5pt)
      #table(columns: (auto, auto, auto),
        [Playbook], [1#super[er] passage], [2#super[e] passage],
        [`nginx.yml`], [`changed=1`], [`changed=0`],
        [`windows.yml`], [`changed=4`], [`changed=0`],
        [`windows.yml` (partage)], [`changed=5`], [`changed=0`],
        [`stockage.yml`], [échecs corrigés], [`changed=0`],
        [`securite.yml`], [`changed=3` ×2], [`changed=0`],
      )
      #small[Chaque playbook finit par des `assert` et des tests réels : un état faux *fait échouer* l'exécution (runs 1 à 4 de `stockage.yml`). Aussi : `supervision`, `verification`, `maintenance`.]
    ],
  )
]

// =====================================================================
// 6. Maintenance
#slide(eyebrow: "Critère 4 · Maintenance", time: "1 min", title: "Mettre à jour sans interruption non maîtrisée")[
  #grid(columns: (1fr, 1fr), gutter: 14pt,
    card(inset: 14pt)[
      #vm("LINUX01") #h(6pt) #vm("OPS01") #h(1fr) #ok(l: "Automatisé")
      #v(0.15em)
      #text(size: 12.5pt)[`maintenance.yml` : vérification → `apt upgrade: safe` *une machine à la fois* → redémarrage seulement si requis *et* autorisé → vérification.]
    ],
    card(inset: 14pt)[
      #vm("WIN-DC01") #h(1fr) #info("Recherche auto · install. manuelle")
      #v(0.15em)
      #text(size: 12.5pt)[Snapshot, Windows Update, puis `Get-HotFix` et `dcdiag`. 22/10 : KB5126646, KB5126645, KB5127690, KB890830.]
    ],
  )
  #v(0.5em)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 14pt,
    [#text(weight: 700, "Avant") \ #small[État initial (`verification.yml`), snapshot `virsh snapshot-create-as`, ≥ 15 % d'espace libre.]],
    [#text(weight: 700, "Pendant") \ #small[`serial: 1`, aucun redémarrage implicite, *WIN-DC01 en dernier* : il porte l'annuaire et le DNS.]],
    [#text(weight: 700, "Capacité") \ #small[OPS01 à 60 % sur `/` : volume étendu à chaud de 10 à 18,22 Gio (33 %).]],
  )
]

// =====================================================================
// 7. Supervision
#slide(eyebrow: "Critère 5 · Supervision", time: "2 min 30", title: "Quatre cibles, un seuil démontré")[
  #grid(columns: (1.35fr, 1fr), gutter: 14pt,
    [
      #shot("S07_grafana-etat-initial.png", caption: [Grafana provisionné par code : disponibilité, CPU, mémoire, disque, alertes.])
    ],
    [
      #set text(size: 11.5pt)
      Prometheus *tire* `/metrics` toutes les 15 s : node_exporter (9100) sur LINUX01 et OPS01, windows_exporter (9182) sur WIN-DC01. `up = 0` : collecte en échec.
      #v(0.2em)
      #table(columns: (1fr, auto, auto),
        [Alerte], [Condition], [for],
        [`HoteInjoignable`], [`up == 0`], [1m],
        [`EspaceDisqueFaible…`], [< 15 % libre], [5m],
        [`ProcesseurSature`], [> 90 %], [10m],
      )
      #v(0.2em)
      #text(weight: 700, "Seuil disque démontré") \
      #small[`/srv/infraready` 1 % → *92 %* → 1 % : pending 09:07:13, firing 09:12:13 (+5 min), résolue 09:16:43 (`S06_ops01_chronologie-seuil.txt`).]
    ],
  )
]

// =====================================================================
// 8. Incident
#slide(eyebrow: "Critère 8 · Diagnostic d'incident", time: "2 min", title: "Plus aucune métrique de LINUX01")[
  #grid(columns: (1fr, 1.1fr), gutter: 14pt,
    [
      #shot("S07_grafana-firing.png", caption: [LINUX01 DOWN, HoteInjoignable en firing. SSH et Nginx restent disponibles.])
      #v(0.15em)
      #note([Un délai, pas un refus], text(size: 10.5pt)[Un service arrêté *refuse* la connexion ; une règle `drop` *ignore* les paquets. Le test local échoue aussi : le filtrage est sur la machine.])
    ],
    [
      #set text(size: 11pt)
      #table(columns: (auto, 1fr, auto),
        [\#], [Test], [Résultat],
        [1], [`ping` depuis OPS01], ok(l: "2/2"),
        [2], [`curl :9100/metrics` depuis OPS01], ko(l: "délai"),
        [4], [`systemctl is-active` node_exporter], ok(l: "active"),
        [5], [`ss -lnt | grep 9100`], ok(l: "LISTEN"),
        [6], [`curl localhost:9100`], ko(l: "délai"),
        [7], [`journalctl -u` node_exporter], ok(l: "sain"),
        [8], [`nft list ruleset`], ko(l: "drop 9100"),
      )
      #v(0.1em)
      ```
sudo nft delete table inet incident
      ```
      #small[Retour à la normale : 4 UP, alerte résolue à 09:38:48. Leçon : toute règle de pare-feu est désormais versionnée (`securite.yml`).]
    ],
  )
]

// =====================================================================
// 9. CI et sécurité
#slide(eyebrow: "Critères 6 et 7 · GitHub, CI et sécurité", time: "1 min 30", title: "Valider le dépôt, refuser par défaut")[
  #grid(columns: (1fr, 1fr), gutter: 16pt,
    [
      #set text(size: 11pt)
      #table(columns: (auto, auto),
        [`validation.yml` (push, PR)], [10/11],
        [gitleaks, tout l'historique], ok(l: "0 fuite"),
        [3 coffres chiffrés], ok(l: "3/3"),
        [`yamllint --strict`], ok(l: "OK"),
        [`ansible-lint`], ok(l: "production"),
        [`--syntax-check` ×8, inventaire], ok(l: "8/8"),
        [shellcheck, PSScriptAnalyzer], ok(l: "0 erreur"),
        [`promtool` config + règles], ok(l: "4 règles"),
      )
      #small[Le runner GitHub est sur Internet, sans route vers 192.168.50.0/24 ni secret : il *valide*, il ne *déploie* pas. 45 commits conventionnels.]
    ],
    [
      #set text(size: 11pt)
      #table(columns: (auto, auto, auto),
        [Hôte], [Port], [Source],
        [LINUX01], [22 · 80 · 9100], [.1/.30 · labo · .30],
        [OPS01], [22 · 3000 · 9090], [.1],
        [WIN-DC01], [5985 · 9182], [.30],
        [WIN-DC01], [53 · 445], [labo],
      )
      #small[ufw versionné, flux ouverts *avant* activation, tests autorisé/refusé. `ansible` : sudo *avec* mot de passe, SSH par clé (E-14 résolu). `svc-ansible` : risque accepté, non délégable (E-15). Snapshot et `--check --diff` avant tout changement.]
      #v(0.1em)
      // Recadrage de S08_github_actions-executions.png sur la liste des exécutions
      #figure(block(radius: 8pt, clip: true, stroke: 0.5pt + hair, image("actions-executions-recadre.png", width: 100%)),
        caption: [Onglet Actions : exécutions vertes sur `Keo` et `thomas`.], supplement: [Capture], kind: "capture")
    ],
  )
]

// =====================================================================
// 10. Limites et questions
#slide(eyebrow: "Choix · questions", time: "1 min", title: "Des choix assumés, tous justifiés")[
  #grid(columns: (1.15fr, 1fr), gutter: 16pt,
    [
      #set text(size: 12pt)
      #table(columns: (1fr, auto),
        [Choix], [Statut],
        [`svc-ansible` Admin du domaine (E-15) : non délégable, WinRM depuis OPS01 seul], part(l: "Risque accepté"),
        [Mises à jour Windows installées à la main], info("Choix"),
        [Alertes sans notification (pas d'Alertmanager)], info("Assumé"),
      )
      #small[Écarts justifiés : QEMU/KVM au lieu de VMware (E-01), Ubuntu 26.04 donc `sudo.ws` (E-12, E-17), WIN-DC01 en SATA/e1000e (E-06). En production : délégation sur `OU=InfraReady`, Alertmanager.]
    ],
    [
      #v(0.6em)
      #text(size: 46pt, weight: 800, tracking: -0.04em, "Questions ?")
      #v(-0.4em)
      #small[Démo possible : `ansible-playbook playbooks/verification.yml -K --ask-vault-pass` · Grafana `192.168.50.30:3000` · traçabilité A→H : `docs/tracabilite.md`.]
    ],
  )
]
