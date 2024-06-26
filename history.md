# History

Fichier contenant l'historique des recherches et commentaires fait à moi même pour l'avancement de mon TIPE

## 20/06/24

Recherche d'un sujet sur les machines de Turing. Ce qui peut être intéressant c'est une automatisation de la conversion d'un problème en une machine de Turing

Ce qui entraine :
- La création d'un programme capable d'executer une machine de turing en fonction des différentes entrées [sous Chaine de caractères ?](https://fr.wikipedia.org/wiki/Machine_de_Turing_universelle#Encodage_d'une_machine_de_Turing)
- La recherche d'un papier traitant d'un problème réduit à une machine de turing

Papiers intéressants :
- [Turing Test as a Defining Feature of AI-Completeness](http://cecs.louisville.edu/ry/TuringTestasaDefiningFeature04270003.pdf)

Une machine de turing modifiant son comportement en fonction de ces actions ? une sorte de machin de turing qui evolue au cours du temps ?

Vocabulaire sur [les machines de Turing](https://www.lix.polytechnique.fr/~bournez/cours/CoursDEAComplexite/01-N-Machines-De-Turing.pdf)


## 25/06/24

Construire une machine de Turing dans minecraft et donc contruire un convertisseur de programme into machine de turing dans minecraft (enft non c'est nul et puis on va m'accuser de reprendre le même sujet que l'an dernier)

Transformation *automatique* de programme en machine de Turing ? (Le but ?)

Transformation d'un langage into machine de turing : [https://web.stanford.edu/class/archive/cs/cs103/cs103.1132/lectures/19/Small19.pdf](https://web.stanford.edu/class/archive/cs/cs103/cs103.1132/lectures/19/Small19.pdf)

Les practical-uses des machines de turing sont enft pas folle, je vois pas à quoi ca peut nous servir

Peut être chercher une façon de transformer une machine de turing en un programme ? Un peu comme un compileur 

Isomorphisme des langages de programmation et des preuves en maths : https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence

Reconnaitre des variables etc dans une machine de turing : regarder du coté de LLVM

Exactement(Edit: Pas vraiment) ce que je cherche : https://cs.stackexchange.com/questions/118260/how-to-translate-automatons-turing-machines-into-programs-of-high-level-progra ainsi que https://www.longdom.org/articles/reverse-engineering-turing-machines-and-insights-into-the-collatz-conjecture.pdf

Réductions à partir des IRR ?? [Fichier Turing_Machines.pdf]

Site web de qqun qui a l'air d'avoir fait des choses : http://bluesky-home.co.uk/

Bon tout ça me parait un peu trop compliqué et n'arrive pas à conclure sur la question, parcontre j'ai trouvé qu'on pouvait trouver une grammaire dépendant d'un contexte qui admet pour langage le même que celui de la machine de turing : https://arxiv.org/abs/1912.09608

The problemo est que je pensais à utiliser le TP que javais fait sur la compilation du Numerix pour utiliser la même chose avec les grammaires, OR, on s'occupait que de la partie analyse _syntaxique_ et ici on fait une analyse _sémantique_, ff.


Chercher aussi a transformer une TM en assembleur, peut etre plus facile ?

On va se limiter à des programmes qui prenne un entier codé par 0 ou 1 donc on aura une turing machine avec n états et 10 symboles (+ le symbole blanc)

on aurait donc 

- une variable représentant la bande
- une fonction pour chaque etat ? ça me parait pas bon quoi parce qu'on peut très bien avec une explosion d'état pour un programme tout con genre une boucle je pense

Si on une détection de cycle dans le graphe représentant la TM, on peut identifier une boucle surement ?

## 26/06/24

On tente d'implémenter le langage qui sera converti en machine de turing ainsi qu'un interpréteur en ocaml

Interpréteur de machine de turing fonctionne bien yessssss
Il faudrait maintenant définir notre nouveau langage ainsi qu'un syntaxe pour écrire des machines de turing dans des fichiers tm 

En l'occurrence, on définit un fichier tm comme il suit (avec un compteur binaire pour exemple):

```text
4
2
-1
0
2,3
0,0,0,0,R
0,1,0,1,R
0,-1,1,-1,L
1,0,2,1,L
1,1,1,0,L
1,-1,2,1,L
```

- La première ligne est le nombre d'états de notre machine de turing
- La seconde ligne est le nombre de symboles de notre machine de turing (sans le caractère blanc)
- La troisième ligne est le caractère blanc
- La quatrième ligne est l'état initial
- La cinquième ligne est la liste des états finaux/acceptants
- Toutes les autres lignes décrivent les transitions :
  - Une ligne est de la forme "q1,c1,q2,c2,M" où
    - `q1` est l'état d'où la transition commence
    - `c1` est le caractère lut sur la transition
    - `q2` est l'état d'arrivé
    - `c2` est le caractère écrit
    - `M` est le déplacement du curseur, il peut être de deux formes : L (Left) ou R (Right)
  
_Dans cet exemple, l'état `3` ne sert à rien, il n'a que pour but de montrer une liste d'état finaux._
