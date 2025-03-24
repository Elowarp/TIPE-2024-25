#import "@preview/cetz:0.3.4"
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

#set par(justify: true)
#show table.cell.where(x:0): strong
#show table.cell.where(y:0): strong

#let cadre(name, content, color) = {
    rect(
        fill: rgb("#ffffff"),
        stroke: (paint: rgb(color), thickness:1pt),
        inset: 8pt,
        width: 100%,
        radius: 2pt,
        [*#name :*\ #content],
    )
}

#let def(content) = {
    cadre("Définition", content, "#000000")
}

#let th(name, content) = {
    cadre("Théorème " + name, content, "#0F084B")
}

// Constantes 
#let ensPts = "X" 

#align(center, text(17pt)[
    *TIPE : Etude de couvertures de réseaux de métros, application de l'homologie persistante*
])

#align(center)[Elowan\
#link("mailto:elowarp@gmail.com")
]

#outline()

#align(center)[
    *Abstract*

    Nous nous proposons ici d'étudier les différentes disparités dans les réseaux métropolitains de plusieurs grandes villes, nous voulons détecter les zones spatiales les plus en déficit de transports en commun. Pour cela, nous adopterons une approche analytique utilisant la topologie, _l'homologie persistante_.
]
= Définitions <Definitions>

_Note: Est ce que c'est considéré comme du plagiat ? (Extrait notice XENS : Les textes et figures sont l’œuvre du candidat. Les reproductions et les copies ne sont pas acceptées, tout plagiat (« action d’emprunter un passage de tout auteur en les donnant pour sien. ») est une forme de contrefaçon et constitue un délit et donc une fraude, il est susceptible d’être sanctionné en tant que telle suivant la procédure disciplinaire.)_


#grid(
    columns: (47%, 47%),
    column-gutter: 6%,
    [L'exemple suivant est tiré de @PH_invitation.
        
    Prenons comme exemple le style artistique du pointillisme. Lorsque l'on regarde une oeuvre d'art, comme le tableau de Seurat en @Seurat, nous voyons bien plus qu'un grand nombre de points, nous voyons des formes et des objets. D'une discrétisation, nous en faisons un _continuum_ de formes. 
    
    L'homologie persistante est une _méthode de calcul_  qui, à partir d'une discrétisation, cherche à fournir un descriptif des caractéristiques que l'on pourrait distinguer de cet ensemble. 
    
    // D'un ensemble de points dans un espace muni d'une distance, nous n'allons pas chercher à reconstituer la forme qu'aurait eu l'objet discrétisé mais plutôt d'avoir des caractéristiques de celui ci. 
    ],
    [
        #figure(
            image("../images/Georges_Seurat.jpg", width: 100%),
            caption: "La scène à la Grande Jatte - Printemps (Georges Seurat, 1888)"
        )<Seurat>
    ]

)

Nous chercherons ici seulement à caractériser les "trous" dans un espace, afin de détecter les trous de couverture dans un réseau métropolitain, étant défini ici comme un espace de $bb(R)^2$ où chaque point correspond à une station de métro. 

== Constructions géométriques

Afin d'utiliser l'homologie persistante, nous devons définir certaines notions géométriques, nous noterons dans la suite #ensPts l'ensemble des points de $bb(R)^2$ que l'on considère.

// Voyons désormais comment formaliser cela, commençons par définir tous nos outils : 

// #def[
//     Un _simplexe_ est l'analogue du triangle à $k$ dimensions, c'est l'objet le plus simple qu'il est possible de définir en $k$ dimensions.
// ]

#def[
    Un simplexe $sigma$ de dimension $k$ correspond à l'enveloppe convexe de $k+1$ points de #ensPts non inclus dans un même sous-espace affine de dimension $k-1$.

    On définit un simplexe de dimension 0 comme un point de #ensPts.
]

Par exemple, un simplexe de dimension 1 est un segment et un simplexe de dimension 3 est un trièdre.

_Remarque : On dit que $sigma_i$ est une face de $sigma_j$ si et seulement si $sigma_j subset sigma_i$ et la dimension de $sigma_i$ est strictement supérieure à celle de $sigma_j$._

