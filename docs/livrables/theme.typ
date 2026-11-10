// Thème commun InfraReady — inspiré des principes de design Apple :
// police système (Adwaita Sans, dérivée d'Inter, proche de SF Pro), hiérarchie par graisse,
// interlettrage négatif sur les grands titres, surfaces grises arrondies sans bordure.

// ---------- Palette ----------
#let ink      = rgb("#1D1D1F")   // texte principal
#let ink2     = rgb("#6E6E73")   // texte secondaire
#let ink3     = rgb("#86868B")   // légendes
#let hair     = rgb("#D2D2D7")   // séparateurs
#let surface  = rgb("#F5F5F7")   // cartes
#let blue     = rgb("#0071E3")   // accent
#let green    = rgb("#248A3D")
#let green-bg = rgb("#E4F4E8")
#let orange   = rgb("#B25000")
#let orange-bg= rgb("#FFF1DE")
#let red      = rgb("#D70015")
#let red-bg   = rgb("#FDE8EA")
#let gray-bg  = rgb("#ECECEF")

// Couleur d'identification de chaque machine (pastille)
#let c-dc  = rgb("#5856D6")   // WIN-DC01
#let c-lx  = rgb("#FF9500")   // LINUX01
#let c-ops = rgb("#30B0C7")   // OPS01
#let c-host= rgb("#8E8E93")   // poste hôte

#let sans = ("Adwaita Sans", "Noto Sans")
#let mono = ("JetBrains Mono", "DejaVu Sans Mono")

// Dossier des preuves du dépôt (chemins relatifs à ce fichier)
#let P(f) = "../preuves/" + f

// ---------- Composants ----------

// Pastille d'état : kind = "ok" | "part" | "ko" | "info"
#let pill(label, kind: "ok") = {
  let (fg, bg) = if kind == "ok" { (green, green-bg) }
    else if kind == "part" { (orange, orange-bg) }
    else if kind == "ko" { (red, red-bg) }
    else { (ink2, gray-bg) }
  box(fill: bg, radius: 99pt, inset: (x: 0.55em, y: 0.28em), baseline: 0.22em,
    text(fill: fg, size: 0.78em, weight: 600, tracking: 0.01em, label))
}
#let ok(l: "Validé") = pill(l, kind: "ok")
#let part(l: "Partiel") = pill(l, kind: "part")
#let ko(l: "À faire") = pill(l, kind: "ko")
#let info(l) = pill(l, kind: "info")

// Pastille de machine
#let dot(c) = box(circle(radius: 0.28em, fill: c), baseline: -0.05em)
#let vm(name) = {
  let c = if name == "WIN-DC01" { c-dc } else if name == "LINUX01" { c-lx }
    else if name == "OPS01" { c-ops } else { c-host }
  [#dot(c)#h(0.3em)#text(weight: 600, name)]
}

// Carte : surface grise arrondie, sans bordure
#let card(body, fill: surface, inset: 12pt, radius: 12pt, width: 100%) = block(
  fill: fill, radius: radius, inset: inset, width: width, breakable: false, body)

// Encadré « à retenir » / limite
#let note(title, body, kind: "info") = {
  let (fg, bg) = if kind == "ok" { (green, green-bg) }
    else if kind == "part" { (orange, orange-bg) }
    else if kind == "ko" { (red, red-bg) }
    else { (blue, rgb("#E8F1FD")) }
  block(fill: bg, radius: 12pt, inset: (x: 12pt, y: 10pt), width: 100%, breakable: false)[
    #text(fill: fg, weight: 700, size: 0.92em, title)
    #v(-0.45em)
    #body
  ]
}

