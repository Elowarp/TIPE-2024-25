# Etude de la couverture de réseaux de métro, application de l'homologie persistante

## Ancrage au thème de l'année

<!-- La transition écologique étant un défi majeure de notre ère, la conversion de données gouvernementale sur les stations de métros en représentation géométrique et topologique afin de trouver les zones urbaines en manque de stations pour développer de nouvelles lignes paraît bien s'inscrire dans le thème de l'année. (50mots) -->

La transition écologique est un défi majeur actuel, où la identification des faiblesses d'un réseau de transports (métros) peut s'avérer utile. La conversion des données géographiques en un espace topologique permet une analyse mathématique de ces réseaux. (49mots)

## Motivation du choix

Après avoir regardé une conférence sur l'homologie persistante et la classification d'objets 3D, j'ai trouvé une thèse appliquant ces idées à la couverture électorale aux états unis, ce qui m'a donné l'idée d'une application à un réseau de métros. (45mots)

## Positionnement thématique

Topologie & Géométrie (Mathématiques) / Informatique partique (Informatique) / Algèbre (Mathématiques)

## Mots clés

Homologie Persistante / Classes d'homologies / Métros / Transformation de données / Représentation géométrique grâce à l'informatique /  

Persistent Homology / Homology class / Subway / Data transformation / Computer Geometric representation  

## Bibliographie commentée

Dans une volonté de transition écologique, le développement d'un réseau de transport peut être complexe car elle essaye de garantir l'équité de l'accès au réseau aux personnes. J'ai étudié une thèse traitant de la couverture des points de votes aux états unis via une approche mathématique [1], j'ai donc souhaité utiliser la même approche pour analyser la couverture des services de plusieurs réseaux métropolitains français.

Cette étude [1] adopte une approche topologique, l'homologie persistante [2], afin de trouver les zones ayant le moins accès aux bureaux de vote. Je souhaite utiliser cette méthode pour trouver les zones les plus importantes à desservir, en fonction des temps de trajets (en voiture ou à pied) entre les stations, et aussi de la disposition géographique de celles-ci. Ne voulant pas créer un faux réseau, j'ai utilisé de vraies données fournies par plusieurs grandes villes comme Toulouse, Marseille, le cas de Paris ayant été abandonné (manque de données).

L'ensemble des outils mathématiques utilisés pour cette étude étant hors-programme, j'ai dû trouver des informations supplémentaires [2] afin de parfaire ma compréhension sur des exemples simples. Ce sont d'ailleurs ces exemples qui me permettent de réaliser mes tests et de vérifier mes différents programmes. Plus précisément, ce document [2] explique comment sont définies les classes d'homologies, représentant des "trous" dans un espace topologique, et comment depuis un ensemble de points dans le plan, nous sommes capables de créer des filtrations. Il apporte de plus une justification à l'utilisation des complexes simpliciaux pondérés de Vietoris-Rips (2) d'un point de vue informatique. Le document [3] apporte un deuxième point de vue sur ces notions et fournitw un algorithme simple permettant de faire le lien entre filtration et classes d'homologies (nécessaire à mon travail sur les réseaux de métro).

Le document [1] permet ensuite de donner une interprétation réelle aux filtrations et aux classes d'homologies. En particulier, ce sont ces classes d'homologies qui nous intéressent [1] et qui, dans notre cas, représentent les zones les moins biens desservies du réseau. Après application de cette méthode, nous avons pu soumettre nos résultats à des habitants afin d'avoir une contre-expertise de notre évaluation personnelle. (406 mots)

## Problématique retenue
<!-- 
Comment détecter les zones urbaines les plus en manque de stations de métros dans un réseau pré-existant : Une approche via la topologie persistante. -->

Comment appliquer la topologie persistante afin de détecter les zones urbaines les moins bien desservies au sein d'un réseau de métro donné ?

## Objectifs du TIPE

1. Convertir les données géographiques des réseaux métropolitains en une représentation informatique d'un espace topologique.
2. Détecter les zones les plus mal desservies.
3. Interpréter pourquoi certaines zones ont été étonnamment détectées et critiquer les limites de notre approche.
4. Appropriation des concepts mathématiques

## Références

[1] A. HICKOK B. JARMAN M. JOHNSON J.LUO et M. A PORTER : Persitent homology for resource coverage: A case study of access to polling sites : https://arxiv.org/pdf/2206.04834

[2] U. Fugacci S. Scaramuccia F. Iuricich et L. De Floriani : Persistent homology: a step-by-step introduction for newcomers : https://www.math.uri.edu/~thoma/comp_top__2018/stag2016.pdf

[3] N. Otter M. A Porter U.Tillmann P. Grindrod H. A Harrington : A roadmap for the computation of persistent homology : https://epjdatascience.springeropen.com/articles/10.1140/epjds/s13688-017-0109-5
