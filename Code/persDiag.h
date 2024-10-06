/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:23:55
 *  Last modified : 29-09-2024 19:44:00
 *  File : persDiag.h
 */
#ifndef PERSDIAG_H
#define PERSDIAG_H

#include "structures/geometry.h"

typedef struct {
    Point *pts;
    int size;
} PersistenceDiagram;

typedef struct {
    int a;
    Point *N_a_t;
    int t;
} H_elmt;

typedef struct {
    int *values;
    int size;
} Psi;

void FindPersistentHomology(PointCloud X);

PersistenceDiagram *PDCreate(Filtration *filtration);
void PDExport(PersistenceDiagram *pd, char *filename);
void PDFree(PersistenceDiagram *pd);

#endif