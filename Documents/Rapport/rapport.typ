#import "@preview/diverential:0.2.0"
#import math
#set heading(numbering: "I.1.1")
#set text(
  font: "New Computer Modern"
)

#set document(
  title: "TIPE : Persistance homologique"
)

#set page(
    header: context [
        #set align(right)
        #set text(9pt)
        Etude de couvertures de réseaux de métros

    ],
    footer: context [
        #set align(center)
        #counter(page).display(
            "1 sur 1",
            both: true
        )
    ]
)

#show table.cell.where(x:0): strong
#show table.cell.where(y:0): strong

#let cadre(name, content, color) = {
    rect(
        fill: rgb("#ffffff"),
        stroke: (paint: rgb(color), thickness:0.5pt),
        inset: 8pt,
        width: 100%,
        radius: 2pt,
        [*#name :*\ #content],
    )
}

#let def(content) = {
    cadre("Définition", content, "#000000")
}

#let th(content) = {
    cadre("Théorème", content, "#0F084B")
}

#align(center, text(17pt)[
    *TIPE : Etude de couvertures de réseaux de métros, application de l'homologie persistante*
])

#align(center)[Elowan\
#link("mailto:elowarp@gmail.com")
]

#outline()

#align(center)[
    *Abstract*

    Nous nous proposons ici d'étudier les différentes disparités dans les réseaux métropolitain de plusieurs grandes villes, dans le sens où l'on veut détecter les zones spatiales les plus en besoin de dévéloppement de transports en commun. Cela grâce une approche utilisant de l'analyse topologique, l'homologie persistante, qui se veut dans notre cas être une approche plus pertinente que l'étude des distances spaciales entre les stations de métros.
]
= Définitions <Definitions>

L'exemple suivant est tiré de@PH_invitation.

#grid(
    columns: (47%, 47%),
    column-gutter: 6%,
    [Prenons comme exemple le style artistique du pointillisme. Lorsque l'on regarde une oeuvre d'art, comme le tableau de Seurat @Seurat, nous voyons bien plus qu'un grand nombre de points, nous voyons des formes et des objets. D'une discrétisation, nous en faisons un _continuum_ de formes. L'homologie persistante va chercher à former cela.
    
    D'un ensemble de points dans un espace muni d'une distance, nous n'allons pas chercher à reconstituer la forme qu'aurait eu l'objet discrétisé mais plutôt d'avoir des caractéristiques de celui ci. ],
    [
        #figure(
            image("../images/Georges_Seurat.jpg", width: 100%),
            caption: "La scène à la Grande Jatte - Printemps (Georges Seurat, 1888)"
        )<Seurat>
    ]

)

Nous chercherons ici seulement des caractérisations de "trous" dans un espace, afin de détecter les trous de couverture dans un réseau métropolitain, réseau transformé en un espace de $bb(R)^2$ où chaque point correspond à une station de métro. 

== Constructions géométriques

Voyons désormais comment formaliser cela, commençons par définir tous nos outils : 

#def[
    Un _simplexe_ est l'analogue du triangle à $k$ dimensions, c'est l'objet le plus simple qu'il est possible de définir en $k$ dimensions.
]

Par exemple, un simplexe en dimension 0 est un point, en dimension 1 c'est un segment, en dimension 3 c'est une pyramide et ainsi de suite.

_Remarque : On dit que $sigma_i$ est une face de $sigma_j$ si $sigma_j$ fait parti des bords du simplexe défini par $sigma_i$, donc $sigma_i$ est nécessairement de dimension supérieure de 1 à $sigma_j$. Un point est donc une face d'un segment (en particulier, une extrémité)._

On a donc naturellement la définition suivante :

#def[
    Un _complexe simplicial_ est un ensemble de simplexes.
]

On donne une représentation de plusieurs complexes simplicaux @Filtration_ex.

Afin de pouvoir caractériser des changements, il faut pouvoir définir deux états différents à comparer, une filtration permet alors d'ordonner ces différents états de façon à en étudier les changements. 

