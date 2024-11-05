/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:49
 *  Last modified : 05-11-2024 17:14:58
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
    float **dist;
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

// Un simplexe est défini par une figure à au plus 3 sommets
// et au plus une face
typedef struct {
    int i;
    int j;
    int k;
} Simplex;

typedef struct {
    bool *simplices;
    int size;
} SimComplex;

typedef struct {
    int *x;
    int *y;
    int size;
} Tuples;

typedef struct {
    int *filt; // F[i] = k si le simplexe i est dans le complexe k
    int *nums; // N[i] = k si le simplexe i est le k-ième simplexe ajouté
    int size;
} Filtration;

// Math
extern float dist_euclidean(int p1, int p2, PointCloud *X);
extern float dist(int p1, int p2, PointCloud *X);

// Points
extern void pointPrint(Point p);
extern bool pointAreEqual(Point p1, Point p2);
extern PointCloud *pointCloudInit(int size);
extern void pointCloudFree(PointCloud *pointCloud);
extern PointCloud *pointCloudLoad(char *filename, char *dist_filename);
void pointCloudPrint(PointCloud *X);

// Edges 
extern EdgeList *edgeListInit(int p1, int p2, float weight);
extern void edgeListFree(EdgeList *edges);
extern void edgeListInsert(EdgeList *edges, int p1, int p2, float weight);
extern int edgeListCount(EdgeList *edges, EdgeList *edge);
extern EdgeList *edgeListRemove(EdgeList *edges, EdgeList *edge);
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
extern void triangleListToFile(TriangleList *list, Point *pts, int n, char *filename);

// Circles
extern void circumCircle(Triangle *t, Point *pts, Point *center, float *radius);
extern bool inCircle(Point *center, float radius, Point *p);

// Faces
extern FaceList *faceListInit();
extern void faceInsert(FaceList *faceList, int p1, int p2, int p3);
extern void faceListFree(FaceList *faceList);

// Simplexes
extern Simplex *simplexInit(int i, int j, int k);
extern int simplexId(Simplex *s, int n);
extern Simplex simplexFromId(int id, int n);
extern void simplexFree(Simplex *s);
extern int simplexMax(int n);
extern void simplexPrint(Simplex *s);
extern int dimSimplex(Simplex *s);
extern bool isFaceOf(Simplex *s1, Simplex *s2);

// Simplicial complexes
extern SimComplex *simComplexInit(int n);
extern void simComplexInsert(SimComplex *cmpx, Simplex *s, int n);
extern void simComplexFree(SimComplex *cmpx);
extern bool simComplexContains(SimComplex *cmpx, Simplex *s, int n);

// Filtrations
extern Filtration *filtrationInit(int size);
extern void filtrationFree(Filtration *filtration);
extern void filtrationInsert(Filtration *filtration, Simplex *s, int n, int k, int num);
extern bool filtrationContains(Filtration *filtration, Simplex *s, int n);
extern void filtrationPrint(Filtration *filt, int n, bool sorted);
extern int *reverseIdAndSimplex(Filtration *filt, int max_nums);
extern void filtrationToFile(Filtration *filtration, Point* pts, int n, char *filename);
extern int filtrationMaxName(Filtration *filtration);

#endif