// Fenêtre de terminal (fond sombre, trois pastilles) pour les commandes
#let term(title: "", size: 7.6pt, body) = block(
  fill: rgb("#1C1C1E"), radius: 10pt, width: 100%, clip: true, breakable: false,
)[
  #block(fill: rgb("#2C2C2E"), width: 100%, inset: (x: 9pt, y: 5pt))[
    #box(circle(radius: 3pt, fill: rgb("#FF5F57")))#h(3.5pt)#box(circle(radius: 3pt, fill: rgb("#FEBC2E")))#h(3.5pt)#box(circle(radius: 3pt, fill: rgb("#28C840")))
    #h(8pt)#text(fill: rgb("#98989D"), size: 6.8pt, font: sans, weight: 500, title)
  ]
  #block(inset: (x: 10pt, y: 8pt), width: 100%)[
    #set text(font: mono, size: size, fill: rgb("#F2F2F7"))
    #set par(leading: 0.55em, justify: false)
    #show raw: set text(font: mono, size: size, features: ("calt": 0))
    #show raw.where(block: true): set block(fill: none, inset: 0pt, radius: 0pt, width: 100%)
    #body
  ]
]

// Capture d'écran : coins arrondis, filet discret, légende
#let shot(file, caption: none, width: 100%, height: auto) = figure(
  block(radius: 9pt, clip: true, stroke: 0.5pt + hair, width: width,
    image(P(file), width: 100%, height: height, fit: "cover")),
  caption: caption,
  supplement: [Capture],
  kind: "capture",
)

// Chiffre clé
#let stat(value, label, color: ink) = block(breakable: false)[
  #text(size: 2.1em, weight: 700, tracking: -0.03em, fill: color, value)
  #v(-0.9em)
  #text(size: 0.82em, fill: ink2, weight: 500, label)
]

// Style de tableau commun : pas de traits verticaux, filets fins
#let apple-tables(body) = {
  set table(
    stroke: (x, y) => (bottom: if y == 0 { 0.8pt + ink3 } else { 0.4pt + hair }),
    inset: (x: 6pt, y: 5.2pt),
    align: left + horizon,
  )
  show table.cell.where(y: 0): set text(weight: 650, fill: ink2, size: 0.86em)
  body
}