#def[
    Une _filtration_ est une application qui à un entier $i$ associe un complexe simplicial $K_i$ de telle sorte que $forall j in [|0, i|]$ le complexe simplicial $K_j$ est inclus dans $K_i$
]

#figure(
    image("../images/filtration.png"),
    caption: [Représentation d'une filtration où $K_0 subset K_1 subset K_2 subset K_3 subset K_4$, tiré de@PH_resource_coverage]
)<Filtration_ex>

Grâce à cette definition, nous sommes capable de quantifier les changements d'un complexe à l'autre, comme la création de cycles (dans $K_2$, il apparait un cycle $(0,1,2,3)$ après avoir rajouté $(0,3)$ à $K_1$) ou la destruction de composantes connexes (dans $K_0$ tous les simplexes 0D sont dans des composantes connexes différentes alors que dans $K_1$ ils sont tous dans la même, on a "cassé" les composantes connexes de 1, 2 et 3).

Le problème que nous avons est que nous voulons analyser un ensemble de point discret, et non pas une filtration déjà existante, il nous faut alors créer une filtration depuis un ensemble de points. Cela va se faire via une construction incrémentale de complexes simplicials, par soucis d'implémentation, nous choisissons comme dans@PH_resource_coverage les complexes de Vietoris-Rips pondérés : 

#def[
    Soient un ensemble $X = (x_i)_(i=0)^n$ de points de poids $(w_i)_(i=0)^n$ et une distance $d$, on définit le complexe simplicial pondéré Vietoris-Rips au rang $r$ $V_r^w (X, bb(R)^2, d)$ comme l'ensemble des simplexes $(x_i_0, ..., x_i_k)$ tels que : 
    #align(center)[
        - $forall j in [|0, k|], w_i_k < r$
        - $forall (j,l) in [|0, k|]^2, d(x_i_j, x_i_k) + w_i_j + w_i_k < 2t$
    ]  
]

Ainsi plus on augmente $r$, plus le complexe possède des simplexes, on en donne une représentation @VR.

#figure(
    image("../images/cech.png"),
    caption: [Construction d'un complexe simplicial avec un $r$ grandissant de gauche à droite]
) <VR>

Donc $r$ est le rayon des boules bleues, et un simplexe est considéré dès lors que les boules associées à ces sommets se rencontrent.

#def[
    On définit une _classe d'homologie de dimension k (kD)_ comme la représentation d'un trou en dimension $k$.

    //A des liens avec les varités, ça peut etre cool de savoir mais pas obligatoire i guess
]

Ainsi une classe d'homologie 0D représente des points connectés, une classe d'homologie 1D représente un trou qui est entouré par un chemin fermé de points connectés ($K_2$ dans @Filtration_ex par exemple) et une classe d'homologie 2D représenterait par exemple une pyramide d'intérieur vide. 

Ainsi, grâce à ces définitions, nous sommes capables, depuis un ensemble $X = {x_i}$ de points fini de poids $(w_i)_i$, de créer une filtration et de l'étudier afin de trouver les classes d'homologie 1D qui représentent pour nous les zones critiques de couverture.

== Interprétation de résultats via l'homologie persistante 

Nous voulons pouvoir détecter les classes d'homologie 1D, c'est à dire les "trous", dans la couverture d'un réseau de transports d'une grande ville. Pour cela, l'homologie persistante nous propose plusieurs affichages graphique afin de rendre compte de ces caractéristiques, nous nous concentrerons sur une seule : _le diagramme de persistance (PD)_

Ce diagramme retrace les "événements" qui sont arrivés lors du parcours d'une filtration. Prenons par exemple le diagramme de persistance associé à la filtration de @Filtration_ex

#figure(
    image("../images/pd_filtration_ex.png", width:50%),
    caption: [Diagramme de persistance de @Filtration_ex, tiré de@PH_resource_coverage]
) <PD_ex>