#figure(
    cetz.canvas({
        import cetz.draw: *
        scale(2)
        let p1 = (-1, 0, 0)
        let p2 = (0.75, 0, 0)
        let p3 = (0.25, 0, 1)
        let t = (0, 1, 0)
        let trièdre = {
            line(p1, t, p2, p1, name:"face1")
            line(p1, t, p3, p1, name:"face2", fill: red.transparentize(75%))
            line(p1, t, stroke: 3pt)
            line(p2, t, p3, p2, name:"face3", )
        }
        trièdre
    }),
caption: [Ce trièdre est un simplexe $sigma$ de dimension 3, où le triangle rouge représente un simplexe $tau$ de dimension 2 mais aussi une face de $sigma$ dans le sens de la remarque précédente. Notons que l'arête en gras est un simplexe de dimension 1 et est une face de $sigma$ et $tau$.]
)


#def[
    Un _complexe simplicial_ est un ensemble de simplexes.
]

// On donne une représentation de plusieurs complexes simplicaux @Filtration_ex.

// Afin de pouvoir caractériser des changements, il faut pouvoir définir deux états différents à comparer, une filtration permet alors d'ordonner ces différents états de façon à en étudier les changements. 

#def[
    Une _filtration_ est une application qui à un entier $i$ associe un complexe simplicial $K_i$ de telle sorte que $forall j in [|0, i|]$, $K_j subset K_i$
]

Observons sur @Filtration_ex les trois notions précédemment définies. Chaque $K_i$ est un complexe simplicial, la suite $(K_i)_(i=0)^3$ est une filtration et tous les points, segments et faces (ici en rouge) sont des simplexes de dimension 0, 1 et 2 respectivement. 

#figure(
    cetz.canvas({
        import cetz.draw: *
        scale(1.2)
        let lines((x, y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "9": line(p0, p1, p2, fill: red.transparentize(75%), name:"9"), 
                "4": line(p0, p1, name:"4"), 
                "5": line(p1, p2, name:"5"), 
                "6": line(p2, p3, name:"6"), 
                "7": line(p3, p0, name:"7"), 
                "8": line(p0, p2, name:"8"), 
            )
        }

        let pts((x,y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "0": (p0, "south-west"), 
                "1": (p1, "south-west"), 
                "2": (p2, "north-east"), 
                "3": (p3, "north-east")
            )
        }

        let draw_point(name, (p, anchor), drawtext:true) = {
            circle(p, radius: (0.05), fill: black, name:name)
            if drawtext {
                if anchor == "north-east"{
                    content(name, anchor:anchor, pad(right: .7em, text($p_name$, size:16pt)))
                } else {
                    content(name, anchor:anchor, pad(left: .7em, text($p_name$, size:16pt)))
                }

            }
        }

        let draw_line(id, l, drawtext:true) = {
            l
            if drawtext {
                if (id > 8) {
                    content(str(id), anchor: "mid", text($tau_id$, size:16pt))
                } else {
                    set-style(content: (frame: "circle", stroke:none, fill:white,))
                    content(str(id), anchor: "mid", text($sigma_id$, size:16pt))
                }
            }
        }

        group(name: "K_0", {
            let origin = (0, 0)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v))
            }
        })

        group(name: "K_1", {
            let origin = (3.5, 0)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }

            for i in range(4, 7) {
                draw_line(i, lines(origin).at(str(i)))
            }

        })

        group(name: "K_2", {
            let origin = (7, 0)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }

            for i in range(4,7) {
                draw_line(i, lines(origin).at(str(i)), drawtext: false)
            }

            draw_line(7, lines(origin).at("7"))
            draw_line(8, lines(origin).at("8"))

        })

        group(name: "K_3", {
            let origin = (10.5, 0)

            for i in range(8, 3, step:-1) {
                draw_line(i, lines(origin).at(str(i)), drawtext: false)
            }

            draw_line(9, lines(origin).at("9"))
            
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }
        })

        for i in range(4){
            content(("K_",str(i),".south").join(""), 
                anchor:"north", 
                pad(top: 2em, text($K_#i$, size:16pt))
            )
        }
        

    }),
    caption: [Représentation d'une filtration où $K_0 subset K_1 subset K_2 subset K_3$ et où chaque simplexe à été nommé : $p_i$ pour les simplexes de dimension 0; $sigma_i$ pour la dimension 1 et $tau_i$ pour la dimension 2.]
)<Filtration_ex>

