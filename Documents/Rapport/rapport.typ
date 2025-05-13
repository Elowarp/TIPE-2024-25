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
        Étude de couvertures de réseaux de métros

    ],
    footer: context [
        #set align(center)
        #counter(page).display(
            "1 sur 1",
            both: true
        )
    ]
)

#show ref: it => {
    let hd = heading
    let elmt = it.element 
    if elmt != none and elmt.func() == hd {
        link(elmt.location(), "section " + numbering(elmt.numbering, ..counter(hd).at(elmt.location())))
    } else {
        it
    }
}

#set par(justify: true)
#show table.cell.where(x:0): strong
#show table.cell.where(y:0): strong
#set figure.caption(separator: " : ")

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

#let code(source, title:"Func", lang:"python") = {
    rect(stroke: (left: gray + 0.2em))[
        #text(title, font:"DejaVu Sans Mono", size:0.8em)\
        #raw(source, lang:lang)
    ]
}

#show raw.line: it => {
  text(fill: gray)[#it.number]
  h(1em)
  it.body
}

// Constantes 
#let ensPts = $X$
#let mrs = "Ville A"
#let tls = "Ville B"

#align(center, text(17pt)[
    *TIPE : Étude de couvertures de réseaux de métros, application de l'homologie persistante et optimisation*
])

#align(center)[Elowan H\
// #link("mailto:elowarp@gmail.com")
]

#outline(
    title: [Sommaire]
)

#align(center)[*Résumé*]
Nous nous proposons ici d'étudier les différentes disparités dans les réseaux métropolitains de plusieurs grandes villes, nous allons détecter les zones spatiales les plus en déficit de transports en commun. Pour cela, nous adopterons une approche analytique utilisant la topologie : _l'homologie persistante_.

= Définitions <Definitions>

L'homologie persistante est une _méthode de calcul_  qui, à partir d'une discrétisation, cherche à fournir une description des caractéristiques que l'on pourrait distinguer de cet ensemble. 
    
Nous chercherons ici seulement à caractériser les "trous" dans un espace, afin de détecter les trous de couverture dans un réseau métropolitain, ici modélisé comme un nuage de points de $bb(R)^2$, dont chaque élément est une station de métro.

Afin d'utiliser l'homologie persistante, nous devons définir certaines notions géométriques, nous noterons dans la suite #ensPts l'ensemble des points de $bb(R)^2$ que l'on considère.

// Voyons désormais comment formaliser cela, commençons par définir tous nos outils : 

// #def[
//     Un _simplexe_ est l'analogue du triangle à $k$ dimensions, c'est l'objet le plus simple qu'il est possible de définir en $k$ dimensions.
// ]

#def[
    Un simplexe $sigma$ de dimension $k$ (ou _$k$-simplexe_) correspond à l'enveloppe convexe de $k+1$ points de #ensPts non inclus dans un sous-espace affine de dimension $k-1$.

    On définit un simplexe de dimension 0 comme un point de #ensPts.
]

Par exemple, un simplexe de dimension 1 est un segment et un simplexe de dimension 3 est un trièdre.

_Remarque : On dit que $sigma_i$ est une face de $sigma_j$ si et seulement si $sigma_i subset sigma_j$ et la dimension de $sigma_i$ $dim(sigma_i)$ est égale à $dim(sigma_j) - 1$._

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
caption: [Ce trièdre est un simplexe $sigma$ de dimension 3, où le triangle rouge représente un simplexe $tau$ de dimension 2 mais aussi une face de $sigma$ dans le sens de la remarque précédente. Notons que l'arête en gras est un simplexe de dimension 1 et est une face de $sigma$ et de $tau$.]
)


#def[
    Un _complexe simplicial_ est un ensemble de simplexes. 
]

// On donne une représentation de plusieurs complexes simplicaux @Filtration_ex.

// Afin de pouvoir caractériser des changements, il faut pouvoir définir deux états différents à comparer, une filtration permet alors d'ordonner ces différents états de façon à en étudier les changements. 

#def[
    Une _filtration_ est une application qui à un entier $i$ associe un complexe simplicial $K_i$ de sorte que : 
    
    $ forall j in [|0, i|] text(", ") K_j subset K_i $
]

Observons sur la @Filtration_ex les notions précédemment définies. Chaque $K_i$ est un complexe simplicial, la suite $(K_i)_(i=0)^3$ est une filtration et tous les points, segments et faces (ici en rouge) sont des simplexes de dimension 0, 1 et 2 respectivement. 

