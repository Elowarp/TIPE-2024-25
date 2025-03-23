# Idée par slides à développer

1. Titre : Rien, potentiellement changer le titre en la pbatique du mcot

2. Le but : Expliquer que l'on veut convertir des données géographiques sur des stations de métros en une représentation géométrique puis grâce à des maths, de l'analyse topologique appelée l'homologie persistante, on étudie les zones concidérées les moins bien desservies d'un réseau. L'informatique n'étant qu'un outil pour les calculs

3. Dans le détail : Nous voulons trouver un moyen de reconnaitre des trous dans un ensemble discret (Image d'un donut décrit discrétement par des points, voyant un gros trou au milieu, et plein de vide entre les différents points). C'est le but de l'homologie persistante, une méthode d'analyse générale.

4. Premières définitions : Simplexes / Faces / Complexes simpliciaux

5. Un peu plus : Filtration / Les classes d'homologies : trous en dimension n (définition mathématique potentiellement en annexe)

6. Plan d'attaque : Construire une filtration à partir d'un ensemble discret de points grâce aux complexes pondérés de Vietoris-Rips / Application de l'algoritme centrale : Algorithme Standard / Récupération des classes d'homologies

7. Théorème central : Explication

8. Définition d'une distance cohérente avec notre problème : représente un temps de trajet. Mais plus cohérente à le slide d'après

9. Complexes pondérés de Vietoris-Rips : Construction incrémentale des complexes

10. Liens entre les complexes et les stations de métros : un complexe au rayon t est donc le cout en temps qu'il faut pour prendre une station. Importance de l'utilisation de cette construction par rapport à celle de Cech informatiquement + approximation

11. Sources des informations : gouvernement + Geoapify

12. Préparatif de l'algorithme : Ordre total sur les simplexes (renommage)

13. Préparatif de l'algorithme : Matrice de bordure. Ligne i = 1 en colonne j alors i est une face de j.

14. Algorithme Standard : Se base sur le théorème central sur la somme directe et réduction en code barre. Simple XOR entre les colonnes depuis la derniere. Low(j) c'est le dernier i de la colonne j tq (i, j) = 1 et on veut que chq Low(j) soit unique.

15. Résultat de l'algorithme : Matrice réduite + interprétation : recense toutes les informations pour les diagrammes de persistances mais surtout pour les cartes (en annexe) Montrer sur le graphe ce qu'il en retourne

16. Résultats, les cartes : Triangles logiques (les gros), explications des petits et pourquoi ils sont là, et ceux dont on a pas vraiment d'interprétation. Autocritique de la méthode
