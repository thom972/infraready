# Séance 1 — Bilan et synthèse individuelle

> **À rédiger par chaque membre du binôme, avec ses propres mots.** Les pistes ci-dessous
> rappellent ce qui a réellement été fait pendant la séance ; elles ne remplacent pas ta rédaction.

## Bilan de fin de séance (support 1, §7)

1. **Quelle compétence concrète avez-vous acquise ?**
   *Piste :* traduire un besoin métier en services, puis en flux nommés avec source, destination et port.
2. **Quel test vous semble le plus fiable pour vérifier votre travail ?**
   *Piste :* un test ciblé sur le port du service (`nc -zv`, `Test-NetConnection -Port`), plus
   fiable qu'un ping qui ne teste qu'ICMP.
3. **Quelle erreur avez-vous rencontrée et comment l'avez-vous isolée ?**
   *Piste :* l'incohérence entre le kit (WinRM non activé) et le sujet (playbook Windows obligatoire),
   isolée en comparant les deux documents et résolue par la règle de priorité du kit.
4. **Quel risque devez-vous garder à l'esprit lors de la prochaine séance ?**
   *Piste :* se couper l'accès en appliquant l'IP fixe ; travailler depuis la console et utiliser
   `netplan try`.
5. **Quelle partie de votre documentation un autre binôme pourrait-il avoir du mal à suivre ?**
   *Piste :* la distinction entre flux du kit et flux ajoutés (SSH Ansible) ; la note de
   justification l'explique.

## Synthèse individuelle (annexe D)

| Élément | Réponse |
|---|---|
| Compétence maîtrisée sans aide | |
| Commande ou procédure encore à vérifier | |
| Erreur rencontrée et méthode d'isolement | |
| Risque principal pour la séance suivante | |

## État des livrables de la séance 1

| Livrable | Emplacement | Statut |
|---|---|---|
| Schéma d'architecture prévisionnel et légendé | `docs/schemas/`, `docs/seance-01/03-architecture.md` | Validé |
| Tableau d'inventaire prévisionnel | `docs/seance-01/04-inventaire-previsionnel.md` | Validé |
| Plan de tests réseau et DNS pour la séance 2 | `docs/seance-01/05-plan-de-tests.md` | Validé |
| Note de justification et points à valider | `docs/seance-01/07-note-justification.md` | Validé |
