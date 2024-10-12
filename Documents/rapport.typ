#import "@preview/diverential:0.2.0"
#import math
#set heading(numbering: "I.1.1")
#set text(
  font: "New Computer Modern"
)

#set document(
  title: "TIPE : Persistance homologique"
)

TIPE : Persistance homologique

#outline()

= Définitions

== Géométrie

On appelle enveloppe convexe d'un ensemble de points $X$ l'ensemble des points qui peuvent être écrits comme une combinaison convexe des points de $X$. Formellement, l'enveloppe convexe de $X$ est définie comme : Soit A une partie de E. L'enveloppe convexe de A est l'intersection de toutes les parties convexes de E qui contiennent A. 

On appelle _simplexe_ $sigma$ la généralisation d'un triangle en dimension quelconque. Par exemple :
- Un simplexe de dimension 0 est un point, noté $sigma = x$.
- Un simplexe de dimension 1 est une arête, noté $sigma = x space y$.
- Un simplexe de dimension 2 est un triangle, noté $sigma = x space y space z$.
Avec $x$, $y$ et $z$ des sommets.

#figure(
  image("images/cech.png"),
  caption: [Exemples de simplexes en dimension 0, 1 et 2 (de gauche à droite).],
)

L'orientation d'un simplexe est définie par un ordre sur ses sommets. Par exemple, un triangle $x space y space z$ est orienté positivement si x < y < z.

Un _k-simplexe_ est alors un simplexe de dimension k. Dès lors, on peut définir un _complexe simplicial_ $K$ comme un ensemble de $n$ simplexes d'un espace affine tels que :
- Toutes les faces d'un simplexe de $K$ sont également dans $K$.
- L'intersection de deux simplexes de $K$ non disjoints doit être une face commune.

On note $k$ la dimension d'un complexe simplicial $K$ si $k$ est la plus grande dimension des simplexes de $K$.

#figure(
  image("images/cech.png"),
  caption: [Exemples de complexes simpliciaux de dimension 0 (en rouge), 1 (en bleu, uniquement les simplexes de dimension 1) et 2 (en vert, uniquement les simplexes de dimension 2).],
)

On appelle _filtration_ une suite de complexes simpliciaux croissante pour l'inclusion.

$ emptyset = K_0 subset.eq ... subset.eq K_p = K $

#figure(
  image("images/filtration.png"),
  caption: [Exemple de filtration, tiré de@PH_resource_coverage],
)

== Topologie

L'homologie persistante est une méthode de topologie algébrique qui permet de mesurer la forme des données. Elle est basée sur l'homologie, qui est une notion mathématique permettant de détecter les trous dans un espace topologique.

Cette idée nous permet de définir les groupes d'homologie persistante. Ces groupes sont des invariants topologiques qui permettent de mesurer la forme des données. Ils sont définis à partir d'une filtration de complexes simpliciaux.

Finalement, nous voulons détecter les trous $k$ dimensionnels, soit les $k$-trous. Pour cela, on va collecter les $k$-simplexes autour de ces trous. Par exemple : 
- un $0$-trou est délimité par un sommet dans une composante connexe, ainsi la présence de 0-trou détecte les déconnexions dans $K$
- un $1$-trou est délimité par des arêtes autour de lui, détectant ainsi les boucles dans $K$.\
  _Exemple : un triangle sans face._
- un $2$-trou est délimité par des triangles autour de lui, détectant ainsi les zones de vide dans $K$.\
  _Exemple : l'intérieur d'une pyramide._

Dans la suite on va définir formellement les outils mathématiques pour détecter ces trous.

=== Homologie

Un espace topologique $K$ est un couple $(E, T)$ où $E$ est un ensemble et $T$ une topologie sur $E$, c'est à dire un ensemble de parties de $E$ que l'on appelle ouverts de $K$ qui vérifie les propriétés suivantes :
1. $E$ et $emptyset$ appartiennent à $T$.
2. Toute union quelconque d'ouverts est un ouvert, c'est à dire si $(O_i)_(i in I)$ est une famille d'éléments de T, indexée par un ensemble quelconque $I$ alors 
$ union_(i in I) O_i in T $
3. Toute intersection finie d'ouverts est un ouvert, c'est à dire si $O_1, ..., O_n$ sont des éléments de $T$ alors
$ O_1  sect ... sect O_n in T $