Les chiffres en abscisse et en ordonnée représente l'indice d'un complexe simplicial dans la filtration. En particulier, l'abscisse donne l'indice du simplexe où la classe d'homologie est apparue et l'ordonnée celle où elle disparait (si elle disparait, si elle ne disparait pas, elle à une ordonnée de $+infinity$).

Ainsi, nous remarquons qu'en $K_0$ il y a la naissance de 4 classes 0D (4 composantes connexes) là où en $K_1$ il n'y en a plus qu'une (d'où la mort de 3 d'entre elle en ordonnée 1, et la dernière qui ne meurt jamais, en $+infinity$). De plus, il y a la création d'un cycle d'intérieur vide (classe 1D) en $K_2$ et que celui ci est complétement rempli en $K_4$.

En reprenant ce qui a été dit précédemment, les classes 0D représentent les composantes connexes vivantes au cours de la filtration, c'est à dire des sous ensembles de stations reliées entre elles. Ainsi un simplexe tuant une homologie 0D (liaison de deux composantes connexes) au rang $r$ représente le fait qu'il est possible à partir de ce rang de se rendre d'une station à l'autre sans prendre le métro.

Ces simplexes tueurs vont créer des homologies 1D à partir d'un certain moment : des zones entre nos stations reliées. Comprenant qu'il est plus simple de passer par les stations de metros pour aller à une autre station du cycle plutot que de se déplacer au centre de la zone.

C'est exactement ce qui nous intéresse : ces zones décritent par les cycles représentent les zones critiques où les personnes sont le moins bien deservies par le réseau de métros, où c'est le plus compliqué de se rendre à une station de métro en prenant en compte le déplacement vers la station (pied ou voiture) et le temps d'attente moyen en station. 

= Méthode

De ce qui précède nous pouvons en extraire une méthode générale pour notre problème. Celle ci se décompose en 5 étapes :

- Récupération de l'ensemble des stations, leurs poids, et leurs distances entre elles
- Transformation de ces informations en une filtration
- Création de la matrice de bordure
- Réduction de la matrice de bordure
- Construction du diagramme de persistance

La première étape étant développée en @Data, nous supposerons dans la suite de cette section avoir un espace muni d'une distance $((x_i)_i, d)$ et où chaque $x_i$ admet $w_i$ pour pondération.

À l'étape 2, nous allons créer une filtration grâce à la définition donnée @Definitions.

Notre but final étant de créer un diagramme de persistance, nous devons réussir à convertir notre filtration en celui ci, cela se fait grâce au théorème centrale dû à Crawley-Boevey@PH_invitation. En définissant un espace filtré comme la donnée d'un espace topologique ainsi qu'une de ses filtration, on a :

#th[
    Tout espace vectoriel filtré de dimension finie est isomorphe à la somme directe des espaces filtrés associés à une certaine famille d'intervalles, uniquement définie. Cette famille d'intervalle est appelé un "code barre".

    //Intéressant pour comprendre pq on fait tt ça
]

Informatiquement, cela revient à créer une matrice de bordure $B$ comme défini plus bas, en créant un ordre total sur les simplexes du complexe.

Cet ordre total est de telle sorte que la face d'un simplexe précède le simplexe et tout simplexe de $K_j$ précède tous les simplexes de $K_i$ tel que $i < j$.

#def[
    On définit la matrice de bordure, associée à un ordre total $sigma_0 < ... < sigma_(n-1)$ sur tous les simplexes $(sigma_i)_(i=0)^(n-1)$ de la filtration, comme $forall (i,j) in [|0, n-1|]^2$,
    $ B[i][j] = cases("Vrai si " sigma_i "est une face de " sigma_j, "Faux sinon") $
]

Un exemple d'une telle matrice est donnée en @Bordure.

Après avoir calculé $B$, nous voulons la "réduire" en "code barre", dans le sens où l'on peut interpréter correctement les valeurs de cette matrice avec la filtration (Grâce au théorème énoncé plus tôt). Cet algorithme est nommé _standard algorithm_ et est décrit dans@PH_roadmap par, en posant $"low"_B (j) = max({i in [|0, n-1|], B[i][j] != 0}) in bb(N) union {-1}$ :

