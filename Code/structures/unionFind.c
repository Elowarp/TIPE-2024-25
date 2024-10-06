/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 29-09-2024 18:44:35
 *  Last modified : 29-09-2024 19:14:48
 *  File : union&find.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "unionFind.h"

// Initialise une structure Union-Find de taille n
UnionFind *ufInit(int n){
    UnionFind *uf = malloc(sizeof(UnionFind));
    uf->parent = malloc(n * sizeof(int));
    uf->rank = malloc(n * sizeof(int));
    uf->size = n;
    for(int i=0;i<n;i++){
        uf->parent[i] = i;
        uf->rank[i] = 0;
    }
    return uf;
}

// Trouve le représentant de la classe de x
int ufFind(UnionFind *uf, int x){
    if(uf->parent[x] != x){
        uf->parent[x] = ufFind(uf, uf->parent[x]);
    }
    return uf->parent[x];
}

// Fusionne les classes de x et y
void ufUnion(UnionFind *uf, int x, int y){
    int x_root = ufFind(uf, x);
    int y_root = ufFind(uf, y);
    if(x_root == y_root){
        return;
    }
    
    if(uf->rank[x_root] < uf->rank[y_root]){
        uf->parent[x_root] = y_root;
    } else if(uf->rank[x_root] > uf->rank[y_root]){
        uf->parent[y_root] = x_root;
    } else {
        uf->parent[y_root] = x_root;
        uf->rank[x_root]++;
    }
}