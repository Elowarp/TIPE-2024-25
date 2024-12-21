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

Pour définir notre langage _Luring_ (Language-Turing), on utilise le cours : https://web.stanford.edu/class/archive/cs/cs103/cs103.1132/lectures/19/Small19.pdf (langage_TM.pdf)

On a en premier lieu 5 commandes :

- `Move` `dir` : Déplace la tête de lecture sur la bande (`right` ou `left`)
- `Write` `s` : Ecrit le symbole `s` à l'endroit de la tête de lecture
- `Goto` `n` : Va à la ligne `n`
- `If` `s` `Go` `n` : Si le symbole `s` est lu alors aller à la ligne `n`
- `Nothing` : Ne fait rien
- `End` : Fini le programme

Chaque exécution est réalisé l'une à la suite de l'autre si aucune ligne ne le contredit

> ça ressemble quand même bcp à de l'assembleur

On veut ainsi démontrer qu'un langage est récursivement énumérable si et seulement s'il existe un programme en Luring le modélisant (sachange qu'un langage est récursivement énumérable ssi il existe une machine de turing le modélisant)

Pour ça, on va faire par double inclusion :

### Depuis une machine de turing vers du Luring
Construire un programme en Luring pour chaque état qui simule un état

Typiquement, un état final sera converti en le code `End`
Ensuite, pour les autres états, on procède dans cet ordre :

- Lire le symbole
- Ecrire le symbole qu'il faut selon la transition donnée
- Aller à l'état demandé

Pour la machine de turing à deux état (q0 et q1) tel que q1 est acceptant
et que lire un a depuis q0 envoie sur q1 avec écriture de b et déplacement à droite
et que lire un b depuis q0 envoie sur q0 avec écriture de a et déplacement à gauche

Code exemple

```
// q0
0 : If a Go 2
1 : If b Go 5

// Si a vient d'être lu depuis l'état q0
2 : Write b 
3 : Move Right
4 : Goto 8

// Si b vient d'être lu depuis l'état q0
5 : Write a
6 : Move left 
7 : Goto 0

// q1
8 : End
```

### Depuis le Luring vers une machine de turing 
On va construire des machines de turing pour chaque action puis les relier entre elle pour construire la machine finale

Pour plus de commodité, on appelle $q_n$ l'état depuis lequel la TM commence pour la commande à la ligne $n$

Par exemple, on a le cas trivial de l'instruction `End` qui se traduit par le lien vers un état acceptant

Ensuite on a le cas de `Move` :
Simplement on fait un deplacement dans la direction indiquée en copiant le caractère que l'on vient de lire

Pour `n : Goto k` :
On crée un état intermédiaire pour lequel on le relie depuis $q_n$ par un deplacement vers la droite en copiant le même caractère, puis on relie cet état intermédiaire à $q_k$ en copiant le même caractère mais en se déplacant à gauche (comme ça la tête de lecture ne se déplace pas)

Pour `n : Write s` :
Idem sauf que la premiere transition se fait en écrivant s et que k = n+1

Pour `n : If s Go k` :
Idem que goto, seulement là on veut que seul la transition qui lit s passe à l'état intermédiaire puis l'etat k et que toutes les autres aillent dans un autre état intermediaire pour ensuite aller à l'état $q_{n+1}$ en n'écrivant rien

Maintenant Implémentons ça !

Il faut un analyseur syntaxique du Luring et un arbre syntaxique ? Utilisation d'un ancien tp sur les grammaires etc : Le numerix

## 29/06/24

Pour expliquer le fonctionnement du parseur, il faut bien dire qu'on utilise des grammaires et les développer

Le problème que je rencontre c'est comment depuis des instructions on peut créer un automate, plus en particulier je sais comment créer les modules unitaires (par exemple pour `move`) mais pas comment les merge ensemble sans que les numéros se chevauchent

on crée n(= nb de lignes) états puis on crée les modules relativement à l'état de départ et l'état d'arrivé de la commande

Maintenant que la partie Luring into TM est faite, il faut faire la réciproque

## 30/06/24
J'ai fait le lien Luring -> Turintape_strg machine file (.tm) 

## 03/07/24
Pour l'instant on se base que sur des symboles de 1 caractère, et donc j'ai fait un interpréteur de fichier Luring 

Maintenant on se se focus sur la transformation turing into luring

### Convertir des états turing en code luring

Déjà d'un état acceptant on met juste un `End`

On va alors décomposer le code en plusieurs segments basés sur le nombre de lettres possible
On note n le nombre de symboles sans compter le symbole blanc donc pour un état q on va avoir

- n+1 lignes pour demander quel est le symbole lu et à quelle ligne on doit renvoyer
- n+1 blocs de 3 lignes : `Write`; `Move` puis `Goto`

Donc pour aller à un état en particulier on va devoir retenir à quelle ligne les n+1 lignes commencent

Si on a moins de n+1 transitions depuis un état on enleve juste les lignes correspondantes

On prend les p = nb d'états premieres lignes pour faire des goto 

**Comment montrer faire un luring prgm qui prend en compte qu'un état peut être acceptant et avoir des transitions sortantes ???**

**Théorème de rice pour montrer qu'on ne peut pas faire un programme qui comprend ce que dit la machine de turing**


Structure du code crée 

Goto etat initial
Goto q1
Goto q2
...
Goto qn
Write s
Move dir
Goto (n+1 +1) // Ici on ne connait pas la ligne où on veut aller pour toucher l'état n+1 alors on va à la ligne dans notre "sommaire" qui nous redirige vers la bonne ligne.
Par exemple à la ligne 2, on a la direction pour trouver l'état 1 etc


Le code produit par uncompiler est un code bon, alors que devrait faire des tests pour tous mes fichiers aifn de trouver d'ou vient le bug tel que quand je l'interprete avec interpreter, le code d'ajout binaire ne foncitonne pas

## 06/07/24
Je viens de realiser les tests pour les fichiers Turing/Lexer/Parser (aka les plus importants) et j'ai trouvé le problème qui faisait que je n'avais pas la même sémantique quand je faisais TM -> Luring -> TM.

Maintenant on observe que (via `Ressource\compteur_binaire_export_av_opti.pdf`) on a une explosion des états (de 3 on est passé à plus de 50 !). Mais la bonne nouvelle c'est que si on regarde plus en détail, nous avons beaucoup de suite d'états avec les mêmes transitions (tout l'alphabet + la caractère blanc), donc il serait simple de le réduire. A faire. Apres, à quoi ça servirait ? hein

Donc on sait que le décompileur fonctionne si no arrive a avoir la même sémantique. enft jsp si sémantique cest le bon mot mais en tt cas ils ont les memes résultats.

Essayons de démontrer par le th de rice que ce que j'essaye de faire n'est pas possible, sachant que je veux faire un programme qui a une machine de turing, donne un programme en Luring (Turing complet ?)

Th de rice : Pour toute fonction f et tout programme prog, il n'existe pas de programme pour vérifier que prog est une implantation de f.

**On peut utiliser le Th de Rice pour montrer que je ne peux pas assurer que ce que j'ai fait est tjrs bon**

On peut à la limite utiliser les mêmes techniques qu'utilisent les dèsobscurcissement de programme

## 17/07/2024
Pour le luring2 on implémente `Move` `dir` `Until` `{s1, s2, s3}`
luring3 : variables
luring4 : Multiple piste dans une bande
luring5 : Multiple piles
luring6 : Multiple bandes

## 20/07/2024
On implémente MoveUntil par du luring 1, par les commandes : 

Luring 2 :
```
n : Move Right Until [s1; s2; s3; ...; sN]
```

Conversion en luring 1 :
```
n : If s1 Go n+N+2
n+1 : If s2 Go n+N+2
...
n+N-1 : If sN Go n+N+2
n+N : Move Right 
n+N+1 : Goto n
n+N+2 : ....
```

Puis convertir de luring 1 en luring 2 est assez direct vu que toutes les opérations précédentes sont toujours valides.

Pour les variables (donc le luring3), on va devoir créer une syntaxe pour différentier les variables des symboles. On décide de mettre des "" autour des symboles, pour garder les lettres minuscules pour les variables.

Les variables ne vont que contenir des symboles, et on va pouvoir les utiliser dans les commandes `Write` et `If`

On va donc rajouter les instructions 

- `Load "s" into x` : Charge le symbole `s` dans la variable `x`
- `Load Current into x` : Charge le symbole actuellement lu dans la variable `x`
- `If x = "s" Go n` : Si la variable `x` est égale à `s` alors aller à la ligne `n`
- `If x != "s" Go n` : Si la variable `x` est différente de `s` alors aller à la ligne `n`
- `Write x` : Ecrit le contenu de la variable `x` à l'endroit de la tête de lecture

## 27/07/24
On change de sujet, la création d'un langage n'est pas vrmt intéressant (selon prof d'info) donc on part, selon ces conseils, sur un sujet du type : "Optimisation de machine de Turing, application à une suite de réduction"

Simplifier des expressions est un problème indécidable selon la source 6 de [ce site](https://www.cas.mcmaster.ca/~carette/publications/simplification.pdf)

La question qu'on doit se poser c'est optimisation de QUOI, optimisation de la taille de la machine de turing OU optimisation du temps d'exécution ? [pcq ce truc est surement intéressant](https://arxiv.org/pdf/1102.5389) en gros c'est pas un truc qui dit que comment optimiser le tps d'execution ni la taille mais qui regarde la diff entre les deux 

Il faudrait donc trouver un moyen de réduire la taille d'une machine de turing et voir comment ça impacte le temps d'exécution + l'appliquer à un pb concret

Par le th de rice il n'existe pas de programme qui peut donner le plus optimisé pour un problème donné

Une optimisation possible c'est clairement transformer une suite d'état où on fait la même chose en une seule transition (see ressources/compteur_bianires_export_av_opti.pdf)

Trouver des schemas d'états à réduire peut être une piste intéressante

On peut minimiser les tables de transitions en utilisant Karnaugh map analysis ou Reachability Tree analysis

mistral m'a donné ces pistes :

> develop the simplifications techniques

 Simplification techniques aim to eliminate unnecessary states,
transitions, or other elements in a Turing machine while preserving
its computational power as much as possible. Here are some common
methods for simplifying a Turing machine:

1. Eliminating Unreachable States: A state is considered unreachable if there is no way to enter it from the initial state or any other reachable state through a sequence of valid transitions. Eliminating
unreachable states does not affect the **computation** of the Turing machine, but it reduces its size and complexity.

2. Merging Equivalent States: Two states are equivalent if they have identical next-state functions for all possible inputs. Merging these states means combining their contents into a single state and updating the control program accordingly. This simplification technique can reduce the number of distinct states in a Turing machine without affecting its computational power.

3. Minimizing State Table: The state table is a tabular representation of a Turing machine's transition function, which lists the next-state and output for each combination of current state and input symbol. By applying various optimization techniques such as **Karnaugh map analysis** or **Reachability Tree analysis**, we can minimize the size of the state table while preserving its functionality.

4. Simplifying Control Structures: Turing machines can include complex control structures like loops, conditional jumps, and nested if-else statements. Simplifying these structures by reducing redundancy or eliminating unnecessary complexity can result in a smaller representation of the machine without altering its computational power.

5. Removing Redundant Transitions: A transition is considered redundant if it can be derived from other transitions through the application of simplification techniques like merging equivalent states, minimizing state tables, or eliminating unreachable states. By removing redundant transitions, we can reduce the size and complexity of a Turing machine without losing its computational power.

6. Eliminating State-independent Transitions: State-independent transitions are those that do not depend on the current state for their execution. These transitions can be merged with the control structure of the machine or moved to the initial or final states without affecting the computation. This simplification technique can help reduce the number of distinct states in a Turing machine.

7. Normal Forms: Converting a Turing machine into a simpler normal form, such as Greibach Normal Form (GNF) or Quadratic Normal Form (QNF), can help eliminate redundant transitions and simplify the control structure of the machine without altering its computational power for certain classes of languages.

In summary, these techniques aim to eliminate unnecessary elements in a Turing machine while preserving its computational power as much as possible. They include eliminating unreachable states, merging equivalent states, minimizing state tables, simplifying control structures, removing redundant transitions, and converting the machine into simpler normal forms for specific classes of languages. These techniques can help reduce the size and complexity of a Turing machine representation without losing its fundamental computational capabilities.

---

Pour utiliser les karnaugh map, on peut dire que pour chaque transitions du type $(q_1,a)\to(q_2,b,D)$ où les $q_i$ sont des états, $a$ et $b$ des symboles et $D$ une direction, on a un état de Karnaugh (EK) qui vaut $q$ + $a$ + $D$ pour chaque symbole $a$ et direction $D$

On met un 1 lorque il y a une transition, 0 sinon. Et pour chaque état de départ, on ne tient pas compte de la direction.

On a donc un tableau du genre, où la direction vaut 0 si c'est la gauche, 1 si c'est la droite.
(on se base sur ce [site](https://www.allaboutcircuits.com/textbook/digital/chpt-11/finite-state-machines/))

| Etat actuel (p colonnes) | Entrée Lettre (m colonnes) | Etat suivant (p colonnes) | Sortie Lettre + Direction (m + 1 colonnes) |

On prend $m$ comme le nombre de bits necessaires pour coder le nombre de symboles différents (avec le blanc) et $p$ le nb de bits necessaires pour coder le nombre d'états différents

Il faut voir si après la reduction de cette table on garde la même sémantique.

## 09/08/24

Une facon de gerer plusieurs output d'une table de karnaugh https://highered.mheducation.com/sites/dl/free/0072865164/147282/mar65164_ch03A.pdf

Mais il faut alors trouver un moyen de trouver une facon de transformer une une produit/somme de variables de karnaugh en une table de transition

Les tables de karnaugh je vois pas comment remonter à une table de transition alors je pars plus sur une transformation d'une TM en automate puis une methode de remplissage de table (table-filling algorithm) avec l'algorithme de John Hopcroft [source](http://i.stanford.edu/pub/cstr/reports/cs/tr/71/190/CS-TR-71-190.pdf)

Pour transformer une machine de turing en automate, soit un alphabet A sur lequel est def la TM, on def $A' = \{aKb, (a,b) \in A², K \in \{Right, Left\}\}$ et l'automate qui suit en est induit trivialement 

La on vient de réussir à faire une bijection entre une machine de turing et un automate, l'automate tel quel n'est pas vraiment utilisable ou alors il faudrait savoir quelles sont les modifications à faire à l'avance

On peut implementer l'algo de hopcroft dans minimisation.ml (Via `Langages formels` de carton et `Eléments dalgorithmique` (Beauquier Danièle) pages 330 dans ressources)

## 18/08/24
J'ai fini d'implémenter l'algorithme de minimisation de Hopcroft !!!!!! horrible le pire que j'ai jamais fait

J'ai donc fait du nettoyage dans le code et j'ai rajouté quelques tests qu'il faut développer pour minimisation et les dlists et + tester avec des machines de turing 

## 21/08/24

J'ai ajouté des tests, il faudrait que j'ai une fonction pour tester si deux automates acceptes le même langage pour rendre les tests plus rapide + rajouter au moins un automate de test. (Update : Fait !)

Puis essayer de minimiser des machines de turing pcq c'est qd meme ça le but. (Update : Fait !)

Il peut être intéressant de regarder la preuve de l'algorithme pour essayer d'adapter aux machines de turing et pas tant faire une bijection avec un automate comme j'ai fait. On ajouterait concrétement une plus value au tipe mais bon c'est déjà hardcore

Il faudrait trouver des problèmes qui se reduisent par machines de turing et donc finir le tipe sur ça

## 22/08/24

Focus sur la réduction de problèmes par machines de turing

Technique : https://perso.eleves.ens-rennes.fr/people/Julie.Parreaux/fichiers_agreg/info_lecons/913_MachineTuring.pdf

Bon il faut trouver des problèmes qui se réduisent par machines de turing, il faut que le problème auquel on réduit le tout soit DECIDABLE, sans quoi il existera pas de machine de turing mdr

Typiquement là des idées : https://fr.wikipedia.org/wiki/D%C3%A9cidabilit%C3%A9#Th%C3%A9ories_d%C3%A9cidables

On pourrait par exemple réduire le problème 2sat à 2color

Bref j'ai commencé une ébauche de la construction de la machine de turing qui renvoit vrai si un graphe est 2-coloriable (voir `Ressources/V1 MT.png`)

## 24/08/24

J'ai fini la construction de la machine de turing qui renvoit une coloration de graphe 2-coloriable sil est possible, ou qui rejette sinon (voir `Ressources/Tous les états MT.pdf`)

Parce que la machine est vraiment grosse et doit s'adapter en fonction des différentes tailles de graphes, je vais devoir faire une fonction qui génère la machine de turing en fonction d'une taille de graphe donnée, puis tester si effectivement elle fonctionne, et sinon la corriger.

On s'en servira pour utiliser la minimisation dessus.

Après calcul, pour des graphes de tailles au plus $n$, on a besoin de $18n + 9 + 2(l'état initial et l'état acceptant)$ états pour la machine de turing. Plutot pas mal d'avoir une machine de turing en taille linéaire par rapport à la taille du graphe

## 03/09/24

La machine de turing est faite mais elle ne marche pas. Bref faut la fix mais là je me concentre sur la recherche du langage accepté par l'automate transformé par la machine de Turing.

Bon j'ai démontré que ma transformation ne fonctionne PAS, ff on try de comprendre la preuve de hopcroft

Finalité : Le tipe entier ne fonctionne pas, je dois changer de sujet.


## 06/09/2024

Code barre durée de vie de chaque niveau 

1ere video
https://youtu.be/hHNFuQuEoxU?si=JlCuJ_FDXt5jDRW4
14:00 -> Exemple sur les avions, plutot cool pour comprendre 

2eme video
https://youtu.be/wvy0MoZv5KQ?si=u6eLjq70trTpMYLs

3eme video
https://www.youtube.com/watch?v=U-gdIxaG6PA&list=PLrRN3yszYHZkR9vyUeOVkcF6yy4FjgkMn&index=3

Application à l'IA :
https://youtu.be/Hro520ieHA8?si=f8FtrXvobeMg9YKf

Utiliser stable topological data analysis pour classifier des parties de modèles 3D pour comparer des modèles 3D

Découpage d'une scène en partie élémentaires pour essayer de voir a quel point on peut optimiser

A partir d'un nuage ne point on reconstitue le truc

scanner la chambre et dire que tel ou tel truc est tel objet 

Geodesic : La plus petite distance entre deux points sur une surface tordue

Des fichiers à download : https://segeval.cs.princeton.edu/

Le sain papier https://www.lix.polytechnique.fr/~maks/papers/perslocsig.pdf et pour la segmentation : Learning 3D Mesh Segmentation and Labeling

Utilisation sur les graphes : Décompositions en partie de chacune des parties d'un graphe

Utiliser du machine learning basé sur la persistance homologique pour résoudre le problème du sac à dos 

Persistance homologique pour la répartition de ressources : https://arxiv.org/pdf/2206.04834

## 08/09/24

TIPE : Utilisation de la persistance homologique (Analyse topologic) pour le developpement de lignes de metro

Pour cela on va suivre la méthode du papier de recherche : https://arxiv.org/pdf/2206.04834 (PH FOR RESOURCE COVERAGE.pdf)

Dans les trucs qui vont changer ya la facon de récuperer les données et définir les nouvelles distances

## 10/09/24
On commence à essayer de programmer la construction des VR complexes

On définit un fichier .dat qui contient les coordonnées des points et les points associés à chaque points : Limite à 2 chiffres significatifs : Voir `example.dat`

On définit aussi un fichier .pd qui contient les diagrammes
de persistance : Voir `example.pd`

https://arxiv.org/pdf/2307.16333 pour calculer les VR

## 14/09/24
On essaye de comprendre l'algorithme utilisée pour calculer les homologies

> $<ab>$ = Un simplex constitué des points a et b

> $Lune(<ab>) = \{ x \in X | d(a,x) < d(a,b) \text{ and } d(b,x) < d(a, b) \}$

> MST(X) = Minimum spanning tree = Arbre couvrant minimal

> RNG(X) = Relative Neighborhood Graph of X = Ensemble de sommets de X et d'arêtes de $E = \{ <xy> | lune(<xy>) \neq \emptyset \}$
> C'est l'ensemble des one-simplieces avec une lune vide

> Important : It should be noted that the above lemma also holds as long as X is a finite metric space with unique pairwise distances. This means that provided we have RNG(X) and MST(X) we know the following information about the one dimensional Vietoris-Rips persistent homology before actually computing it: The birth times of all homology classes with non-trivial persistence and the number of bars in the persistence barcode. The latter is particularly important because we will use it in the stopping condition utilised in the algorithm later in this paper

### Etapes de l'algorithme 
> Si nos points sont en 2D, pour calculer RNG on peut utiliser le truc de `Delaunator`

> On construit un arbre k dimensionnel, k dépendant du RNG, un tas min H de la forme (a, N[a][t], r, t) trié par rapport à r, on stock dans un tableau N les voisins du sommet i : N[i] = KNN(i, k). Si N[a] est vide on a une fonction qui retourne tt les voisins de a du plus proche au plus loin 

> $\psi$ est une bijection qui a chaque one simplex associe un entier, en gros un tableau qui a un simplex associe un entier

> Faire un parcours en prof pour trouver les composantes d'une lune

> T1 et T<1 sont des AVL, chaque noeud est de la forme  left, right, height, key and column -> Utilisé pour augmenter la reproduction des matrices


J'ai crée tous les fichiers que je pense on va avoir besoins pour les structures avant d'implémenter notre algorithme.

## 15/09/24
J'ai pu implémenter les tas max/min avec différents tests pour vérifier que tout fonctionne bien. De même pour les arbres k dimensionnels, le test de knn ne fonctionne pas mais je pense que ça vient de mon exemple qui n'à pas vraiment de cohérence métrique avec le schéma du cours que j'ai pris (cours de mirliaz). Tous les autres tests passent.

Il faudra donc implémenter les arbres AVL, les RNG et le truc des graphes puis nous pourront commencer à implémenter l'algorithme de calcul des homologies.

## 17/09/24
J'ai réparé KNN et implémenté les AVL, il faut maintenant implémenter les RNG et les graphes, pour la triangulation on va implémenter le truc de delaunay 

## 24/09/24
Triangularisation via l'algorithme décrit ici https://paulbourke.net/papers/triangulate/

```
subroutine triangulate
input : vertex list
output : triangle list
   initialize the triangle list
   determine the supertriangle
   add supertriangle vertices to the end of the vertex list
   add the supertriangle to the triangle list
   for each sample point in the vertex list
      initialize the edge buffer
      for each triangle currently in the triangle list
         calculate the triangle circumcircle center and radius
         if the point lies in the triangle circumcircle then
            add the three triangle edges to the edge buffer
            remove the triangle from the triangle list
         endif
      endfor
      delete all doubly specified edges from the edge buffer
         this leaves the edges of the enclosing polygon only
      add to the triangle list all triangles formed between the point 
         and the edges of the enclosing polygon
   endfor
   remove any triangles from the triangle list that use the supertriangle vertices
   remove the supertriangle vertices from the vertex list
end
```

## 29/09/24
Implémentation complète de l'algorithme de triangulation !!!!!!!!
Pour tester : `python3 repr.py` compile le code et pour un nombre aléatoire de points a des emplacements aléatoires, affiche le graphe triangulé. 
J'ai aussi commencé à implémenter les graphes, RNG et MST et j'ai même commencé l'algorithme finale. 

Bon deux gros problèmes : Trouver la data sur laquelle vérifier que le programme est bon, comprendre bien l'algorithme et trouver la data pour faire le tipe quoi ???

## 01/10/24

En fait on tej le papier qui décrit un algorithme de fou de complexité de bz pour faire l'approche naive 

Ex naif : https://www.jeremykun.com/2015/08/06/cech-vietoris-rips-complex/

Ex d'utilisation des PD : https://iuricichf.github.io/ICT/algorithm.html

Standard algorithm : L'algorithme pour réduire une matrice de bordure en des codes barres

Donc les étapes :

- Définir un ordre total sur les simplexes (les points, les arêtes, les triangles etc) cad que si s'il apparait dans un complexe simplical alors il doit etre plus petit que tous les autres simplexes dans les complexes simpliciaux qui le suivent et qui sont pas dans celui là
- Itérer sur un R pour la filtration de Veirotis-Rips et à chaque nouveau simplexe on attribue un numéro de simplicial complexe
- On construit un tableau de bordure
- On réduit le tableau de bordure
- On crée les diagrammes

On définit a chaque simplexe un quadruplet (i, j, k, f) avec i,j,k les indices des points dans le tableau de points et f qui vaut 1 si ya une face et 0 sinon. On a j et k qui valent 0 si on est sur un point et k qui vaut 0 si on est sur une arête.

On pose qu'une filtration n'est qu'une liste de simplexes ordonnée par leur numéro de simplicial complexe, sachant filt[i] contient le nombre d'élément des K_i, ce qui est cohérent vu K_i inclus dans K_j si i < j

On a donc l'algorithme

```
R <- Le rayon courant
Eps <- le rayon par lequel on ajoute pour faire les VR complexes 
Tant que le dernier complexe simplical n'est pas complet (cad qui contient tous les simplexes possibles) :
   K_i <- VR Complexe simplical de rayon R
   Pour tout simplexe s de K_i :
      Si s n'est pas dans le complexe simplical précédent alors
         Ajouter le dernier id attribué à un simplexe à l'indentifiant de s
         Ajouter s à la liste des simplexes
   Fin Pour
   R <- R + Eps
```

Alors par construction, on a une filtration et un ordre total sur les simplexes

## 06/10/24

Ok on va être clair sur les structures : 
On identifie un simplex à son identifiant unique
Complexe simplical c'est un tableau de booléen qui dit si un simplex est dans le complexe simplical ou pas
Filtration c'est 2 tableaux, F et N, F[i] = k si le simplex i est dans le complexe simplical k (k=-1 pas encore apparu) et N[i] = j si le simplex i est le j-eme simplexe apparu dans la filtration(j=-1 pas encore apparu)

J'ai donc réussi à créer une filtration depuis un fichier .dat, il faut maintenant implémenter l'algorithme "standard" pour réduire la matrice de bordure (pas capté ct quoi mais bon).

On peut utiliser les infos du papier : https://epjdatascience.springeropen.com/articles/10.1140/epjds/s13688-017-0109-5

## 10/10/24

On a réussi à implémenter l'algorithme de réduction de la matrice de bordure, et la création des diagrammes de persistance avec comme test la comparaison avec les diagrammes du site mentionné plus haut https://iuricichf.github.io/ICT/algorithm.html.

Nous faisons la distinction entre les filtrations injectives et non injectives MAIS la construction de notre filtration est injective par construction, donc on s'en fiche un peu au final.

## 12/10/24

J'ai rédigé un document résumant toutes les définitions pour mieux comprendre ce que je fais, il se nomme `rapport.pdf` dans Documents. Mauvais point : Je ne comprends toujours pas comment déterminer la classe d'homologie d'un simplexe.

Dans les choses a changer : savoir associé un simplexe à un temps de découverte en plus de son identifiant (ie avoir des nombres de classes d'homologies flottants).

Il nous faut définir les valeurs que l'on va prendre pour remplir nos nuages de points.

## 15/10/24

En général :
Pour calculer le temps de trajet à pied ou en voiture on utilise https://apidocs.geoapify.com/docs/route-matrix/ /!\ le trajet dans le deux sens nont pas le mm temps donc on va utiliser la moyenne entre les deux temps pour avoir une distance symétrique.

Pour Paris :

- carte des points metro : https://prim.iledefrance-mobilites.fr/fr/jeux-de-donnees/traces-du-reseau-ferre-idf
- Etat des lignes pour recup les temps d'attente (à moyenner): https://prim.iledefrance-mobilites.fr/fr/apis/idfm-ivtr-requete_unitaire ou 

Pour Marseille :

- carte des points metro : https://data.ampmetropole.fr/explore/dataset/points-d-arret-de-tout-les-reseaux-de-transport/table/ (/!\ a trier)
- Temps d'attente (à moyenner): https://transport.data.gouv.fr/resources/39589?issue_type=DuplicateStops#issues

Pour Toulouse :

- https://transport.data.gouv.fr/resources/81678

Pour Rennes :

- https://transport.data.gouv.fr/datasets/versions-des-horaires-theoriques-des-lignes-de-bus-et-de-metro-du-reseau-star-au-format-gtfs

Dans les trucs qu'il faut faire :

- Définir les VR avec les boules dans le code
- Créer un fichier qui récupère les distances entre chaque station de metro en temps
- Definir des fichiers dist_villes.txt pour définir notre distance sur nos points des villes
- Savoir dessiner les zones de trous sur la carte
- Faire des analyses statistiques

On va construire les VR par incrémentation par secondes et on renomme les fichiers de points par example_pts.txt

## 22/10/24

On a trié et recup tt les infos pour calculer les trucs sur marseille, on va calculer la plus grande distance entre deux point pour savoir quand arreter la boucle while

## 19/11/24

Représentation sur la carte des stations de marseille + les morts de 1d simplexes avec evaluation rapide des statistiques

Important : Pourquoi j'ai que la naissance d'un seul 1d et pas plus ?

pts.txt : [lat] [long] [weight] [nb_line]

Pour améliorer la recherche, trouver un moyen d'importer les fichiers textes vers des bases de données 

## 23/11/24

On utilise https://www.convertcsv.com/csv-to-sql.htm pour faire les conversions en sql

Commande pour obtenir tous les arrets d'une ligne nommé "A" : 

SELECT * FROM stops JOIN stop_times ON stops.stop_id = stop_times.stop_id WHERE stop_times.trip_id = (SELECT DISTINCT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_short_name = "A") LIMIT 1);

Pour avoir le temps moyen d'attente 

SELECT TIMEDIFF(MAX(arrival_time), MIN(arrival_time)) / (COUNT(arrival_time)-1) AS mean_val FROM stop_times WHERE trip_id = (SELECT DISTINCT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_short_name = "A") LIMIT 1);

Pour chq station de la ligne line:61 en prenant que ce sont les mm tps ds les deux sens de circulation

<!-- SELECT stop_id, TIMEDIFF(MAX(arrival_time), MIN(arrival_time)) / (COUNT(arrival_time)-1) AS mean_val FROM stop_times WHERE trip_id in (SELECT trip_id FROM trips WHERE route_id = "line:61" AND direction_id = 0) GROUP BY stop_id; -->

SELECT stop_id, AVG(Elapsed) FROM (SELECT stop_id, TIMEDIFF(Lead(arrival_time, 1) OVER(PARTITION BY stop_id ORDER BY arrival_time), arrival_time) as Elapsed  FROM stop_times WHERE stop_times.trip_id IN (SELECT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_short_name = "A") AND direction_id = 0)) as t GROUP BY stop_id;

La commande qui renvoie long lat avg tps d'attente et le nom de la station :

```sql
SELECT stop_lat, stop_lon, cast(AVG(avg_waiting_time) as dec(8, 4)) as waiting_time, stop_name 
   FROM stops 
      JOIN 
         (
            SELECT stop_id as stp, AVG(Elapsed) as avg_waiting_time 
            FROM (
               SELECT stop_id, TIMEDIFF(Lead(arrival_time, 1) OVER(PARTITION BY stop_id ORDER BY arrival_time), arrival_time) as Elapsed  
               FROM stop_times 
               WHERE 
                  stop_times.trip_id IN (
                     SELECT trip_id FROM trips WHERE route_id IN (SELECT route_id FROM routes WHERE route_short_name IN ("M1", "M2") AND route_type = 1)
                  )
            ) as t 
            GROUP BY stop_id
         ) times 
      ON stops.stop_id = times.stp GROUP BY stop_name
   INTO OUTFILE '/mnt/Partage/Cours/TIPE_2024-25/Code/SourceData/toulouse/toulouse_pts.txt' FIELDS TERMINATED BY ' ';
```

## 24/11/24

Attention : Mis en lumière par toulouse mais on construit notre complexe simplicial tant que on atteint pas une des distances max du problèmes, mais ca ne prend pas en compte que si la dist_max < aux poids des sommets alors ils ne sont jamais traité 

Obtenir le fichier des shapes :

```sql
SELECT route_short_name, shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence 
   FROM (
      SELECT shp.shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence, route_id 
      FROM (
         SELECT DISTINCT shape_id, route_id 
         FROM trips 
         WHERE route_id IN (
            SELECT route_id 
            FROM routes 
            WHERE route_short_name IN ("M1", "M2")
         ) AND direction_id = 0
      ) shp 
      JOIN shapes ON shapes.shape_id = shp.shape_id
   ) infos 
   JOIN routes ON infos.route_id = routes.route_id 
   INTO OUTFILE '/mnt/Partage/Cours/TIPE_2024-25/Code/SourceData/marseille/marseille_shapes.txt' FIELDS TERMINATED BY ' ';
```

Pour les distances sur toulouse, elles me paraissent particulièrement grande (~250mn de moyenne) sans raison apparante

Indeed : J'ai inversé lat et lon donc on prend comme convention lat, lon 

On utilise : https://github.com/jamesrwilliams/gtfs-to-sql/blob/master/sql/load-gtfs.sql Pour transformer un dossier GTFS en sql pour faire nos requetes

## 3/12/24

Nous avons un problème dans les statistiques : les temps d'aparrition sont incohérents, en effet cela doit surement venir de la notation des simplexes qui ne tient pas compte du temps d'apparition, seulement de l'ordre d'apparition : On change donc le nom d'un simplexe en fonction de son rang d'apparition.

Après implémentation, on est sur des ordres de grandeurs de la minute qui est bcp plus cohérent avec notre pb.

Et rapport ens 95% fini yey 

Passage entier sur la conversion de données GTSL en filtration

## 8/12/24

J'ai remanié le dossier et réparé les tests du persDiag.c

SELECT stop_lat, stop_lon, cast(AVG(avg_waiting_time) as dec(15, 4)) as waiting_time, stop_name 
   FROM stops 
      JOIN 
         (
            SELECT stop_id as stp, AVG(Elapsed) as avg_waiting_time 
            FROM (
               SELECT stop_id, TIMEDIFF(Lead(arrival_time, 1) OVER(PARTITION BY stop_id ORDER BY arrival_time), arrival_time) as Elapsed  
               FROM stop_times 
               WHERE 
                  stop_times.trip_id IN (
                     SELECT trip_id FROM trips WHERE route_id IN (SELECT route_id FROM routes WHERE route_short_name IN ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14") and route_type = 1)
                  )
            ) as t 
            GROUP BY stop_id
         ) times 
      ON stops.stop_id = times.stp GROUP BY stop_name INTO OUTFILE '/mnt/Partage/Cours/TIPE_2024-25/Code/SourceData/paris/paris_pts.txt' FIELDS TERMINATED BY ' '

le tracé des lignes de metro ici https://data.iledefrance-mobilites.fr/explore/dataset/traces-des-lignes-de-transport-en-commun-idfm/information/?disjunctive.route_type