```python
StandardAlgorithm(B)
    for j in [|0, n-1|]:
        while (il existe i < j avec low_B(i) = low_B(j)):
            ajouter colonne i de B à colonne j
```

Comparons alors nos deux matrices, sur l'exemple de la filtration de @Filtration_ex (Les cases vident remplacent les zeros pour plus de lisibilité), avec ici notre ordre total sur les simplexes :

#align(center)[#image(width:80pt,"../images/filtration_inj.png")]

#grid(
    columns: (48%, 48%),
    gutter: 4%,
    [
        #figure(
            table(columns : 12, rows:11,  
            [],  [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10],
            [0], [], [], [], [], [1], [], [], [1], [1], [], [],
            [1], [], [], [], [], [1], [1], [], [], [], [], [],
            [2], [], [], [], [], [], [1], [1], [], [1], [], [],
            [3], [], [], [], [], [], [], [1], [1], [], [], [],
            [4], [], [], [], [], [], [], [], [], [], [1], [],
            [5], [], [], [], [], [], [], [], [], [], [1], [],
            [6], [], [], [], [], [], [], [], [], [], [], [1],
            [7], [], [], [], [], [], [], [], [], [], [], [1],
            [8], [], [], [], [], [], [], [], [], [], [1], [1],
            [9], [], [], [], [], [], [], [], [], [], [], [],
            [10],[], [], [], [], [], [], [], [], [], [], [],
            [low], [-1], [-1], [-1], [-1], [1], [2], [3], [3], [2], [8], [8]
            ),
            caption:"Matrice B non réduite"
        ) <Bordure>
    ],
    [
        #figure(
            table(columns : 12, rows:11,
            [],  [0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10],
            [0], [], [], [], [], [1], [], [], [], [], [], [],
            [1], [], [], [], [], [1], [1], [], [], [], [], [],
            [2], [], [], [], [], [], [1], [1], [], [], [], [],
            [3], [], [], [], [], [], [], [1], [], [], [], [],
            [4], [], [], [], [], [], [], [], [], [], [1], [1],
            [5], [], [], [], [], [], [], [], [], [], [1], [1],
            [6], [], [], [], [], [], [], [], [], [], [], [1],
            [7], [], [], [], [], [], [], [], [], [], [], [1],
            [8], [], [], [], [], [], [], [], [], [], [1], [],
            [9], [], [], [], [], [], [], [], [], [], [], [],
            [10],[], [], [], [], [], [], [], [], [], [], [],
            [low], [-1], [-1], [-1], [-1], [1], [2], [3], [-1], [-1], [8], [7]
            ),
            caption:[Matrice $overline(B)$, la matrice B après reduction]
        )
    ]
)

Regardons la 1ere ligne (celle du 0) de la matrice $B$, il y a trois 1 : en effet le simplexe 0 est à la naissance des simplexes 4, 7 et 8 (en tant qu'extrémité). De même pour donner naissance à 10, il a fallut avoir les simplexes 6, 7 et 8, d'où la présence d'un 1 dans la colonne 10 des lignes 6, 7 et 8. 

En regardant la matrice $overline(B)$, nous remarquons que l'opération de réduction à permis d'avoir la ligne low sans répétion de nombre positifs, autrement dit, on accorde la naissance d'un simplexe à un unique autre simplexe. Ainsi le simplexe 1 donne naissance au simplexe 4, 8 donne naissance à 9 et 7 donne naissance à 10. 

Ainsi si $"low"_overline(B) (j) = i != -1$ alors on a une paire de simplexe $(sigma_i, sigma_j)$ tel que l'apparition de $sigma_i$ cause l'apparition d'une classe d'homologie et $sigma_j$ va, en apparaissant, la tuer. Par exemple, dans le complexe $K_0$, la naissance de 1 cause la création d'une classe 0D alors que l'apparition de 4 "tue" cette classe en création un cycle, donc en créant une classe 1D. 

En revanche si $"low"_overline(B) (j) = -1$ alors son apparition cause la naissance d'une classe d'homologie, s'il existe $k$ tel que $"low"_overline(B) (k) = j$ on est dans le cas précédent, si k n'existe pas alors la classe d'homologie n'est jamais tuée.

C'est depuis cette matrice $overline(B)$ réduite que l'on construit notre diagramme de persistance comme il suit : 

#def[
    Un diagramme de persistance PD est un multi-ensemble de $overline(bb(R)^2)$ tel que depuis une matrice réduite $overline(B)$ on ait, en notant $"dg"(sigma) = l$ si $sigma$ apparait à partir de $K_l$ : 

    $ "PD" = {("dg"(i), "dg"(j)), "tels que low"_overline(B) (j) = i""} union {("dg"(i), +infinity), "tels que low"_overline(B) (i) = -1} $
]