#figure(
    cetz.canvas({
        import cetz.draw: *
        set-style(text: (size:10pt))
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
                    content(name, anchor:anchor, pad(right: .7em, text($p_name$)))
                } else {
                    content(name, anchor:anchor, pad(left: .7em, text($p_name$)))
                }

            }
        }

        let draw_line(id, l, drawtext:true) = {
            l
            if drawtext {
                if (id > 8) {
                    content(str(id), anchor: "mid", text($tau_id$))
                } else {
                    set-style(content: (frame: "circle", stroke:none, fill:white,))
                    content(str(id), anchor: "mid", text($sigma_id$))
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
                pad(top: 1em, text($K_#i$))
            )
        }
        

    }),
    caption: [Représentation d'une filtration où $K_0 subset K_1 subset K_2 subset K_3$ et où chaque simplexe a été nommé : $p_i$ pour les simplexes de dimension 0, $sigma_j$ pour la dimension 1 et $tau_k$ pour la dimension 2.]
)<Filtration_ex>

// Grâce à cette definition, nous sommes capables de quantifier les changements d'un complexe à l'autre, comme la création de cycles (dans $K_2$, il apparait un cycle $(0,1,2,3, 0)$ après avoir rajouté $(0,3)$ à $K_1$) ou la destruction de composantes connexes (dans $K_0$, tous les simplexes 0D sont dans des composantes connexes différentes alors que dans $K_1$ ils sont tous dans la même, on a "tué" les composantes connexes de 1, 2 et 3).

Nous observons qu'une filtration permet d'ajouter une notion de "temporalité" dans un ensemble de points. Nous sommes capable de noter quels événements surviennent entre deux complexes à la suite, par exemple l'apparition d'un cycle entre $K_1$ et $K_2$ (le cycle $(sigma_4, sigma_5, sigma_6, sigma_7)$) ou l'apparition d'un simplexe de dimension 2 entre $K_2$ et $K_3$ (la face rouge).

On introduit de plus un ordre total $prec.curly.eq$ sur l'ensemble des simplexes d'une filtration. 

#def[
    Soient une filtration $K_0 subset K_1 subset ... subset K_p$ et l'ensemble $S$ de tous les simplexes apparaissant dans la filtration. On indice $S$ de sorte que pour tout $sigma_i$ et $sigma_j$ de $S$: 

    $ cases("Si" sigma_i in K_k_i "et" sigma_j in K_k_j "avec" k_i < k_j,"Sinon si" sigma_i "est une face de" sigma_j, ) => i < j $

    Si aucun des deux cas n'est réalisé alors le choix de l'ordre entre les deux simplexes est arbitraire. 
    
    On définit donc l'ordre total $prec.curly.eq$ tel que $sigma_i prec.curly.eq sigma_j <=> i<=j$
]

Observons sur la @Filtration_ex l'indexation des simplexes suivant l'ordre précédemment défini : les simplexes $sigma_8$ et $sigma_7$ sont plus grands au sens de $prec.curly.eq$ que tous les autres $sigma_i$ et $p_i$ parce qu'ils apparaissent plus tard dans la filtration. De plus, si $sigma_8$ était apparu dans $K_3$, l'ordre aurait toujours été respecté puisque $sigma_8$ est une face de $tau_9$.

Il y a un problème : nous voulons analyser un ensemble de points discrets, et non une filtration déjà existante, il nous faut alors créer une filtration depuis un ensemble de points. Nous faisons cela via une construction incrémentale de complexes simpliciaux avec les complexes de Vietoris-Rips pondérés. Ainsi d'après @PH_resource_coverage :

#def[
    Soient un ensemble $#ensPts = (x_i)_(i=0)^n$ de points associés à des poids $(w_i)_(i=0)^n$ et une distance $d$, on définit le complexe simplicial pondéré de Vietoris-Rips au rang $r$, noté $V_r (#ensPts, d)$, comme l'ensemble des simplexes $(x_i_0, ..., x_i_k)$ tels que : 
    #align(center)[
        $
        cases(
            forall j in [|0, k|]\, w_i_j < r,
            forall (j,l) in [|0, k|]^2\, d(x_i_j, x_i_l) + w_i_j + w_i_l < 2r
        )
        $
    ]  
]

