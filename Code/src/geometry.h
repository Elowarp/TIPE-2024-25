/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:49
 *  Last modified : 23-04-2025 21:52:06
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

// Un simplexe est défini par une figure à au plus 3 sommets
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
    unsigned long long *nums; // N[i] = k si le simplexe i est le k-ième simplexe ajouté
    int size;
    unsigned long long max_name;
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

// Simplexes
extern Simplex *simplexInit(int i, int j, int k);
extern int simplexId(Simplex *s, int n);
extern Simplex simplexFromId(int id, int n);
extern void simplexFree(Simplex *s);
extern unsigned long long simplexMax(int n);
extern void simplexPrint(Simplex *s);
extern int dimSimplex(Simplex *s);
extern bool isFaceOf(Simplex *s1, Simplex *s2);

// Simplicial complexes
extern SimComplex *simComplexInit(unsigned long long n);
extern void simComplexInsert(SimComplex *cmpx, Simplex *s, int n);
extern void simComplexFree(SimComplex *cmpx);
extern bool simComplexContains(SimComplex *cmpx, Simplex *s, int n);

// Filtrations
extern Filtration *filtrationInit(unsigned long long size);
extern void filtrationFree(Filtration *filtration);
extern void filtrationInsert(Filtration *filtration, Simplex *s, int n, int k, 
    unsigned long long num);
extern bool filtrationContains(Filtration *filtration, Simplex *s, int n);
extern void filtrationPrint(Filtration *filt, int n, bool sorted);
extern void filtrationToFile(Filtration *filtration, Point* pts, int n, char *filename);
extern unsigned long long filtrationMaxName(Filtration *filtration);
int *reverseIdAndSimplex(Filtration *filt);

#endif