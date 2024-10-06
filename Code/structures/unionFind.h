/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 29-09-2024 18:43:47
 *  Last modified : 29-09-2024 18:44:28
 *  File : union&find.h
 */
#ifndef UNIONFIND_H
#define UNIONFIND_H

typedef struct {
    int *parent;
    int *rank;
    int size;
} UnionFind;

extern UnionFind *ufInit(int n);
extern int ufFind(UnionFind *uf, int x);
extern void ufUnion(UnionFind *uf, int x, int y);
extern void ufFree(UnionFind *uf);

#endif