Ainsi plus on augmente $r$, plus le complexe possède des simplexes, on en donne une représentation @VR. Pour chaque $r$ qui augmente le nombre de simplexes du complexe simplicial, nous ajoutons $V_r (#ensPts, d)$ à la filtration que l'on est en train de créer.

#figure(
    image("../images/cech.png"),
    caption: [Construction d'un complexe simplicial avec un $r$ grandissant de gauche à droite, tiré de @PH_resource_coverage]
) <VR>

Ici, $r$ est le rayon des boules bleues, et un simplexe est considéré dès lors que les boules associées à ces sommets se rencontrent.

Pour définir formellement des "trous", nous devons définir les opérateurs de bords. Ainsi selon @CoursHomologie :

#def[
    On définit un _complexe de chaînes_ comme la donnée d'une suite 
    
    $ ... attach(arrow, t:delta_(k+2)) C_(k+1) attach(arrow, t:delta_(k+1)) C_k attach(arrow, t:delta_(k)) C_(k-1) attach(arrow, t:delta_(k-1)) ... $

    Où chaque $C_k$ est un groupe abélien libre qui a pour base les $k$-simplexes de #ensPts et $delta_k$ est une morphisme de groupes tel que $delta_k compose delta_(k+1) = 0$
    
    On appelle $delta_k$ un _opérateur de bords_.

    //A des liens avec les varités, ça peut etre cool de savoir mais pas obligatoire i guess
]

#def[
    On définit alors les _classes d'homologie de dimension $k$_ comme le groupe de Ker$(delta_k)$ quotienté par Im$(delta_(k+1))$:

    $ H_k = "Ker"(delta_k) \/ "Im"(delta_(k+1)) $

    Celle-ci représente les "trous" en dimension $k$.
]

On peut voir que $H_0$ représente les composantes connexes de $#ensPts$, $H_1$ représente un trou qui est entouré par un chemin fermé de points connectés (comme le cycle $(sigma_4, sigma_5, sigma_6, sigma_7)$ dans $K_2$ dans @Filtration_ex par exemple) et $H_2$ représenterait par exemple un trièdre d'intérieur vide. 

_Exemple à faire_

Pour notre usage, nous voulons calculer $H_0$, les temps moyens pour se rendre à une station de métros, et $H_1$ qui représente les zones critiques de couverture du réseau.

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

#[
    #show link: underline

    On choisit de se baser uniquement sur des vraies villes, que l'on nommera #mrs et #tls par la suite, pour tester notre approche. De plus, toutes les informations relatives aux stations de métros ainsi que les temps de passages sont trouvables sur #link("https://transport.data.gouv.fr").

    Ces informations servent à définir nos points et notre pondération, en revanche elles ne permettent pas d'obtenir les distances entre les stations, pour cela nous utiliserons alors #link("https://www.geoapify.com")[geoapify] qui nous permet d'estimer des temps de trajet en voiture et à pied.

]

== Points et distances <Construction>

Définissons dès lors nos objets :

#def[
    Un point $x_i$, représentant une station de métro, est défini par la donnée de sa position géographique (latitude/longitude) ainsi que son poids $w_i$. Le poids $w_i$ est égal à la moyenne du temps d'attente entre deux métros en station $x_i$ sur une semaine entière.
]

Les temps de passage des métros en station étant plus ou moins constant sur la semaine, il est cohérent d'utiliser une moyenne.

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
    On définit la distance entre deux stations de métro $x$ et $y$ comme :
    $ d(x,y) = 1 / 2 (min(t_"marche" (x,y), t_"voiture" (x,y)) + min(t_"marche" (y,x), t_"voiture" (y,x))) $
]

Ainsi en revenant aux boules des complexes simplicaux de Vietoris-Rips, la distance modélise le coût temporel d'un trajet "porte à porte" entre les stations (en voiture ou à pied).

= Méthode

Pour trouver les zones critiques, nous utiliserons la méthode de l'homologie persistante décrite dans @PH_resource_coverage (dans le cas de notre réseau de métros). Celle ci se décompose en 3 étapes :

- Transformation de l'ensemble de $bb(R)^2$ des stations de métros $x_i$ de poids $w_i$ en une filtration;
- Création et réduction de la matrice de bordure (définie dans la suite);
- Récupération des simplexes "tueurs" de classes d'homologies

On suppose que l'étape une, malgré la difficulté technique qu'elle pose à implémenter, est déjà réalisée suivant la @Definitions.

