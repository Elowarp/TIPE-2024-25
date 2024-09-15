/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:49
 *  Last modified : 15-09-2024 16:46:00
 *  File : geometry.h
 */
#ifndef GEOMETRY_H
#define GEOMETRY_H

#include <stdbool.h>

extern const int DIM;

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

extern float dist_euclidean(Point p1, Point p2);
extern float dist(Point p1, Point p2);
extern void pointPrint(Point p);

extern EdgeList *edgeListInit();
extern FaceList *faceListInit();
extern PointCloud *pointCloudInit(int size);
extern SimComplex *simComplexInit();
extern Filtration *filtrationInit(SimComplex *cmpx);

extern bool pointAreEqual(Point p1, Point p2);

extern void edgeInsert(EdgeList *edgeList, int p1, int p2, float weight);
extern void faceInsert(FaceList *faceList, int p1, int p2, int p3);
 
extern SimComplex *simComplexCopy(SimComplex *cmpx);
 
extern void simComplexInsert(Filtration *filtration, SimComplex *cmpx);
 
extern void pointCloudFree(PointCloud *pointCloud);
extern void edgeListFree(EdgeList *edgeList);
extern void faceListFree(FaceList *faceList);
extern void simComplexFree(SimComplex *cmpx);
extern void filtrationFree(Filtration *filtration);

#endif