// Grâce à cette definition, nous sommes capables de quantifier les changements d'un complexe à l'autre, comme la création de cycles (dans $K_2$, il apparait un cycle $(0,1,2,3, 0)$ après avoir rajouté $(0,3)$ à $K_1$) ou la destruction de composantes connexes (dans $K_0$, tous les simplexes 0D sont dans des composantes connexes différentes alors que dans $K_1$ ils sont tous dans la même, on a "tué" les composantes connexes de 1, 2 et 3).

Nous observons qu'une filtration permet d'ajouter une notion de "temporalité" dans un ensemble de points. Nous sommes capable de noter quels événements surviennent entre deux complexes à la suite, par exemple l'apparition d'un cycle entre $K_1$ et $K_2$ (le cycle (0,1,2,3)) ou l'apparition d'un simplexe de dimension 2 entre $K_2$ et $K_3$ (la face rouge).

On introduit de plus un ordre total $<$ sur l'ensemble des simplexes d'une filtration. 

#def[
    Soient une filtration $K_0 subset K_1 subset ... subset K_p$ et deux simplexes $sigma in K_i$ et $tau in K_j$, on a 

    $ cases("soit" i < j, "sinon" i=j "et" sigma "est une face de" tau) => sigma < tau $

    Si aucun des deux cas n'est réalisé alors le choix de l'ordre entre les deux simplexes est arbitraire.
]

Observons sur @Filtration_ex l'indexation des simplexes suivant l'ordre précédemment défini : on a bien $sigma_8$ et $sigma_7$ qui sont plus grand au sens de < que tous les autres $sigma_i$ et $p_i$ parce qu'ils apparaissent plus tard dans la filtration. Si $sigma_8$ était apparu dans $K_3$, l'ordre aurait toujours été respecté puisque $sigma_8$ est une face de $tau_9$.

Il y a un problème : nous voulons analyser un ensemble de points discrets, et non pas une filtration déjà existante, il nous faut alors créer une filtration depuis un ensemble de points. Cela va se faire via une construction incrémentale de complexes simpliciaux via les complexes de Vietoris-Rips pondérés. Ainsi d'après @PH_resource_coverage :

#def[
    Soient un ensemble $X = (x_i)_(i=0)^n$ de points associés à des poids $(w_i)_(i=0)^n$ et une distance $d$, on définit le complexe simplicial pondéré de Vietoris-Rips au rang $r$, noté $V_r (X, d)$, comme l'ensemble des simplexes $(x_i_0, ..., x_i_k)$ tels que : 
    #align(center)[
        $
        cases(
            forall j in [|0, k|]\, w_i_j < r,
            forall (j,l) in [|0, k|]^2\, d(x_i_j, x_i_k) + w_i_j + w_i_k < 2r
        )
        $
    ]  
]

Ainsi plus on augmente $r$, plus le complexe possède des simplexes, on en donne une représentation @VR. (_Note : Remarque par M.Ni pas comprise_)

#figure(
    image("../images/cech.png"),
    caption: [Construction d'un complexe simplicial avec un $r$ grandissant de gauche à droite]
) <VR>

Ici, $r$ est le rayon des boules bleues, et un simplexe est considéré dès lors que les boules associées à ces sommets se rencontrent.

Pour définir formellement des "trous", nous devons définir les opérateurs de bords. Ainsi selon @CoursHomologie :

#def[
    On définit un complexe de chaînes comme la donnée d'une suite 
    
    $ ... attach(arrow, t:delta_(k+2)) C_(k+1) attach(arrow, t:delta_(k+1)) C_k attach(arrow, t:delta_(k)) C_(k-1) attach(arrow, t:delta_(k-1)) ... $

    Où chaque $C_k$ est un groupe abélien généré par les $k$-simplexes de #ensPts et $delta_k$ est une morphisme de groupes tel que $delta_k compose delta_(k+1) = 0$
    
    On appelle $delta_k$ un _opérateur de bords_.

    //A des liens avec les varités, ça peut etre cool de savoir mais pas obligatoire i guess
]