// Notre but final étant de créer un diagramme de persistance, nous devons réussir à convertir notre filtration en celui ci, cela se fait grâce au théorème centrale dû à Crawley-Boevey @PH_invitation. En définissant un espace filtré comme la donnée d'un espace topologique ainsi qu'une de ses filtration, on a :

// Depuis cette filtration, nous voulons obtenir les classes d'homologies, c'est donc le théorème suivant qui justifie entièrement cette recherche.

Ainsi à partir de cette filtration, nous pouvons obtenir les classes d'homologie grâce au théorème qui suit :

#th(
    "des facteurs invariants",
    [
    D'après @PH_invitation et @ComputingPH, il existe un unique ensemble ${d_1, ..., d_p}$ d'éléments de $H_k$ définis à des inversibles près, tel que :
    $ H_k (X) tilde.eq plus.circle.big_(i=1)^p P_k (X) \/ d_i P_k (X) $

    en notant $P_k (#ensPts)$ l'ensemble des parties à $k+1$ éléments de #ensPts, formant donc un complexe simplicial constitué uniquement de $k$-simplexes. Cet ensemble est appelé _code barre_ de $H_k$
    ]
)
_A reprendre_
// _Note : Je ne suis pas sûr de comprendre ce que je manipule notamment les types du quotient... Les extraits sont ici : #underline(link("https://fr.wikipedia.org/wiki/Th%C3%A9or%C3%A8me_des_facteurs_invariants#A-modules_de_type_fini","Source")) et @annexe_inv. _

Informatiquement, selon @PH_roadmap, on calcule ce code barre en créant une matrice de bordure $B$ après avoir défini un ordre total sur les simplexes respectant les propriétés énoncées @Definitions.

#def[
    On définit la matrice de bordure, associée à un ordre total $sigma_0 prec.curly.eq ... prec.curly.eq sigma_(n-1)$ sur tous les simplexes $(sigma_i)_(i=0)^(n-1)$ de la filtration, suivant :
    $ forall (i,j) in [|0, n-1|]^2, B[i][j] = cases("1 si" sigma_i "est une face de" sigma_j, "0 sinon") $
]<BordureDef>

_Note : D'après @ComputingPH, $B$ peut être vu comme la somme des matrice des $delta_k$ dans la base concaténée des bases des $C_k$._

Un exemple d'une telle matrice est donnée en @Bordure.

Après avoir calculé $B$, nous voulons la _réduire_ à un code barre, dans le sens où par lecture matricielle, grâce au théorème précédement, nous pouvons donner un temps de vie à chaque simplexe par l'attribution d'un unique antécédent à chacun de ceux-ci. Le terme de _réduction_ fait ici référence à la réduction de $B$ en forme normale de Smith. Nous pouvons observer ce résultat en @BordureReduite.

Cet algorithme de réduction est nommé _standard algorithm_ et est décrit dans @PH_roadmap par, en posant $n$ le nombre de simplexes et $"low"_B (j) = max({i in [|0, n-1|], B[i][j] != 0}) in bb(N) union {-1}$ :

#code("for j allant de 0 à n-1:
    while (il existe i < j avec low[i] = low[j]):
        ajouter colonne i de B à colonne j modulo 2",
    title: "StandardAlgorithm(B)"
)

_Notons que cet algorithme a pour complexité temporelle $O(n^3)$ au pire._ 

Comparons alors nos deux matrices, sur l'exemple de la filtration de la @Filtration_ex (Les cases vides remplacent les zeros pour plus de lisibilité et les colonnes/lignes vides ont été omises), avec ici notre ordre total sur les simplexes :

