/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 13:06:18
 *  Last modified : 15-09-2024 16:53:29
 *  File : kdTree.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "../misc.h"
#include "geometry.h"
#include "heap.h"
#include "kdTree.h"

/*
    Fichier construisant un arbre k-d à partir d'un ensemble de points, 
    pour k = DIM
*/

// Crée un noeud de l'arbre
KDTree *kdTreeNodeInit(Point pt){
    KDTree *tree = malloc(1*sizeof(KDTree));
    tree->axis = 0;
    tree->left = NULL;
    tree->right = NULL;
    tree->point = pt;
    return tree;
}

// Compare la i-ième coordonnées des deux points entre eux
static bool cmpPointsCoord(Point p1, Point p2, int i){
    switch (i)
    {
    case 0:
        return p1.x < p2.x;

    case 1:
        return p1.y < p2.y;
    
    default:
        print_err("cmpPointsCoord: Coordonnée impossible\n");
        exit(1);
    }
}

// Trie un tableau de n points selon la i-ième coordonnée
static void sortPointArray(Point *pts, int n, int i){
    // Tri par insertion
    for (int j = 1; j < n; j++){
        Point key = pts[j];
        int k = j-1;

        while (k >= 0 && cmpPointsCoord(key, pts[k], i)){
            pts[k+1] = pts[k];
            k--;
        }
        
        pts[k+1] = key;
    }
}

// Tri le tableau des n points selon la i-ième coordonnées et 
// renvoie le point médian
static Point median(Point *pts, int n, int i){
    // Implémentation naïve
    sortPointArray(pts, n, i);
    return pts[(n-1)/2]; // Prend le point médian bas
}

// Crée l'arbre depuis un ensemble de n point, commençant par la i-ième coordonnée
KDTree *kdTreeInit(Point *pts, int n, int i){
    if (n == 0) return NULL;
    
    Point pt;
    if (n == 1) pt = pts[0];
    else pt = median(pts, n, i);
    
    KDTree *tree = kdTreeNodeInit(pt);

    tree->axis = i;
    tree->left = kdTreeInit(pts, (n-1)/2, (i+1)%DIM);

    // On avance de n/2 pour ne pas inclure le point médian
    if (n > 1){ // S'assure qu'on ne dépasse pas la taille du tableau
        Point *pts_after_med = pts + (n-1)/2 + 1;
        tree->right = kdTreeInit(pts_after_med, (n - (n-1)/2 - 1), (i+1)%DIM);
    }

    return tree;
}

// Affiche un arbre avec une indentation de i espaces
static void kdTreePrintIndent(KDTree *tree, int i){
    char *s = " | ";
    if (tree == NULL){
        for (int j = 0; j < i; j++) printf("%s", s);
        printf("NULL\n");
        return;
    }

    for (int j = 0; j < i; j++) printf("%s", s);
    printf("Point : (%f, %f)\n", tree->point.x, tree->point.y);
    for (int j = 0; j < i; j++) printf("%s", s);
    printf("Axis : %d\n", tree->axis);
    
    for (int j = 0; j < i; j++) printf("%s", s);
    printf("Left : \n");
    kdTreePrintIndent(tree->left, i+1);
    for (int j = 0; j < i; j++) printf("%s", s);
    printf("Right : \n");
    kdTreePrintIndent(tree->right, i+1);
}

// Affiche un arbre 
void kdTreePrint(KDTree *tree){
    kdTreePrintIndent(tree, 0);
}

// Renvoie la différence entre les coordonnes i des deux points 
static float diffCoord(Point p1, Point p2, int i){
    switch (i)
    {
    case 0:
        return p1.x - p2.x;

    case 1:
        return p1.y - p2.y;

    default:
        print_err("diffCoord: Coordonnée impossible\n");
        exit(1);
    }
}

// Parcours de l'arbre avec la construction des k plus proches voisins
static void visit(KDTree *tree, Point pt, int i, int k, HeapMax *H){
    if(tree == NULL) return;

    float diff = diffCoord(tree->point, pt, i);
    KDTree *t1;
    KDTree *t2;

    if (diff >= 0){
        t1 = tree->left;
        t2 = tree->right;
    } else {
        t1 = tree->right;
        t2 = tree->left;
    }

    // Visite du premier sous arbre
    visit(t1, pt, (i+1)%DIM, k, H);

    // Visite du deuxième si nécessaire
    if(heapMaxSize(H) < k || heapMaxTop(H)->priority >= diff){
        HeapNode *node = heapNodeInit(dist(tree->point, pt), (void *) (&tree->point));
        
        if (heapMaxSize(H) >= H->maxSize){
            HeapNode *node = heapMaxPop(H);
            heapNodeFree(node);
        }
        
        heapMaxInsert(H, node);
        
        visit(t2, pt, (i+1)%DIM, k, H);
    }
}

// Recherche des k plus proche voisins d'un point pt dans l'arbre
Point *kdTreeNearestNeighbor(KDTree *tree, Point pt, int k){
    // Construit un tas max des k plus proches voisins
    HeapMax *H = heapMaxInit(k);
    visit(tree, pt, 0, k, H);

    // Transforme les k voisins trouvés en tableau de points
    // Et libère les noeuds du tas
    int size = heapMaxSize(H);
    Point *neighbors = malloc((size)*sizeof(Point));
    for(int i = 0; i < size; i++){
        HeapNode *node = heapMaxPop(H);
        Point p = *(Point *) node->elmt;
        neighbors[i] = p;
        heapNodeFree(node);
    }

    // Libérer tous les noeuds de H
    heapMaxFree(H);
    return neighbors;
};

// Libère un arbre k-d
void kdTreeFree(KDTree *tree){
    if (tree == NULL) return;

    kdTreeFree(tree->left);
    kdTreeFree(tree->right);
    
    free(tree);
}