#def[
    On définit alors les _classes d'homologie de dimension $k$_ comme le groupe de Ker$(delta_k)$ quotienté par Im$(delta_(k+1))$:

    $ H_k = "Ker"(delta_k) \/ "Im"(delta_(k+1)) $

    Celle ci représente les "trous" en dimension $k$
]

On peut voir que $H_0$ représente des points connectés, $H_1$ représente un trou qui est entouré par un chemin fermé de points connectés ($K_2$ dans @Filtration_ex par exemple) et $H_2$ représenterait par exemple une pyramide d'intérieur vide. 

Pour notre usage, nous voulons calculer $H_0$ les temps moyens pour se rendre à une station de métros et $H_1$ qui représente les zones critiques de couverture du réseau.

// Ainsi, grâce à ces définitions, nous sommes capables, depuis un ensemble $X = {x_i}$ de points fini de poids $(w_i)_i$, de créer une filtration et de l'étudier afin de trouver $H_1$ qui représentent, pour notre cas d'usage, les zones critiques de couverture.

// == Interprétation de résultats via l'homologie persistante 

// Nous voulons pouvoir détecter les classes d'homologie 1D, c'est à dire les "trous", dans la couverture d'un réseau de transports d'une grande ville. Pour cela, l'homologie persistante nous propose plusieurs affichages graphique afin de rendre compte de ces caractéristiques, nous nous concentrerons sur une seule : _le diagramme de persistance (PD)_

// Ce diagramme retrace les "événements" qui sont arrivés lors du parcours d'une filtration. Prenons par exemple le diagramme de persistance associé à la filtration de @Filtration_ex

// #figure(
//     image("../images/pd_filtration_ex.png", width:50%),
//     caption: [Diagramme de persistance de @Filtration_ex, tiré de@PH_resource_coverage]
// ) <PD_ex>

// Les chiffres en abscisse et en ordonnée représente l'indice d'un complexe simplicial dans la filtration. En particulier, l'abscisse donne l'indice du simplexe où la classe d'homologie est apparue et l'ordonnée celle où elle disparait (si elle disparait, si elle ne disparait pas, elle à une ordonnée de $+infinity$).

// Ainsi, nous remarquons qu'en $K_0$ il y a la naissance de 4 classes 0D (4 composantes connexes) là où en $K_1$ il n'y en a plus qu'une (d'où la mort de 3 d'entre elle en ordonnée 1, et la dernière qui ne meurt jamais, en $+infinity$). De plus, il y a la création d'un cycle d'intérieur vide (classe 1D) en $K_2$ et que celui ci est complétement rempli en $K_4$.

// En reprenant ce qui a été dit précédemment, les classes 0D représentent les composantes connexes vivantes au cours de la filtration, c'est à dire des sous ensembles de stations reliées entre elles. Ainsi un simplexe tuant une homologie 0D (liaison de deux composantes connexes) au rang $r$ représente le fait qu'il est possible à partir de ce rang de se rendre d'une station à l'autre sans prendre le métro.

// Ces simplexes tueurs vont créer des homologies 1D à partir d'un certain moment : des zones entre nos stations reliées. Comprenant qu'il est plus simple de passer par les stations de metros pour aller à une autre station du cycle plutot que de se déplacer au centre de la zone.

// C'est exactement ce qui nous intéresse : ces zones décritent par les cycles représentent les zones critiques où les personnes sont le moins bien deservies par le réseau de métros, où c'est le plus compliqué de se rendre à une station de métro en prenant en compte le déplacement vers la station (pied ou voiture) et le temps d'attente moyen en station. 

= Les données <Data>

== Sources

Ne voulant pas me baser sur des villes factices, j'ai décidé de trouver des sources pouvant me fournir des informations sur les stations de metros de plusieurs grandes villes de France comme Toulouse ou Marseille.

Ainsi, toutes les informations relatives aux stations de metros ainsi que les temps de passages sont trouvables sur le site du gouvernement : #link("https://transport.data.gouv.fr").

Ces informations servent à définir nos points et notre pondération, en revanche elles ne permettent pas d'obtenir les distances entre les stations, pour cela nous utiliserons alors #link("https://www.geoapify.com") qui nous permet d'estimer des temps de trajet en voiture et à pied.

// De plus, pour la distance nous avons besoin du nombre d'habitants par arrondissement, pour cela nous utiliserons : #link("implémenté sans cette donnée")