#grid(
    columns: (50%, 45%),
    gutter: 5%,
    [#figure(
        cetz.canvas({
            import cetz.draw: *
            scale(1)
            set-style(text: (size:10pt))
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
                        content(name, anchor:anchor, pad(right: .2em, text($p_name$)))
                    } else {
                        content(name, anchor:anchor, pad(left: .3em, text($p_name$)))
                    }

                }
            }

            let draw_txt(id, dx, dy) = {
                content(str(id), anchor: "mid", 
                    [#move(dx:dx, dy:dy, text($sigma_id$))]
                )
            }
            let draw_line(id, l, drawtext:true) = {
                l
                if drawtext {
                    if (id > 8) {
                        content(str(id), anchor: "mid", text($tau_id$))
                    } else {
                        if id == 4 {
                            draw_txt(id, 6pt, -5pt)
                        } else if id == 5 {
                            draw_txt(id, -6pt, -6pt)
                        } else if id == 6 {
                            draw_txt(id, -6pt, 4pt)
                        } else if id == 7 {
                            draw_txt(id, 6pt, 4pt)
                        } else {
                            draw_txt(id, 0pt, 3pt)
                        }
                    }
                }
            }

            group(name: "K_3", {
                let origin = (0, 0)

                for i in range(9, 3, step:-1) {
                    draw_line(i, lines(origin).at(str(i)))
                }

                for i in range(4) {
                    let (p, v) = pts(origin).at(str(i))
                    draw_point(str(i), (p, v))
                }
            })
        }),
        caption: [Rappel du nommage des simplexes ($p_i$ pour la dimension 0, $sigma_j$ pour la dimension 1, $tau_k$ pour la dimension 2)]
    )   
    ],
    [
        En regardant la matrice $overline(B)$, nous remarquons que l'opération de réduction à permis d'avoir la ligne low sans répétion de nombre positifs, autrement dit, on accorde la naissance d'un simplexe à un unique autre simplexe. Ainsi le simplexe 1 donne naissance au simplexe 4, 8 donne naissance à 9 et 7 donne naissance à 10. 
    ]
)

#set table(inset: (right:1em, left: 1em))

#grid(
    columns: (50%, 50%),
    gutter: 0%,
    [
        #figure(
            table(columns : 9,
            table.header(
                table.cell(colspan:9, [*Enfants*], stroke: none),
            ),
            table.cell(
                rowspan:10,
                align: horizon,
                stroke: none,
                rotate(-90deg, reflow: true)[
                *Parents*
            ]),
            [],  [4], [5], [6], [7], [8], [9], 
            table.cell(
                rowspan:10,
                align: horizon,
                stroke: none,
                rotate(-90deg, reflow: true)[]
            ),
            [0], [1], [], [], [1], [1], [], 
            [1], [1], [1], [], [], [], [], 
            [2], [], [1], [1], [], [1], [], 
            [3], [], [], [1], [1], [], [], 
            [4], [], [], [], [], [], [1], 
            [5], [], [], [], [], [], [1], 
            [6], [], [], [], [], [], [], 
            [7], [], [], [], [], [], [], 
            [8], [], [], [], [], [], [1],
            table.cell(colspan: 9, [], stroke:none),
            table.cell(stroke:none, []), [*low*], [*1*], [*2*], [*3*], [*3*], [*2*], [*8*], table.cell(stroke:none, [])
            ),
            caption:[Matrice $B$]
        ) <Bordure>        
    ],
    [
        #figure(
            table(columns : 9,
            table.header(
                table.cell(colspan:9, [*Enfants*], stroke: none),
            ),
            table.cell(
                rowspan:10,
                align: horizon,
                stroke: none,
                rotate(-90deg, reflow: true)[
                *Parents*
            ]
            ),
            [],  [4], [5], [6], [7], [8], [9],
            table.cell(
                rowspan:10,
                align: horizon,
                stroke: none,
                rotate(-90deg, reflow: true)[]
            ),
            [0], [1], [], [], [], [], [], 
            [1], [1], [1], [], [], [], [], 
            [2], [], [1], [1], [], [], [], 
            [3], [], [], [1], [], [], [], 
            [4], [], [], [], [], [], [1], 
            [5], [], [], [], [], [], [1], 
            [6], [], [], [], [], [], [], 
            [7], [], [], [], [], [], [], 
            [8], [], [], [], [], [], [1], 
            table.cell(colspan: 9, [], stroke:none),
            table.cell(stroke:none, []), [*low*], [*1*], [*2*], [*3*], [-1], [-1], [*8*], table.cell(stroke:none, [])
            ),
            caption:[Matrice $overline(B)$, $B$ après réduction]
        ) <BordureReduite>
    ]
)

Par exemple, si $"low"_overline(B) (j) = i != -1$ alors on a une paire de simplexes $(sigma_i, sigma_j)$ telle que l'apparition de $sigma_i$ fait apparaitre une nouvelle classe d'homologie. Et au contraire, $sigma_j$ va la _tuer_ en apparaissant. Prenons comme exemple la filtration @Filtration_ex : dans $K_2$, $sigma_7$ cause l'apparition d'une classe dans $H_1$ (car elle crée un cycle) cependant l'apparition du simplexe $tau_10$ dans $K_4$ tue la classe de $sigma_7$ dans $H_1$ (car elle "remplit" le contenu du cycle)