C'est grâce à cette définition que nous arrivons au diagramme de persistance donnée en @PD_ex


= Les données <Data>

== Sources

Ne voulant pas me baser sur des villes factices, j'ai alors décidé de trouver des sources pouvant me fournir des informations sur les stations de metros de plusieurs grandes villes de France comme Toulouse ou Marseille.

Ainsi toutes les informations relatives aux stations de metros ainsi que les temps de passages sont trouvables via le site du gouvernement : #link("https://transport.data.gouv.fr").

Ces informations servent à définir nos points et notre pondération (voir @Construction), en revanche elles ne permettent pas d'obtenir les distances entre les stations, pour cela nous utiliserons alors #link("https://www.geoapify.com") qui nous renvoie depuis des coordonnées geographiques des temps de trajets en voiture et à pied.

// De plus, pour la distance nous avons besoin du nombre d'habitants par arrondissement, pour cela nous utiliserons : #link("implémenté sans cette donnée")

== Construction des informations importantes <Construction>

Définissons dès lors nos objets :

#def[
    Un point $x_i$, représentant une station de métro, est défini par deux données, celle de la position géographique (latitude/longitude) ainsi que son poids $w_i$. Le poids $w_i$ est égal à la moyenne du temps d'attente entre deux métros en station $x_i$ sur une semaine entière.
]

Les temps de passage des metros en station étant plus ou moins constant sur la semaine, il est cohérent d'utiliser une moyenne.

De plus, dans un premier temps, nous définissons similairement à@PH_resource_coverage une distance non symétrique entre deux stations $x$ et $y$ :

$ tilde(d)(x,y) = min(t_"marche" (x,y), t_"voiture" (x,y)) $

Avec $t_"marche" (x,y)$ le temps qu'il faut en marchant pour aller de la station x à la station y, de même en voiture pour $t_"voiture" (x,y)$.

On définit finalement la distance (qui cette fois est symétrique): 

// #def[
//     On définit la distance entre deux stations de métros $x$ et $y$ comme :
//     $ d(x,y) = 1 / P (P(x)tilde(d)(x,y) + P(y)tilde(d)(y,x)) $
//     En notant $P(x)$ la population de l'arrondissement de la station $x$, et $P = P(x) + P(y)$ la somme des population des arrondissement de $x$ et $y$.

//     _(Temporairement P(x) = 1 $forall x$, donc $d = tilde(d)$)_
// ]
#def[
    On définit la distance entre deux stations de métros $x$ et $y$ comme :
    $ d(x,y) = 1 / 2 (tilde(d)(x,y) + tilde(d)(y,x)) $
]

Ainsi en revenant aux boules des complexes simplicaux de Vietoris-Rips, elle relate du coût en temps de prendre le métro. En particulier, $d(x,y)$ est une estimation de la moyenne de temps de trajet d'un individu de la station $x$ allant à $y$ et du trajet de $y$ à $x$.

Nous pouvons alors analyser les réseaux de transport metropolitain français.

= Résultats et conclusion

