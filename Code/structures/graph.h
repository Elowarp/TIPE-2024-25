/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:21
 *  Last modified : 14-09-2024 22:24:51
 *  File : graph.h
 */
#ifndef GRAPH_H
#define GRAPH_H

#include <stdbool.h>

typedef struct {
    int size;
    bool **edges;
} Graph;

// Trouve les composantes connexes d'un graphe
// La signature va changer
void FindCC();

#endif