En revanche si $"low"_overline(B) (j) = -1$ alors l'apparition de $sigma_j$ crée une classe d'homologie : s'il existe $k$ tel que $"low"_overline(B) (k) = j$ on est dans le cas précédent, sinon la classe d'homologie n'est jamais tuée.

// C'est depuis cette matrice $overline(B)$ réduite que l'on construit notre diagramme de persistance comme il suit : 

// #def[
//     Un diagramme de persistance PD est un multi-ensemble de $overline(bb(R)^2)$ tel que depuis une matrice réduite $overline(B)$ on ait, en notant $"dg"(sigma) = l$ si $sigma$ apparait à partir de $K_l$ : 

//     $ "PD" = {("dg"(i), "dg"(j)), "tels que low"_overline(B) (j) = i""} union {("dg"(i), +infinity), "tels que low"_overline(B) (i) = -1} $
// ]

// C'est grâce à cette définition que nous arrivons au diagramme de persistance donnée en @PD_ex

C'est depuis cette matrice que nous sommes capables de déterminer $H_0$ et $H_1$, et donc de générer des représentations graphiques comme montré en @CarteResultat

= Recherche d'optimisation<optimisation>

La motivation de cette section vient de l'observation suivante : pour 36 stations, il faut environ 10 secondes pour calculer les classes d'homologies. Sachant que ce temps d'exécution provient majoritairement de la complexité temporelle du standard algorithm, nous cherchons à optimiser la complexité de celui ci : $O(n^3) = O(2^(3|#ensPts|))$ ($n$ étant le nombre total de simplexes possibles $=2^(|#ensPts|)$).

L'optimisation que l'on propose provient de deux observations :
- $B$ est une matrice creuse ;
- L'opération de somme de colonnes (ligne 3) agit seulement sur une matrice extraite $B_d$ ne dépendant que de la dimension des simplexes. 

Le premier point influence le choix d'utilisation de listes d'adjacences à une matrice d'adjacence, en particulier par des doubles listes chaînées ordonnées.

La justification du second point se trouve en annexe.

On en déduit cet algorithme où $B$ est modifié par effet de bords sur les $B_d$ : 


#code("dims <- Tableau des simplexes où dims[i] contient la liste des simplexes de dim=i
for toute dimension d à considérer:
    for chaque simplexe j de dims[d] de façon croissante
        while il existe i tel que low[j] = low[i]:
            ajouter colonne i de B à colonne j modulo 2
", title:"StandardAlgorithmUpgrade(B)")

Le calcul de la complexité ne permettant pas d'avoir une meilleure borne, on note que cette algorithme est en $O(2^(3|#ensPts|))$ au pire, mais bien moins en pratique, voir @resultatOpti.

= Résultats et conclusion

== Résultats de l'homologie persitante
// #figure(
//     table(
//         columns: (auto, auto, auto, auto),
//         inset: 10pt,
//         align: horizon,
//         table.header(
//         [*Ville*], [*Dimension*], [*Médiane*], [*Variance*],
//         ),
//         table.cell(rowspan: 2)[#mrs], 
//             "0D Homologie", "184.00s", "23.57s",
//             "1D Homologie", "223.50s", "10.5s",
//         table.cell(rowspan: 2)[#tls], 
//             "0D Homologie", "211.00s", "22.27s",
//             "1D Homologie", "318.00s", "58.62s",


//     ),
//     caption: [Tableau récapitulant les médianes ainsi que la variance des temps de mort des classes holomogiques pour chaque ville.]

// )

// On comprend que globalement il faut 200s (soit 3m20s) pour quelqu'un de se rendre d'une station à une autre (le minimum en temps entre la voiture et la marche) ce qui est effectivement cohérent avec la réalité. Les temps des classes pour la dimension 1 montrent le temps moyen de trajet entre les deux stations les plus éloignées d'un même cycle. Donc par exemple pour #tls, il faudra en moyenne 318s (5min20s) pour rejoindre une station depuis les zones les moins bien deservies.

#align(center)[
    #grid(
        columns: (50%, 50%),
        [
            #figure(
                image("../../Code/images/marseille.png", width: 100%),
                caption:[Carte de #mrs]
            )<CarteResultat>
        ],
        [
            #figure(
                image("../../Code/images/toulouse.png", width:100%),
                caption:[Carte de #tls]
            )
        ],
    )
]
_Visuels à changer pour supprimer le nom des villes et rendre plus joli les triangles_