== Construction des informations importantes <Construction>

Définissons dès lors nos objets :

#def[
    Un point $x_i$, représentant une station de métro, est défini par deux données, celle de la position géographique (latitude/longitude) ainsi que son poids $w_i$. Le poids $w_i$ est égal à la moyenne du temps d'attente entre deux métros en station $x_i$ sur une semaine entière.
]

Les temps de passage des metros en station étant plus ou moins constant sur la semaine, il est cohérent d'utiliser une moyenne.

// De plus, dans un premier temps, nous définissons similairement à @PH_resource_coverage une distance non symétrique entre deux stations $x$ et $y$ :

// $ tilde(d)(x,y) = min(t_"marche" (x,y), t_"voiture" (x,y)) $

// Avec $t_"marche" (x,y)$ le temps qu'il faut en marchant pour aller de la station x à la station y, de même en voiture pour $t_"voiture" (x,y)$.

On définit la distance similairement à @PH_resource_coverage: 

// #def[
//     On définit la distance entre deux stations de métros $x$ et $y$ comme :
//     $ d(x,y) = 1 / P (P(x)tilde(d)(x,y) + P(y)tilde(d)(y,x)) $
//     En notant $P(x)$ la population de l'arrondissement de la station $x$, et $P = P(x) + P(y)$ la somme des population des arrondissement de $x$ et $y$.

//     _(Temporairement P(x) = 1 $forall x$, donc $d = tilde(d)$)_
// ]
#def[
    On définit la distance entre deux stations de métros $x$ et $y$ comme :
    $ d(x,y) = 1 / 2 (min(t_"marche" (x,y), t_"voiture" (x,y)) + min(t_"marche" (y,x), t_"voiture" (y,x))) $
]

Ainsi en revenant aux boules des complexes simplicaux de Vietoris-Rips, elle modélise le coût temporel d'un trajet "porte à porte" en utilisant le métro. 

= Méthode

Pour trouver les zones critiques, nous utiliserons la méthode de l'homologie persistante décrite dans @PH_resource_coverage (dans le cas de notre réseau de métros). Celle ci se décompose en 3 étapes :

- Transformation de l'ensemble de $bb(R)^2$ des stations de métros $x_i$ de poids $w_i$ en une filtration;
- Création et réduction de la matrice de bordure (définie dans la suite);
- Récupération des simplexes "tueurs" de classes d'homologies

On suppose que l'étape une, malgré la difficulté technique qu'elle pose à implémenter, est déjà réalisée suivant la #link(<Definitions>, "section I").

// Notre but final étant de créer un diagramme de persistance, nous devons réussir à convertir notre filtration en celui ci, cela se fait grâce au théorème centrale dû à Crawley-Boevey @PH_invitation. En définissant un espace filtré comme la donnée d'un espace topologique ainsi qu'une de ses filtration, on a :

// Depuis cette filtration, nous voulons obtenir les classes d'homologies, c'est donc le théorème suivant qui justifie entièrement cette recherche.

Ainsi à partir de cette filtration, nous pouvons obtenir les classes d'homologie grâce au théorème qui suit :

#th(
    "des facteurs invariants",
    [
    D'après @PH_invitation et @ComputingPH, chaque $H_k$ est isomorphe à une somme directe d'espaces filtrés associés à une certaine famille d'intervalles, définie d'une unique manière. Cette famille d'intervalles est appelé un _code barre_.
    ]
)

Informatiquement, selon @PH_roadmap, on calcule ce code barre en créant une matrice de bordure $B$ après avoir défini un ordre total sur les simplexes respectant les propriétés énoncées #link(<Definitions>, "section I").

#def[
    On définit la matrice de bordure, associée à un ordre total $sigma_0 < ... < sigma_(n-1)$ sur tous les simplexes $(sigma_i)_(i=0)^(n-1)$ de la filtration, suivant :
    $ forall (i,j) in [|0, n-1|]^2, B[i][j] = cases("1 si" sigma_i "est une face de" sigma_j, "0 sinon") $
]<BordureDef>

_Note : D'après @ComputingPH, $B$ peut être vu comme la matrice de $delta_1$ dans la base associés à $C_1$._

Un exemple d'une telle matrice est donnée en @Bordure.

