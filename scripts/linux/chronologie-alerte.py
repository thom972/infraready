#!/usr/bin/env python3
"""Chronologie d'une alerte reconstituee depuis l'historique de Prometheus (lecture seule).

A lancer sur OPS01 (Prometheus ecoute sur localhost:9090).

Exemples :
  # Demonstration du seuil disque (partie F)
  python3 chronologie-alerte.py --alerte EspaceDisqueFaibleLinux \
    --condition 'node_filesystem_avail_bytes{hote="LINUX01",mountpoint="/srv/infraready"} / node_filesystem_size_bytes{hote="LINUX01",mountpoint="/srv/infraready"} < 0.15'

  # Incident : cible injoignable (partie H)
  python3 chronologie-alerte.py --alerte HoteInjoignable --condition 'up{hote="LINUX01",job="linux"} == 0'
"""
import argparse
import datetime
import json
import urllib.parse
import urllib.request
import zoneinfo

PROMETHEUS = "http://localhost:9090"
PARIS = zoneinfo.ZoneInfo("Europe/Paris")


def instants(expr, heures, pas):
    """Renvoie les horodatages (secondes) ou l'expression PromQL a renvoye une valeur."""
    fin = datetime.datetime.now(datetime.timezone.utc).timestamp()
    params = urllib.parse.urlencode(
        {"query": expr, "start": fin - heures * 3600, "end": fin, "step": pas}
    )
    with urllib.request.urlopen(f"{PROMETHEUS}/api/v1/query_range?{params}") as reponse:
        series = json.load(reponse)["data"]["result"]
    return sorted(float(t) for serie in series for t, _ in serie["values"])


def heure(ts):
    d = datetime.datetime.fromtimestamp(ts, datetime.timezone.utc)
    return f"{d:%d/%m %H:%M:%S} UTC  ({d.astimezone(PARIS):%H:%M:%S} heure de Paris)"


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--alerte", required=True, help="nom de l'alerte (alertname)")
    p.add_argument("--condition", required=True, help="expression PromQL vraie pendant l'anomalie")
    p.add_argument("--heures", type=float, default=24, help="periode analysee, en heures (defaut 24)")
    p.add_argument("--pas", type=int, default=15, help="resolution en secondes (defaut 15)")
    a = p.parse_args()

    evenements = [
        ("Anomalie observee (condition vraie)", a.condition),
        ("Alerte en attente (pending)", f'ALERTS{{alertname="{a.alerte}",alertstate="pending"}}'),
        ("Alerte declenchee (firing)", f'ALERTS{{alertname="{a.alerte}",alertstate="firing"}}'),
    ]
    print(f"Chronologie de l'alerte {a.alerte} - {a.heures:g} dernieres heures, pas de {a.pas} s\n")
    for nom, expr in evenements:
        t = instants(expr, a.heures, a.pas)
        if t:
            print(f"{nom}\n  debut : {heure(t[0])}\n  fin   : {heure(t[-1])}\n")
        else:
            print(f"{nom}\n  aucune donnee sur la periode\n")
    print("Lecture : la fin de l'anomalie correspond au retour a la normale (fichier supprime,")
    print("service relance) ; la fin de l'etat firing correspond a la resolution de l'alerte.")


if __name__ == "__main__":
    main()