Un _homomorphisme_ est simplement un morphisme de groupes.

Un _homéomorphisme_ est une application bijective continue d'un espace topologique et dont l'inverse est continue. Dans ce cas, les deux espaces sont dits _homéomorphes_.

Un _invariant topologique_ est une propriété d'un espace topologique qui reste inchangée par homéomorphisme.

Soit $K$ un espace topologique. _L'homologie_ de $K$ est un ensemble d'invariants topologiques de $K$ représentés par ses _groupes d'homologie_ 

$ H_0(K), H_1(K), H_2(K), ... $

Où le $k$-ième groupe d'homologie $H_k (K)$ décrit les trous de dimension $k$ dans $K$.

Une _chaîne complexe_ de $C(K)$, ou _complex de chaîne_ est une séquence de groupes abéliens ou de modules $C_0, C_1, C_2, ...$ relié par des homomorphismes $diff_n : C_n -> C_(n-1)$ nommés _opérateurs limite_. On a 

$ ...  overbrace(->, diff_(n+1)) C_n overbrace(->, diff_(n)) C_(n-1) overbrace(->, diff_(n-1)) ... -> C_2 overbrace(->, diff_(2)) C_1 overbrace(->, diff_(1)) C_0 overbrace(->, diff_(0)) {0} $

Où ${0}$ est le groupe trivial et $C_i equiv {0}$ pour $i < 0$. De plus, il faut que $diff_n o diff_(n+1) = 0$ l'application nulle pour tout $n$.

On pose $B_n (X) = "Im"(diff_(n+1))$ l'ensemble des limites et $Z_n (X) = "Ker"(diff_n)$ l'ensemble des cycles.

(Paragraphe sur les groupes normaux)

On peut alors définir le $k$-ième groupe d'homologie de $K$ comme le quotient des cycles par les limites :

$ H_k (K) = (Z_k (K))/ (B_k (K)) $

Les éléments de $H_k (K)$ sont appelés les _classes d'homologie_ de $K$. Chaque classe d'homologie est une classe d'équivalence sur plusieurs cycles et deux cycles de la même classe d'homologie sont dits homologues.

=== Homologie simplicial

On considère une $k$-chaîne, soit est une combinaison linéaire de $k$-simplexes sur $K$. On note $C_k$ le groupe abélien libre dont les générateurs sont les simplexes de X orientés en $k$ dimension. La relation entre les faces induit une notion de bordure pour la $k$-chaîne : l'application _des limites_ $diff_k : C_k (K) -> C_(k-1)(K)$ est définit sur chaque simplexe $sigma = [v_0, ..., v_k]$ par 

$ diff_k (sigma) =  sum_(i=0)^k (-1)^i [v_0, ..., v_(i-1), v_(i+1), ..., v_k] $

Considérée comme nulle si $k = 0$. Ce comportement sur les générateurs induit un homomorphisme sur tout $C_k$, en effet soit $c in C_k$, l'écrire comme la somme des générateurs $ c = sum_(sigma_i in K_k) m_i sigma_i $
Où $K_k$ est l'ensemble des k-complexes de $K$ et les $m_i$ sont des coefficients de l'anneau $C_k$ (Généralement des entiers). Puis définir :

$ diff_k(c) = sum_(sigma_i in K_k) m_i diff_k (sigma_i) $

La dimension de la $k$-ième homologie de $K$ s'avère être le nombre de $k$-trous dans $K$. 

On a $H_k (K) approx.eq underbrace(ZZ_2 plus.circle ... plus.circle ZZ_2,beta_k "fois") $

Le $k$-nombre de Betti de $K$ $beta_k$ est le rang du $k$-ième groupe d'homologie de $K$. Intuitivement il s'agit du nombre de $k$-trous dans $K$.


#bibliography("bibliography.yml", style: "american-physics-society")