// ---------- Schéma d'architecture (dessin natif, mis à l'échelle par w) ----------
#let schema(w: 16cm, ts: 1) = {
  let u = w / 16
  let fs(x) = x * ts * 1pt
  let seg(x, y, len, ang, c) = place(dx: x * u, dy: y * u, line(length: len * u, angle: ang, stroke: 1pt + c))
  let head(x, y, dir, c) = {
    // dir : "l" vers la gauche, "r" vers la droite, "u" vers le haut
    let a = 0.11
    if dir == "r" { place(dx: (x - 0.2) * u, dy: (y - a) * u, polygon(fill: c, (0pt, 0pt), (0.2 * u, a * u), (0pt, 2 * a * u))) }
    else if dir == "l" { place(dx: x * u, dy: (y - a) * u, polygon(fill: c, (0.2 * u, 0pt), (0pt, a * u), (0.2 * u, 2 * a * u))) }
    else { place(dx: (x - a) * u, dy: y * u, polygon(fill: c, (0pt, 0.2 * u), (a * u, 0pt), (2 * a * u, 0.2 * u))) }
  }
  let harrow(x1, x2, y, label, c: ink3) = {
    seg(calc.min(x1, x2) + (if x2 < x1 { 0.18 } else { 0 }), y, calc.abs(x2 - x1) - 0.18, 0deg, c)
    head(x2 + (if x2 < x1 { 0 } else { 0 }), y, if x2 > x1 { "r" } else { "l" }, c)
    place(dx: calc.min(x1, x2) * u, dy: (y - 0.95) * u,
      box(width: calc.abs(x2 - x1) * u, align(center, text(size: fs(6.2), fill: ink2, weight: 500, label))))
  }
  let vcard(x, c, name, os, ip, roles) = place(dx: x * u, dy: 3.25 * u,
    block(width: 4.1 * u, height: 3.1 * u, fill: white, radius: 10pt, inset: 0.3 * u, stroke: 0.6pt + hair)[
      #set par(leading: 0.42em)
      #box(circle(radius: fs(3.4), fill: c), baseline: -0.1em)#h(0.35em)#text(size: fs(9.5), weight: 700, tracking: -0.01em, name) \
      #text(size: fs(6.6), fill: ink2, os) \
      #v(0.1em)#text(font: mono, size: fs(7.6), weight: 600, fill: c.darken(25%), ip)
      #v(0.05em)
      #text(size: fs(6.6), fill: ink, roles)
    ])
  let dns = c-dc.lighten(25%)
  block(width: w, height: 8 * u, {
    // Internet
    place(dx: 12.6 * u, dy: 0.25 * u, box(fill: gray-bg, radius: 99pt, inset: (x: 0.35 * u, y: 0.16 * u),
      text(size: fs(7), weight: 600, fill: ink2, "Internet")))
    place(dx: 11.3 * u, dy: 0.5 * u, line(length: 1.25 * u, stroke: (paint: ink3, thickness: 0.8pt, dash: "dashed")))
    place(dx: 11.35 * u, dy: 0.82 * u, text(size: fs(5.8), fill: ink3, "NAT · mises à jour"))
    // Poste hôte
    place(dx: 4.7 * u, dy: 0pt, block(width: 6.6 * u, height: 1.45 * u, fill: surface, radius: 10pt, inset: 0.28 * u)[
      #set par(leading: 0.4em)
      #box(circle(radius: fs(3.2), fill: c-host), baseline: -0.1em)#h(0.35em)#text(size: fs(8.6), weight: 700, "Poste hôte — Arch Linux") \
      #text(size: fs(6.5), fill: ink2, "QEMU/KVM · virt-manager · snapshots qcow2") \
      #text(font: mono, size: fs(7), weight: 600, fill: ink2, "192.168.50.1") #text(size: fs(6.3), fill: ink2, " passerelle NAT · DNS temporaire")
    ])
    seg(8, 1.45, 0.95, 90deg, ink3)
    place(dx: 8.15 * u, dy: 1.62 * u, text(size: fs(6), fill: ink2, weight: 500, "SSH 22 · Grafana 3000 · Prometheus 9090 (depuis l'hôte)"))
    // Réseau du labo
    place(dx: 0pt, dy: 2.4 * u, block(width: 16 * u, height: 5.6 * u, radius: 14pt,
      stroke: (paint: blue.lighten(45%), thickness: 0.9pt, dash: "dashed"), fill: rgb("#F7FAFF")))
    place(dx: 0.35 * u, dy: 2.6 * u, text(size: fs(7), weight: 650, fill: blue,
      "Réseau libvirt « infraready » · NAT · 192.168.50.0/24 · virbr50 · domaine infraready.test"))
    // Machines
    vcard(0.35, c-dc, "WIN-DC01", "Windows Server 2025", "192.168.50.10",
      [AD DS · DNS du domaine \ partage SMB « Lab » \ windows_exporter :9182])
    vcard(5.95, c-ops, "OPS01", "Ubuntu Server 26.04", "192.168.50.30",
      [Contrôleur Ansible · Git \ Prometheus :9090 \ Grafana :3000])
    vcard(11.55, c-lx, "LINUX01", "Ubuntu Server 26.04", "192.168.50.20",
      [Nginx :80 · disque ext4 \ /srv/infraready \ node_exporter :9100])
    // Flux d'administration et de collecte
    harrow(5.95, 4.45, 4.75, [WinRM 5985 (NTLM) \ collecte 9182])
    harrow(10.05, 11.55, 4.75, [SSH 22 (Ansible) \ collecte 9100])
    // Flux DNS des clients Linux vers le contrôleur de domaine (en L, sous les cartes)
    seg(13.6, 6.35, 0.8, 90deg, dns)
    seg(8, 6.35, 0.8, 90deg, dns)
    seg(2.4, 7.15, 11.2, 0deg, dns)
    seg(2.4, 6.55, 0.6, 90deg, dns)
    head(2.4, 6.35, "u", dns)
    place(dx: 2.4 * u, dy: 7.27 * u, box(width: 11.2 * u, align(center,
      text(size: fs(6.2), fill: c-dc.darken(10%), weight: 550, "DNS 53 · SMB 445 — LINUX01 et OPS01 sont clients du DNS de WIN-DC01"))))
  })
}
