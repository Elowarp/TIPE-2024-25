/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:24
 *  Last modified : 15-09-2024 15:49:27
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
extern Point *kdTreeNearestNeighbor(KDTree *tree, Point pt, int k);

extern void kdTreeFree(KDTree *tree);
#endif