Après avoir calculé $B$, nous voulons la _réduire_ en code barre, dans le sens où l'on peut interpréter correctement les valeurs de cette matrice avec la filtration (grâce au théorème précédent). Le terme de _réduction_ fait ici référence à la réduction de $B$ en forme normale de Smith. Dans notre cas, ce résultat s'interprète comme l'attribution à chaque simplexe de la naissance d'_au plus_ une classe d'homologie. Nous pouvons observer ce résultat en @BordureReduite.

Cet algorithme de réduction est nommé _standard algorithm_ et est décrit dans @PH_roadmap par, en posant $"low"_B (j) = max({i in [|0, n-1|], B[i][j] != 0}) in bb(N) union {-1}$ :

```python
StandardAlgorithm(B)
    for j in [|0, n-1|]:
        while (il existe i < j avec low_B(i) = low_B(j)):
            ajouter colonne i de B à colonne j
```

Comparons alors nos deux matrices, sur l'exemple de la filtration de @Filtration_ex (Les cases vident remplacent les zeros pour plus de lisibilité), avec ici notre ordre total sur les simplexes :

#figure(
    cetz.canvas({
        import cetz.draw: *
        scale(1.2)
        let lines((x, y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "9": line(p0, p1, p2, fill: red.transparentize(75%), name:"9"), 
                "4": line(p0, p1, name:"4"), 
                "5": line(p1, p2, name:"5"), 
                "6": line(p2, p3, name:"6"), 
                "7": line(p3, p0, name:"7"), 
                "8": line(p0, p2, name:"8"), 
            )
        }

        let pts((x,y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "0": (p0, "south-west"), 
                "1": (p1, "south-west"), 
                "2": (p2, "north-east"), 
                "3": (p3, "north-east")
            )
        }

        let draw_point(name, (p, anchor), drawtext:true) = {
            circle(p, radius: (0.05), fill: black, name:name)
            if drawtext {
                if anchor == "north-east"{
                    content(name, anchor:anchor, pad(right: .7em, text($p_name$, size:16pt)))
                } else {
                    content(name, anchor:anchor, pad(left: .7em, text($p_name$, size:16pt)))
                }

            }
        }

        let draw_line(id, l, drawtext:true) = {
            l
            if drawtext {
                if (id > 8) {
                    content(str(id), anchor: "mid", text($tau_id$, size:16pt))
                } else {

                    content(str(id), anchor: "mid", text($sigma_id$, size:16pt))
                }
            }
        }

        group(name: "K_3", {
            let origin = (0, 0)

            draw_line(9, lines(origin).at("9"))
            for i in range(8, 3, step:-1) {
                draw_line(i, lines(origin).at(str(i)), drawtext: true)
            }

            
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }
        })

        content(("K_3.south"), 
                anchor:"north", 
                pad(top: 2em, text($K_3$, size:16pt))
            )
    }),
    caption: [Rappel du nommage des simplexes]
)

En regardant la matrice $overline(B)$, nous remarquons que l'opération de réduction à permis d'avoir la ligne low sans répétion de nombre positifs, autrement dit, on accorde la naissance d'un simplexe à un unique autre simplexe. Ainsi le simplexe 1 donne naissance au simplexe 4, 8 donne naissance à 9 et 7 donne naissance à 10. 

Par exemple, si $"low"_overline(B) (j) = i != -1$ alors on a une paire de simplexe $(sigma_i, sigma_j)$ telle que l'apparition de $sigma_i$ fait apparaitre une nouvelle classe d'homologie. Et au contraire, $sigma_j$ va la _tuer_ en apparaissant. Prenons comme exemple la filtration @Filtration_ex : dans $K_0$, le point 1 cause l'apparition d'une classe dans $H_0$ cependant l'apparition du simplexe (0,3) dans $K_2$ tue la classe de 1 dans $H_0$ mais créer une nouvelle classe dans $H_1$ (car elle crée un cycle).

#grid(
    columns: (45%, 45%),
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
        ) <BordureReduite>
    ]
)

// Regardons la 1ere ligne (celle du 0) de la matrice $B$, il y a trois 1 : en effet le simplexe 0 est à la naissance des simplexes 4, 7 et 8 (en tant qu'extrémité). De même pour donner naissance à 10, il a fallut avoir les simplexes 6, 7 et 8, d'où la présence d'un 1 dans la colonne 10 des lignes 6, 7 et 8. 

