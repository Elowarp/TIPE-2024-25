# TIPE Turing Minimisation 2024-25

Repo contenant tous mes fichiers pour mon TIPE 24-25 sur le thème "Transition, transformation, conversion".

Je maintiens un fichier `history.md` contenant toutes les modifications jours par jours ainsi que mes réfléxions sur ce tipe/code.
Le but de ce TIPE est de trouver un algorithme permettant de minimiser le nombre d'états d'une machine de turing et de l'appliquer sur une suite de réduction de problèmes, tels que 3SAT etc.

J'ai pour cela implémenter l'algorithme de Hopcroft sur ma minimisation d'un automate fini déterministe, j'ai de plus implémenter un convertisseur de machine de Turing en automate fini déterministe ainsi que son inverse. Nous avons donc un algorithme de minimisation, qui ne donne en revanche pas necéssairement la machine de turing minimale, mais qui donne une machine de turing au pire de la même taille que celle initiale, au mieux plus petite.

L'algorithme de Hopcroft se trouve dans le fichier `Code/minimisation.ml` et se base sur la version donnée dans le livre `Elements d'algorithmique (Mme Beauquier eet M Berstel)`.

Des tests sont disponibles dans le dossier `Code/tests/`, où simplement en faisant `make test` dans le dossier `Code/` pour lancer les tests.

Un `make clean` pour supprimer tous les fichiers parasites, et `make cleanall` pour supprimer les fichiers parasites et les exécutables.