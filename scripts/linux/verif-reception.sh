#!/usr/bin/env bash
# Vérifications de réception d'une VM Ubuntu InfraReady — LECTURE SEULE, ne modifie rien.
#
# Usage :
#   ./verif-reception.sh [IP_A_TESTER ...] | tee S02_$(hostname)_reception.txt
# Exemple sur LINUX01 :
#   ./verif-reception.sh 192.168.50.1 192.168.50.10 192.168.50.30 | tee S02_linux01_reception.txt
#
# Relire la sortie avant de la committer : elle ne doit contenir aucun secret.

set -u

run() {
    printf '\n### %s\n' "$*"
    "$@" 2>&1
    printf '[code retour : %s]\n' "$?"
}

printf '=== Réception %s — %s ===\n' "$(hostname)" "$(date '+%Y-%m-%d %H:%M:%S %Z')"

# 1. Configuration locale
run hostnamectl
run lsb_release -a
run ip -br link
run ip -br address
run ip route
run resolvectl status

# 2. Connectivité IP vers les cibles passées en argument
for target in "$@"; do
    run ping -c 3 -W 2 "$target"
done

# 3. Résolution de noms
run getent hosts ubuntu.com
run getent hosts WIN-DC01.infraready.test   # échec attendu tant qu'AD DS / DNS n'est pas en service

# 4. Services et ports en écoute
run systemctl is-active ssh
run ss -lnt
run systemctl --failed --no-pager

# 5. Mises à jour en attente
run apt list --upgradable
if [ -f /var/run/reboot-required ]; then
    printf '\n### Redémarrage requis : OUI\n'
else
    printf '\n### Redémarrage requis : non\n'
fi