J'ai choisi de baser ce tipe sur les réseaux métropolitain de Toulouse et Marseille, justifiant mon choix par la présence de contacts dans ces différentes villes pour attester la cohérence de mes résultats.

#figure(
    table(
        columns: (auto, auto, auto, auto),
        inset: 10pt,
        align: horizon,
        table.header(
        [*Ville*], [*Dimension*], [*Médiane*], [*Variance*],
        ),
        table.cell(rowspan: 2)[Toulouse], 
            "0D Homologie", "211.00s", "22.27s",
            "1D Homologie", "318.00s", "58.62s",

        table.cell(rowspan: 2)[Marseille], 
            "0D Homologie", "184.00s", "23.57s",
            "1D Homologie", "223.50s", "10.5s",

    ),
    caption: [Tableau récapitulant les médianes ainsi que la variance des temps de mort des classes holomogiques pour chaque ville.]

)

On comprend que globalement il faut 200s (soit 3m20 environ) pour quelqu'un de se rendre d'une station à une autre (le minimum en temps entre la voiture et la marche) ce qui est effectivement cohérent avec la réalité. Les temps des classes 1D ici présent montre le temps moyen de trajet entre les deux stations les plus éloignées d'un même cycle. Donc par exemple pour marseille, il faudra en moyenne 318s (5min20s) pour rejoindre une station depuis les zones les moins biens deservies.

#align(center)[#grid(
    columns: (50%, 50%),
    [
        #figure(
            image("../../Code/images/pd_toulouse.png", width:90%, alt:"Toulouse"),
            caption: [Toulouse]
        )
    ],  
    [
        #figure(
            image("../../Code/images/pd_marseille.png", width:90%, alt:"Marseille"),
            caption: [Marseille]
        )
    ],
)]

Ainsi via ces diagrammes de persistance, on remarque que les stations de metros pour ces deux villes sont égalements réparties en terme de temps de trajet entre deux stations (les classes 0D en rouge). Mais l'interprétation des diagrammes de persistance est assez limité dans notre cas, analysons alors directement les classes 1D se faisant tuer directement sur une carte : 

#align(center)[
    #grid(
        columns: (50%, 50%),
        [
            #figure(
                image("../../Code/images/toulouse.png", width:100%),
                caption:"Carte de toulouse"
            )
        ],
        [
            #figure(
                image("../../Code/images/marseille.png", width: 100%),
                caption:"Carte de Marseille"
            )
        ]
    )
]

Les triangles ici représentés montrent les zones où il est le plus difficile pour se rendre à une station de métro. Pour les triangles les plus gros, il peut être cohérent de croire qu'il est difficile de se rendre à ces stations de métros en revanche pour les plus petits comme à la Canebière à Marseille cela est plus dur.

Ce sont des zones où il ne circule que très peu de voitures entre les stations de métros, en effet ces zones sont uniquement pietonnes donc la distance parcourue à durée égale est necéssairement plus long à pied qu'en voiture. Donc la distance prise par notre algorithme est celle relevant de la marche à pied, d'où les zones _a priori_ plus petites que celles discutées plus haut.  

Nous pouvons observer le plus gros problème de cette méthode : la méthode est pertinente pour le développement d'un réseau autre que le métropolitain (réseau de bus, par exemple). En effet, on remarque que les zones critiques sont entre les lignes de metros dessinées, mais jamais en bout de ligne, là où pourtant la disponibilité des métros est plus faible que dans l'hypercentre des villes. 

Mais via cette interprétation là, je n'arrive pas à expliquer la présence du triangle au sud de Toulouse, parce qu'il est en bout de ligne, même si effectivement le temps de trajet est haut dans cette région de la ville.

Ainsi, cette méthode d'analyse peut être pertinente lors d'une simulation pour la création ou l'amélioration prévue d'un réseau, afin de détecter les zones qui seront le plus en besoin avec le réseau imaginé, mais ne permet pas d'établir un tracé _optimal_ d'une ligne de métro pour satisfaire le plus de monde.


#bibliography("../bibliography.yml", style: "american-physics-society")