/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:23:55
 *  Last modified : 14-09-2024 22:50:06
 *  File : persDiag.h
 */
#ifndef PERSDIAG_H
#define PERSDIAG_H

#include "structures/geometry.h"

typedef struct {
    Point *pts;
    int size;
} PersistenceDiagram;

PointCloud *pointCloudLoad(char *filename);

void FindPersistentHomology(PointCloud X);

PersistenceDiagram *PDCreate(Filtration *filtration);
void PDExport(PersistenceDiagram *pd, char *filename);
void PDFree(PersistenceDiagram *pd);

#endif