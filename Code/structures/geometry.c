/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 13:55:46
 *  Last modified : 29-09-2024 15:49:55
 *  File : geometry.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "geometry.h"

const int DIM = 2;

// Renvoie la distance euclidienne entre deux points
float dist_euclidean(Point p1, Point p2){
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y-p1.y, 2));
}

// Renvoie la distance entre deux points
// Cette fonction sert d'interface pour que l'on puisse facilement
// la modifier lors de l'application de notre programme à un sujet
float dist(Point p1, Point p2){
    return dist_euclidean(p1, p2);
}

///////////////////////
//      POINTS       //
///////////////////////

// Affiche un point
void pointPrint(Point p){
    printf("(%f, %f)", p.x, p.y);
}

// Initialise un nuage de points
PointCloud *pointCloudInit(int size){
    PointCloud *pointCloud = malloc(sizeof(PointCloud));
    pointCloud->pts = malloc(size * sizeof(Point));
    pointCloud->weights = malloc(size * sizeof(float));
    pointCloud->size = size;
    return pointCloud;
};

// Teste si deux points sont égaux
bool pointAreEqual(Point p1, Point p2){
    return p1.x == p2.x && p1.y == p2.y;
};

// Libère un nuage de points
void pointCloudFree(PointCloud *pointCloud){
    free(pointCloud->pts);
    free(pointCloud->weights);
    free(pointCloud);
};

///////////////////////
//       EDGES       //
///////////////////////

// Initialise une liste d'arêtes
EdgeList *edgeListInit(int p1, int p2, float weight){
    EdgeList *list = malloc(sizeof(EdgeList));
    list->p1 = p1;
    list->p2 = p2;
    list->weight = weight;
    list->next = NULL;
    return list;
}

// Insère une arête dans la liste
void edgeListInsert(EdgeList *edgeList, int p1, int p2, float weight){
    EdgeList *new = malloc(sizeof(EdgeList));
    new->p1 = p1;
    new->p2 = p2;
    new->weight = weight;
    new->next = NULL;

    EdgeList *cur = edgeList;
    while(cur->next != NULL){
        cur = cur->next;
    }
    
    cur->next = new;
}

// Affiche une liste d'arêtes
void edgeListPrint(EdgeList *edgeList){
    EdgeList *current = edgeList;
    while(current != NULL){
        printf("Edge : %d %d %f\n", current->p1, current->p2, current->weight);
        current = current->next;
    }
}

// Retourne vrai si deux arêtes sont égales
bool edgeAreEqual(EdgeList *e1, EdgeList *e2){
    return (e1->p1 == e2->p1 && e1->p2 == e2->p2) ||
        (e1->p1 == e2->p2 && e1->p2 == e2->p1);
}

// Supprime toutes les occurrences d'une arête dans une liste d'arêtes
EdgeList *edgeListRemove(EdgeList *edgeList, EdgeList *edge){
    if (edgeList == NULL){
        return NULL;
    } else if (edgeAreEqual(edgeList, edge)){
        EdgeList *next = edgeList->next;
        EdgeList *tmp = edgeListRemove(next, edge);
        free(edgeList);
        return tmp;
    } else {
        edgeList->next = edgeListRemove(edgeList->next, edge);
        return edgeList;
    }
}

// Compte le nombre d'occurrences d'une arête dans une liste d'arêtes
int edgeListCount(EdgeList *edgeList, EdgeList *edge){
    if (edgeList == NULL){
        return 0;
    } else if (edgeAreEqual(edgeList, edge)){
        return 1 + edgeListCount(edgeList->next, edge);
    } else {
        return edgeListCount(edgeList->next, edge);
    }
}

// Supprime les arêtes en double d'une liste d'arêtes
// Si a est une arête présente plus de 2 fois, alors la liste renvoyée ne 
// contiendra plus a
EdgeList *removeDoubledEdges(EdgeList *edgeList){
    if (edgeList == NULL){
        return NULL;
    } else {
        EdgeList *next = edgeList->next;
        EdgeList edge = {edgeList->p1, edgeList->p2, edgeList->weight, NULL};
        if (edgeListCount(edgeList, &edge) > 1){
            return removeDoubledEdges(edgeListRemove(edgeList, &edge));
            
        } else {
            edgeList->next = removeDoubledEdges(next);
            return edgeList;
        }
    }
}

// Libère une liste d'arêtes
// Attention, cette fonction ne libère pas les points
void edgeListFree(EdgeList *edgeList){
    EdgeList *current = edgeList;
    while(current != NULL){
        EdgeList *next = current->next;
        free(current);
        current = next;
    }
}

