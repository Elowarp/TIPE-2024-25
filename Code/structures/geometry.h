/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:49
 *  Last modified : 14-09-2024 22:16:51
 *  File : geometry.h
 */
#ifndef GEOMETRY_H
#define GEOMETRY_H

typedef struct {
    float x;
    float y;
} Point;

typedef struct {
    Point *pts;
    float *weights;
    int size;
} PointCloud;

typedef struct edge_t {
    int p1;
    int p2;
    float weight;
    struct edge_t *next;
} EdgeList;

typedef struct face_t {
    int p1;
    int p2;
    int p3;
    struct face_t *next;
} FaceList;

typedef struct {
    Point *pts;
    EdgeList *edges;
    FaceList *faces;
} SimComplex;

// Liste chainée de complexes simpliciaux
typedef struct Filtration_t {
    SimComplex *complex;
    struct Filtration_t *next;
} Filtration;


EdgeList *edgeListInit();
FaceList *faceListInit();
PointCloud *pointCloudInit(int size);
SimComplex *simComplexInit();
Filtration *filtrationInit(SimComplex *cmpx);

void edgeInsert(EdgeList *edgeList, int p1, int p2, float weight);
void faceInsert(FaceList *faceList, int p1, int p2, int p3);

SimComplex *simComplexCopy(SimComplex *cmpx);

void simComplexInsert(Filtration *filtration, SimComplex *cmpx);

void pointCloudFree(PointCloud *pointCloud);
void edgeListFree(EdgeList *edgeList);
void faceListFree(FaceList *faceList);
void simComplexFree(SimComplex *cmpx);
void filtrationFree(Filtration *filtration);

#endif