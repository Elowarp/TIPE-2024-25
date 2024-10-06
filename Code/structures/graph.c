/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 29-09-2024 18:21:59
 *  Last modified : 29-09-2024 18:55:20
 *  File : graph.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "geometry.h"
#include "graph.h"
#include "unionFind.h"

// Crée un graphe de taille n
Graph *graphInit(int n){
    Graph *g = malloc(sizeof(Graph));
    g->size = n;
    g->edges = calloc(n, sizeof(bool *));
    g->weights = calloc(n, sizeof(float *));
    for(int i=0;i<n;i++){
        g->edges[i] = calloc(n, sizeof(bool));
        g->weights[i] = calloc(n, sizeof(float));
    }
    return g;
}

// Ajoute une arête entre les sommets u et v
void graphEdgeAdd(Graph *g, int u, int v, float w){
    g->edges[u][v] = true;
    g->edges[v][u] = true;
    g->weights[u][v] = w;
    g->weights[v][u] = w;
}

// Supprime une arête entre les sommets u et v
void grapheEdgeRemove(Graph *g, int u, int v){
    g->edges[u][v] = false;
    g->edges[v][u] = false;
    g->weights[u][v] = 0;
    g->weights[v][u] = 0;
}

// Retourne l'ensemble de points dans la lune d'un simplexe <ab>
bool *lune(Graph *g, int a, int b, Point *pts){
    bool *l = calloc(g->size, sizeof(bool));
    for(int i=0;i<g->size;i++){
        if(dist(pts[a], pts[i]) < dist(pts[a], pts[b])
          && dist(pts[b], pts[i]) < dist(pts[a], pts[b])){
            l[i] = true;
        }
        
    }
    return l;
}

// Teste si un tableau est rempli de false
static bool allFalse(bool *l, int n){
    for(int i=0;i<n;i++){
        if(l[i]){
            return false;
        }
    }
    return true;
}

// Retourne le graphe relatif aux voisins d'un ensemble de points
Graph *graphRNG(Point *pts, int n){
    Graph *g = graphInit(n);
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            bool *l = lune(g, i, j, pts);
            if (allFalse(l, n)){
                graphEdgeAdd(g, i, j, 0);
            }
        }
    }
    return g;
}

// Calcule un arbre couvrant minimal d'un graphe via Kruskal
Graph *graphMST(Graph *g){
    Graph *mst = graphInit(g->size);

    // Crée le tableau des arêtes
    int **edges = malloc(sizeof(int *));
    for(int i=0;i<g->size;i++){
        edges[i] = malloc(sizeof(int));
    }

    int count = 0;

    // Remplit le tableau des arêtes
    for(int i=0;i<g->size;i++){
        for(int j=i+1;j<g->size;j++){
            if(g->edges[i][j]){
                int infos[3] = {i, j, g->weights[i][j]};
                edges[count] = infos;
            }
        }
    }    

    // Trie le tableau des arêtes
    for(int i=0;i<count;i++){
        for(int j=i+1;j<count;j++){
            if(edges[i][2] > edges[j][2]){
                int *tmp = edges[i];
                edges[i] = edges[j];
                edges[j] = tmp;
            }
        }
    }

    // Initialise une structure Union-Find pour eviter les cycles
    UnionFind *p = ufInit(count);

    // Ajoute les arêtes au MST
    for(int i=0;i<count;i++){
        int u = edges[i][0];
        int v = edges[i][1];
        if(ufFind(p, u) != ufFind(p, v)){
            graphEdgeAdd(mst, u, v, edges[i][2]);
            ufUnion(p, u, v);
        }
    }

    return mst;
}

// Calcule le graphe privé d'un autre graphe
Graph *graphRemove(Graph *g, Graph *toRemove){
    Graph *new = graphInit(g->size);
    for(int i=0;i<g->size;i++){
        for(int j=0;j<g->size;j++){
            if(g->edges[i][j] && !toRemove->edges[i][j]){
                graphEdgeAdd(new, i, j, g->weights[i][j]);
            }
        }
    }
    return new;
}

// Libère la mémoire allouée pour un graphe
void graphFree(Graph *g){
    for(int i=0;i<g->size;i++){
        free(g->edges[i]);
        free(g->weights[i]);
    }
    free(g->edges);
    free(g->weights);
    free(g);
}