Les triangles ici représentés montrent les zones où il est le plus difficile de rejoindre une station de métro. Pour les plus gros triangles, il peut être cohérent de croire qu'il est difficile de se rendre à ces stations de métros. En revanche, l'interprétation est plus dure pour les plus petits triangles.

Nous devons revenir à la définition de notre distance : celle ci prend en compte le temps minimal entre un trajet en voiture et le même trajet à pied. Les plus petites zones, comme à gauche sur la ligne bleue dans la #mrs ou en bout de ligne rouge dans la #tls, correspondent en fait à des espaces uniquement piétons dont le temps de trajet est plus court à pied qu'en voiture. Ainsi, les plus petites zones indiquent donc la même information (difficulté d'accès à ces stations) que les grandes mais à une échelle différente.

== Résultat de l'optimisation

#figure(
    grid(columns: (50%, 50%),
    image("../images/analyse_cmpx.png"),
    image("../images/analyse_cmpx_log.png")
    ),
    caption: "Temps d'exécution des deux algorithmes précédents, avec une ordonnée linéaire à gauche et logarithmique à droite."
)<resultatOpti>

On observe sur la @resultatOpti une nette amélioration entre la version avant optimisation et celle après, cependant, même si la figure de gauche montre la différence ressentie lors de l'exécution, celle de droite montre que nous restons quand même en complexité "quasi"-exponentiel en le nombre d'éléments de #ensPts.

Notons que le stockage en liste d'adjacence permet un plus grand nombres d'éléments tandis que la matrice d'adjacence pose beaucoup plus de problèmes. Ici, l'étude s'arrête pour un nombre d'éléments égale à 65 puisqu'il faut plus de 16go de ram pour stocker la matrice d'une taille supérieure (ma limite physique).

L'homologie persistante est donc une méthode nous permettant de mettre en lumière des zones mal desservies en prenant en compte des realités plus complexes que seul le temps de trajet. Par exemple, nous prenons en compte les temps d'attente en station mais nous aurions pu aussi prendre en compte la densité de population autour de ces stations. Cette caractéristique peut être une possibilité d'ouverture de ce sujet car celle ci joue intuitivement un rôle dans le temps d'attente en station et donc dans la difficulté de prendre un métro.

#bibliography("../bibliography.yml", style: "american-physics-society", title:"Bibliographie")

= Annexe

Justifions le deuxième point annoncé dans @optimisation, soit $d in [|0, |#ensPts| - 1|]$, considérons la matrice extraite :
$ B_d = (B_(i,j))_((i,j) in I) "telle que " I = {(i,j) in [|0,n-1|], dim(sigma_i) = d "et "dim(sigma_j)=d+1 } $

On note $phi$ la correspondance entre les indices des deux matrices : $(B_d)_(phi(i,j)) = B_(i,j)$

Supposons que l'on exécute la ligne 3 de l'algorithme, alors $"low"(j)="low"(i) = k$, on pose $sigma_i$, $sigma_j$ et $sigma_k$ les simplexes associés. Donc $sigma_k$ est une face de $sigma_i$ et $sigma_j$, donc par définition 
$ dim(sigma_k) + 1 = dim(sigma_i) = dim(sigma_j) $

La ligne $L_k$ ainsi que les deux colonnes $C_i$ et $C_j$ sont alors considérées dans $B_(d)$ ($d = dim(sigma_k)$). De plus, toutes les lignes ayant un coefficient non nul dans les colonnes $C_i$ ou $C_j$ le sont aussi puisqu'un coefficient non nul revient à être une face, donc de dimension $d$. 

Ainsi l'opération de somme des colonnes $C_i + C_j$ dans $B$ (ligne 3) est équivalent à celle de $C_i' + C_j'$ dans $B_d$ avec $phi(i,j) = (i',j')$.

Ainsi, au lieu d'exécuter l'algorithme sur la matrice creuse $B$, on peut l'exécuter sur les matrices extraites $B_d$ plus petites et moins creuses, on localise ainsi les modifications.

// _Partie temporaire pour plus de compréhension_
// == Théorème des invariants <annexe_inv>
// Source de @ComputingPH : 

// #image("../images/image1.png")
// #image("../images/image2.png")
// #image("../images/image3.png")
// #image("../images/image4.png")