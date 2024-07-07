# TIPE Luring (Turing Language) 2024-25

Repo contenant tous mes fichiers pour mon TIPE 24-25 sur le thème "Transition, transformation, conversion".

Je maintiens un fichier `history.md` contenant toutes les modifications jours par jours ainsi que mes réfléxions sur ce tipe/code.
Le but de ce TIPE est de créer un langage de programmation Turing Complet (qu'on appelera le Luring) et d'arriver à transformer chaque programme écrit en Luring en machine de turing pour l'exécution et mais surtout de faire l'opération inverse : transformer une machine de Turing en un programme écrit en Luring.

Des exemples de fichier luring `.lu` sont donnés dans `Code/luring_programs/`. La syntaxe est décrite dans le fichier `history.md`.

Pour tester l'exécution d'un programme Luring, il faut faire :

```bash
cd Code/
make interpreter
./interpreter prgm.lu
```

Avec `prgm.lu` le programme en luring

Par exemple, tester l'addition de 1 à un nombre binaire (ici `0101`), on a l'affichage suivant :

```bash
elo@yoga:/mnt/Partage/Cours/TIPE_2024-25$ cd Code/
elo@yoga:/mnt/Partage/Cours/TIPE_2024-25/Code$ make interpreter
ocamlc -g turing.ml lexer.ml parser.ml compiler.ml interpreter.ml -o interpreter
elo@yoga:/mnt/Partage/Cours/TIPE_2024-25/Code$ ./interpreter luring_programs/increase_counter.lu
Vous êtes en train d'exécuter le fichier luring_programs/increase_counter.lu, il faut une entrée pour l'exécution de ce programme, merci de l'écrire : (le caractère blanc est le caractère _ )
0101
Votre bande est celle ci :  [ ... 0 1 0 1 ... ]
Exécution du programe : 
Bande résultante :  [ ... 0 1 1 0 ... ]
```

Pour afficher toutes les étapes faites par la machine de Turing, modifier la derniere ligne du fichier `interpreter.ml` par `run_luring filename ~verbose:true tape`

Un `make clean` pour supprimer tous les fichiers parasites, et `make cleanall` pour supprimer les fichiers parasites et les exécutables.