En revanche si $"low"_overline(B) (j) = -1$ alors l'apparition de $sigma_j$ crée une classe d'homologie : s'il existe $k$ tel que $"low"_overline(B) (k) = j$ on est dans le cas précédent, sinon la classe d'homologie n'est jamais tuée.

// C'est depuis cette matrice $overline(B)$ réduite que l'on construit notre diagramme de persistance comme il suit : 

// #def[
//     Un diagramme de persistance PD est un multi-ensemble de $overline(bb(R)^2)$ tel que depuis une matrice réduite $overline(B)$ on ait, en notant $"dg"(sigma) = l$ si $sigma$ apparait à partir de $K_l$ : 

//     $ "PD" = {("dg"(i), "dg"(j)), "tels que low"_overline(B) (j) = i""} union {("dg"(i), +infinity), "tels que low"_overline(B) (i) = -1} $
// ]

// C'est grâce à cette définition que nous arrivons au diagramme de persistance donnée en @PD_ex

C'est depuis cette matrice que nous sommes capables de déterminer $H_0$ ainsi que $H_1$, et donc de générer des représentations graphiques comme montré en @CarteResultat

= Résultats et conclusion

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

On comprend que globalement il faut 200s (soit 3m20s) pour quelqu'un de se rendre d'une station à une autre (le minimum en temps entre la voiture et la marche) ce qui est effectivement cohérent avec la réalité. Les temps des classes 1D ici présent montre le temps moyen de trajet entre les deux stations les plus éloignées d'un même cycle. Donc par exemple pour Toulouse, il faudra en moyenne 318s (5min20s) pour rejoindre une station depuis les zones les moins biens deservies.

// #align(center)[#grid(
//     columns: (50%, 50%),
//     [
//         #figure(
//             image("../../Code/images/pd_toulouse.png", width:90%, alt:"Toulouse"),
//             caption: [Toulouse]
//         )
//     ],  
//     [
//         #figure(
//             image("../../Code/images/pd_marseille.png", width:90%, alt:"Marseille"),
//             caption: [Marseille]
//         )
//     ],
// )]

// Ainsi via ces diagrammes de persistance, on remarque que les stations de metros pour ces deux villes sont égalements réparties en terme de temps de trajet entre deux stations (les classes 0D en rouge). Mais l'interprétation des diagrammes de persistance est assez limité dans notre cas, analysons alors directement les classes 1D se faisant tuer directement sur une carte : 

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
            )<CarteResultat>
        ]
    )
]

Les triangles ici représentés montrent les zones où il est le plus difficile de rejoindre une station de métro. Pour les triangles les plus gros, il peut être cohérent de croire qu'il est difficile de se rendre à ces stations de métros. En revanche, pour les plus petits cela est plus dur.

Ce sont des zones où il ne circule que très peu de voitures entre les stations de métros, en effet ces zones sont uniquement pietonnes donc la distance parcourue à durée égale est necéssairement plus long à pied qu'en voiture. Donc la distance prise par notre algorithme est celle relevant de la marche à pied, d'où les zones _a priori_ plus petites que celles discutées plus haut.  

Nous pouvons observer le plus gros problème de cette méthode : la méthode est pertinente pour le développement d'un réseau autre que le métropolitain (réseau de bus, par exemple). En effet, on remarque que les zones critiques sont entre les lignes de metros dessinées, mais jamais en bout de ligne, là où pourtant la disponibilité des métros est plus faible que dans l'hypercentre des villes. 

Mais via cette interprétation là, je n'arrive pas à expliquer la présence du triangle au sud de Toulouse, parce qu'il est en bout de ligne, même si effectivement le temps de trajet est haut dans cette région de la ville.

Ainsi, cette méthode d'analyse peut être pertinente lors d'une simulation pour la création ou l'amélioration prévue d'un réseau, afin de détecter les zones qui seront le plus en besoin avec le réseau imaginé, mais ne permet pas d'établir un tracé _optimal_ d'une ligne de métro pour satisfaire le plus de monde.


#bibliography("../bibliography.yml", style: "american-physics-society")