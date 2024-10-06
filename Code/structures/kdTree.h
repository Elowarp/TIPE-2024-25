/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:24
 *  Last modified : 29-09-2024 19:22:14
 *  File : kdTree.h
 */
#ifndef KDTREE_H
#define KDTREE_H

#include "geometry.h"

typedef struct KDTree_t {
    int axis;
    Point point;
    struct KDTree_t *left, *right;
} KDTree;

extern KDTree *kdTreeInit(Point *pts, int n, int i);

extern void kdTreePrint(KDTree *tree);
extern Point *kdTreeNearestNeighbor(KDTree *tree, Point pt, int k, 
    int *nb_neighboors);

extern void kdTreeFree(KDTree *tree);
#endif