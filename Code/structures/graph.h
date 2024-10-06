/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:21
 *  Last modified : 29-09-2024 18:51:50
 *  File : graph.h
 */
#ifndef GRAPH_H
#define GRAPH_H

#include <stdbool.h>
#include "geometry.h"

typedef struct {
    int size;
    bool **edges;
    float **weights;
} Graph;

extern Graph *graphInit(int n);
extern void graphEdgeAdd(Graph *g, int u, int v, float w);
extern void grapheEdgeRemove(Graph *g, int u, int v);
extern bool *lune(Graph *g, int a, int b, Point *pts);
extern Graph *graphRNG(Point *pts, int n);
extern Graph *graphMST(Graph *g);
extern Graph *graphRemove(Graph *g, Graph *toRemove);
extern void graphFree(Graph *g);

#endif