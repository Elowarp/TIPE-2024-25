/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:23:55
 *  Last modified : 05-11-2024 17:15:19
 *  File : persDiag.h
 */
#ifndef PERSDIAG_H
#define PERSDIAG_H

#include "geometry.h"

typedef struct {
    int x;
    int y;
} Tuple;

typedef struct {
    int *dims;
    Tuple *pairs;
    int size_pairs;
    int size_dims;
} PersistenceDiagram;

extern Filtration *buildFiltration(PointCloud *X);
extern int **buildBoundaryMatrix(int *reversed, int n, int nb_pts);
extern int **reduceMatrix(int **boundary, int n, int *low);
extern int *buildLowMatrix(int **boundary, int n);
extern Tuple *extractPairs(int *low, int n, int *size_pairs);
extern Tuple *extractPairsFilt(int *low, Filtration *filt, int n, int *size_pairs);
extern int *reverseIdAndSimplex(Filtration *filt, int max_nums);

PersistenceDiagram *PDCreate(Filtration *filtration, PointCloud *X);
void PDExport(PersistenceDiagram *pd, char *filename);
void PDFree(PersistenceDiagram *pd);

#endif