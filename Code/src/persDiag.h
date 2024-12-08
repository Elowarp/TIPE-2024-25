/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:23:55
 *  Last modified : 26-11-2024 15:46:07
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
    unsigned long long size_pairs;
    Simplex *death1D; // Simplexes tuant des 1D homologies
    int size_death1D;
    int size_dims;
} PersistenceDiagram;

extern Filtration *buildFiltration(PointCloud *X);
extern int *reverseIdAndSimplex(Filtration *filt);
extern int **buildBoundaryMatrix(int *reversed, unsigned long long n, int nb_pts);
extern int *buildLowMatrix(int **boundary, unsigned long long n);
extern int **reduceMatrix(int **boundary, unsigned long long n, int *low);
extern Tuple *extractPairsFilt(int *low, Filtration *filt, 
    unsigned long long *size_pairs, int *reversed);

PersistenceDiagram *PDCreate(Filtration *filtration, PointCloud *X);
void PDExport(PersistenceDiagram *pd, char *filename, char *death_filename, bool bigger_dims);
void PDFree(PersistenceDiagram *pd);

#endif