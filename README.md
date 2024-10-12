# TIPE 2024-25

Repo contenant tous mes fichiers pour mon TIPE 24-25 sur le thème "Transition, transformation, conversion".

Je maintiens un fichier `history.md` contenant toutes les modifications jours par jours ainsi que mes réfléxions sur ce tipe/code.

Le sujet en étude est le suivant : Homologie persistante pour de la répartition de ressources : le cas des transports publics.

Pour l'instant, j'ai réalisé un fichier `data/example.dat` qui contient un exemple de donnée, ainsi en compilant le projet et en faisant "make && ./main" on obtient un fichier `exportedPD/pd_example.pers` qui contient le diagramme de persistance de l'exemple.

Pour l'afficher il faut avoir les dépendances `matplotlib` et `gudhi` installées, puis faire `python3 repr.py`.
