# TIPE 2024-25

## Rapides explications

Repo contenant tous mes fichiers pour mon TIPE 24-25 sur le thème "Transition, transformation, conversion".

Je maintiens un fichier `history.md` contenant toutes les modifications jours par jours ainsi que mes réfléxions sur ce tipe/code.

Le sujet en étude est le suivant : Homologie persistante pour de la répartition de ressources : le cas des transports publics.

La plus grande partie de mon travail peut être observée dans le fichier `rapport.pdf`. Celui ci condense tout mon travail pour l'instant, il n'est pas final mais assez fini pour en donner une première approche.

## Utilisation

Le projet se décompose en deux parties, en supposant la récolte de données effectuée, la première est le calcul des classes d'homologies 0D et 1D issues de nos données en C, la seconde est le traitement et l'affichage des données en python.

Avant tout il faut se rendre dans le dossier Code :

```bash
cd Code
```

Le C est pur, il n'y a rien à installer. En revanche, le module de traitement suppose que les modules de `requirements.txt` soient installés :

```bash
pip install -r requirements.txt
```

Pour compiler le C, un simple `make` fera l'affaire.

Maintenant un fichier `main` est crée, celui ci prend 1 à 2 arguments, le premier qui est obligatoire est celui du nom de la ville (par exemple `marseille`). Le programme ira chercher de lui meme les fichiers relatifs au nom de la ville dans le dossier `data/` (en l'occurrence `marseille_pts.txt` et `marseille_dist.txt` si l'option `-e` n'est pas ajoutée à la commande).

Les informations sur les classes d'homologies ainsi que les simplexes tuant des 1D classes se retrouvent exportées dans `exportedPD/` en tant que `nomville.dat` et `nomville_death.txt` respectivement.

Le 2nd argument est l'option `-e` discutée plus haut. Lorsque rajoutée, le programme utilisera la distance euclidienne sur les points plutôt qu'un fichier `_dist.txt` associé au nom de ville.

C'est à peu près tout pour le programme principale.

Pour le Python, on va simplement utiliser `python repr.py nomville` avec `nomville` le nom de la ville que l'on a renseigné plus tôt lors de l'exécution de `main`. Le diagramme de persistance et l'affichage des simplexes sur la carte se trouvent dans le dossier `images/` avec les noms correspondant.
