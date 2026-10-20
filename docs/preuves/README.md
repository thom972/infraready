# Preuves de fonctionnement

Une preuve est un élément **observable** qui soutient une affirmation : sortie de commande,
capture lisible, résultat de workflow, état de service (support 2, annexe B).

## Convention de nommage

`S<séance>_<machine>_<objet>.<txt|png>` — exemples : `S02_linux01_reception.txt`,
`S02_ops01_ansible-ping.png`, `S02_win-dc01_ip.png`.

## Produire une preuve

```bash
# Linux : sortie complète horodatée
./scripts/linux/verif-reception.sh 192.168.50.1 192.168.50.10 | tee S02_linux01_reception.txt
```

```powershell
# Windows
.\scripts\windows\Verif-Reception.ps1 | Tee-Object -FilePath S02_win-dc01_reception.txt
```

Chaque capture porte un titre et une légende dans le tableau ci-dessous.

## Avant de committer une preuve

- Aucun mot de passe, jeton, clé privée ni information personnelle.
- La preuve correspond à un test du tableau de réception.

## Index des preuves

| Fichier | Exigence / test | Ce qu'il démontre |
|---|---|---|
| | | |
