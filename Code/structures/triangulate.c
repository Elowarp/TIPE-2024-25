/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-09-2024 16:05:58
 *  Last modified : 29-09-2024 16:03:22
 *  File : triangulate.c
 *  Description : Triangulation d'un tableau de points via l'algorithme de Delaunay
 *             Inspiration : (https://paulbourke.net/papers/triangulate/)
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "geometry.h"
#include "triangulate.h"

// Retourne un triangle englobant tous les points, écrit dans p1, p2 et p3 
// les coordonnées des sommets du triangle
Triangle *createSuperTriangle(Point *pts, int n, Point *p1, Point *p2, Point *p3){
    /*
      Recherche le minimum et maximum des points dans l'ensemble.
    */
    float xmin, xmax, ymin, ymax, dx, dy, dmax, xmid, ymid;
    xmin = pts[0].x;
    ymin = pts[0].y;
    xmax = xmin;
    ymax = ymin;
    for (int i=1;i<n;i++) {
        if (pts[i].x < xmin) xmin = pts[i].x;
        if (pts[i].x > xmax) xmax = pts[i].x;
        if (pts[i].y < ymin) ymin = pts[i].y;
        if (pts[i].y > ymax) ymax = pts[i].y;
    }
    dx = xmax - xmin;
    dy = ymax - ymin;
    dmax = (dx > dy) ? dx : dy;
    xmid = (xmax + xmin) / 2.0;
    ymid = (ymax + ymin) / 2.0;

    // Crée le supertriangle avoir une marge suffisante d'au 
    // moins 1 partout pour contenir tous les points
    Triangle *superTriangle = malloc(sizeof(Triangle));
    p1->x = xmid - 20 * dmax;
    p1->y = ymid - dmax;
    p2->x = xmid;
    p2->y = ymid + 20 * dmax;
    p3->x = xmid + 20 * dmax;
    p3->y = ymid - dmax;

    // On assigne les indices des points
    superTriangle->p1 = n;
    superTriangle->p2 = n+1;
    superTriangle->p3 = n+2;

    return superTriangle;
}

// Triangulation d'un tableau de n points
TriangleList *triangulate(Point *pts, int n){
    TriangleList *list = NULL;

    // Déterminer le supertriangle
    Point *p1 = malloc(sizeof(Point));
    Point *p2 = malloc(sizeof(Point));
    Point *p3 = malloc(sizeof(Point));
    Triangle *superTriangle = createSuperTriangle(pts, n, p1, p2, p3);

    // Ajouter les sommets du supertriangle à la fin de la liste de points
    Point *newPts = malloc((n+3) * sizeof(Point));
    for(int i=0;i<n;i++){
        newPts[i] = pts[i];
    }
    newPts[n] = *p1;
    newPts[n+1] = *p2;
    newPts[n+2] = *p3;

    // Ajouter le supertriangle à la liste de triangles
    list = triangleListInit(superTriangle);

    // Pour chaque point dans la liste de points
    for(int i=0;i<n;i++){
        // Initialiser le buffer d'arêtes
        EdgeList *edgeBuffer = NULL;

        // Pour chaque triangle dans la liste de triangles
        TriangleList *current = list;
        TriangleList *modifiedList = list;
        while(current != NULL){
            // Sauvegarde la cible suivante avant potentielle suppression 
            // de current
            TriangleList *next = current->next;

            // Calculer le centre et le rayon du cercle circonscrit du triangle
            Point center;
            float radius;
            circumCircle(current->t, newPts, &center, &radius);

            // Si le point est dans le cercle circonscrit du triangle
            if(inCircle(&center, radius, &newPts[i])){
                // Ajouter les trois arêtes du triangle au buffer d'arêtes

                // Cas du buffer vide
                if (edgeBuffer == NULL) 
                    edgeBuffer = edgeListInit (current->t->p1, current->t->p2, 
                        dist(newPts[current->t->p1], newPts[current->t->p2]));
                else 
                    edgeListInsert(edgeBuffer, current->t->p1, current->t->p2, 
                        dist(newPts[current->t->p1], newPts[current->t->p2]));
                
                // Ajout du reste
                edgeListInsert(edgeBuffer, current->t->p2, current->t->p3, 
                    dist(newPts[current->t->p2], newPts[current->t->p3]));
                    
                edgeListInsert(edgeBuffer, current->t->p3, current->t->p1, 
                    dist(newPts[current->t->p3], newPts[current->t->p1]));
                    
                // Retirer le triangle de la liste de triangles
                list = triangleListRemove(list, current->t);
            }

            current = next;
        }


        // Supprimer les arêtes doublées du buffer d'arêtes
            // Cela laisse uniquement les arêtes du polygone englobant
        edgeBuffer = removeDoubledEdges(edgeBuffer);

        // Ajouter à la liste de triangles tous les triangles formés entre le point
            // et les arêtes du polygone englobant
        EdgeList *currentEdge = edgeBuffer;
        while(currentEdge != NULL){
            list = triangleListInsert(list, 
                    createTriangle(currentEdge->p1, currentEdge->p2, i));
            currentEdge = currentEdge->next;
        }
        
    }
    // Retirer les triangles de la liste de triangles qui utilisent les 
    // sommets du supertriangle
    TriangleList *current = list;
    TriangleList *modifiedList = list;
    while(current != NULL){
        TriangleList *next = current->next;
        if (current->t->p1 >= n || current->t->p2 >= n || current->t->p3 >= n)
            list = triangleListRemove(list, current->t);
            
        current = next;
    }


    // Retirer les sommets du supertriangle de la liste de points
    free(p1);
    free(p2);
    free(p3);
    free(newPts);

    return list;
}