///////////////////////
//     TRIANGLES    //
///////////////////////
// Crée un triangle
Triangle *createTriangle(int p1, int p2, int p3){
    Triangle *t = malloc(sizeof(Triangle));
    t->p1 = p1;
    t->p2 = p2;
    t->p3 = p3;
    return t;
}

// Crée une liste de triangles
TriangleList *triangleListInit(Triangle *t){
    TriangleList *list = malloc(sizeof(TriangleList));
    list->t = t;
    list->next = NULL;
    list->prev = NULL;
    return list;
}

// Affiche liste triangle 
void triangleListPrint(TriangleList *list){
    TriangleList *current = list;
    while(current != NULL){
        trianglePrint(current->t);
        printf("\n");
        current = current->next;
    }
}

// Ajoute un triangle à la liste
TriangleList *triangleListInsert(TriangleList *list, Triangle *t){
    TriangleList *new = triangleListInit(t);
    TriangleList *cur = list;

    if (cur == NULL){
        return new;
    }

    while(cur->next != NULL){
        cur = cur->next;
    }
    cur->next = new;
    new->prev = cur;

    return list;
}

// Teste si deux triangles sont égaux
bool triangleAreEqual(Triangle *t1, Triangle *t2){
    return (t1->p1 == t2->p1 && t1->p2 == t2->p2 && t1->p3 == t2->p3) ||
        (t1->p1 == t2->p1 && t1->p2 == t2->p3 && t1->p3 == t2->p2) ||
        (t1->p1 == t2->p2 && t1->p2 == t2->p1 && t1->p3 == t2->p3) ||
        (t1->p1 == t2->p2 && t1->p2 == t2->p3 && t1->p3 == t2->p1) ||
        (t1->p1 == t2->p3 && t1->p2 == t2->p1 && t1->p3 == t2->p2) ||
        (t1->p1 == t2->p3 && t1->p2 == t2->p2 && t1->p3 == t2->p1);
}

// Supprime un triangle de la liste
TriangleList *triangleListRemove(TriangleList *list, Triangle *t){
    if (list == NULL){
        return NULL;
    } else if (triangleAreEqual(list->t, t)){
        TriangleList *next = list->next;
        free(list);
        return next;
    }
    
    TriangleList *cur = list->next;
    
    while(cur != NULL){
        TriangleList *next = cur->next;
        
        if(triangleAreEqual(cur->t, t)){
            if (cur->next == NULL) {
                if (cur->prev != NULL)
                    cur->prev->next = NULL;
            } else {
                cur->next->prev = cur->prev;
            }
            
            if (cur->prev == NULL){
                if (cur->next != NULL)
                    cur->next->prev = NULL;
                
            } else {
                cur->prev->next = cur->next;
            }

            free(cur);
        } 
        
        cur = next;
    }
    return list;

}

// Renvoie la longueur de la liste de triangles
int triangleListLength(TriangleList *list){
    int length = 0;
    TriangleList *cur = list;
    while(cur != NULL){
        length++;
        cur = cur->next;
    }
    return length;
}

// Libère la mémoire allouée pour une liste de triangles
// /!\ Attention, cette fonction ne libère pas la mémoire des triangles, que
// des maillons de la liste
void triangleListFree(TriangleList *list){
    TriangleList *tmp;
    while(list != NULL){
        tmp = list;
        list = list->next;
        free(tmp);
    }
}

// Affiche un triangle
void trianglePrint(Triangle *t){
    printf("Triangle : %d %d %d", t->p1, t->p2, t->p3);
}


///////////////////////
//       Circles     //
///////////////////////

// Calcule le cercle circonscrit d'un triangle
void circumCircle(Triangle *t, Point *pts, Point *center, float *radius){
    Point p1 = pts[t->p1];
    Point p2 = pts[t->p2];
    Point p3 = pts[t->p3];

    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    float x3 = p3.x;
    float y3 = p3.y;

    float A = x2 - x1;
    float B = y2 - y1;
    float C = x3 - x1;
    float D = y3 - y1;

    float E = A * (x1 + x2) + B * (y1 + y2);
    float F = C * (x1 + x3) + D * (y1 + y3);

    float G = 2.0 * (A * (y3 - y2) - B * (x3 - x2));

    float dx, dy;

    if (fabs(G) < 0.000001) {
        center->x = 0;
        center->y = 0;
        *radius = -1;
        return;
    }

    center->x = (D * E - B * F) / G;
    center->y = (A * F - C * E) / G;

    dx = center->x - x1;
    dy = center->y - y1;
    *radius = sqrt(dx * dx + dy * dy);
}


// Retourne vrai si le point est dans un cercle de centre center et de rayon 
// radius
bool inCircle(Point *center, float radius, Point *p){
    float dx = p->x - center->x;
    float dy = p->y - center->y;
    float dist = sqrt(dx * dx + dy * dy);
    return dist <= radius;
}