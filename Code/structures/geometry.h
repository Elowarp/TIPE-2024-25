/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:49
 *  Last modified : 29-09-2024 16:05:46
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

typedef struct edge_t { // On stocke les indices des points
    int p1;
    int p2;
    float weight;
    struct edge_t *next;
} EdgeList;

typedef struct { // On stocke les indices des points
    int p1;
    int p2;
    int p3;
} Triangle;

typedef struct TriangleList_t { // Liste doublement chainée
    Triangle *t;
    struct TriangleList_t *next;
    struct TriangleList_t *prev;
} TriangleList;

typedef struct {
    Point *p1;
    Point *p2;
    Point *p3;
} Face;

typedef struct faceList_t {
    Face *face;
    struct faceList_t *next;
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

// Math
extern float dist_euclidean(Point p1, Point p2);
extern float dist(Point p1, Point p2);

// Points
extern void pointPrint(Point p);
extern bool pointAreEqual(Point p1, Point p2);
extern PointCloud *pointCloudInit(int size);
extern void pointCloudFree(PointCloud *pointCloud);

// Edges 
extern EdgeList *edgeListInit(int p1, int p2, float weight);
extern void edgeListFree(EdgeList *edgeList);
extern void edgeListInsert(EdgeList *edgeList, int p1, int p2, float weight);
extern int edgeListCount(EdgeList *edgeList, EdgeList *edge);
extern EdgeList *edgeListRemove(EdgeList *edgeList, EdgeList *edge);
extern EdgeList *removeDoubledEdges(EdgeList *edges);

// Triangles
extern Triangle *createTriangle(int p1, int p2, int p3);
extern bool triangleAreEqual(Triangle *t1, Triangle *t2);
extern void trianglePrint(Triangle *t);
extern TriangleList *triangleListInit(Triangle *t);
extern TriangleList *triangleListInsert(TriangleList *list, Triangle *t);
extern TriangleList *triangleListRemove(TriangleList *list, Triangle *t);
extern void triangleListFree(TriangleList *list);
extern void triangleListPrint(TriangleList *list);
extern int triangleListLength(TriangleList *list);

// Circles
extern void circumCircle(Triangle *t, Point *pts, Point *center, float *radius);
extern bool inCircle(Point *center, float radius, Point *p);

// Faces
extern FaceList *faceListInit();
extern void faceInsert(FaceList *faceList, int p1, int p2, int p3);
extern void faceListFree(FaceList *faceList);

// Simplicial complexes
extern SimComplex *simComplexInit();
extern void simComplexInsert(Filtration *filtration, SimComplex *cmpx);
extern SimComplex *simComplexCopy(SimComplex *cmpx);
extern void simComplexFree(SimComplex *cmpx);

// Filtrations
extern Filtration *filtrationInit(SimComplex *cmpx);
extern void filtrationFree(Filtration *filtration);

#endif