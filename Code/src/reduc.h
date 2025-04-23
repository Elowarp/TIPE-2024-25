/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 22-04-2025 20:23:49
 *  Last modified : 23-04-2025 22:55:29
 *  File : reduc.h
 */
#ifndef REDUC_H
#define REDUC_H

#include "list.h"

typedef struct {
    int n; // Longueur de la liste de sommmets s
    db_int_list **s;

} boundary_mat;

// Version 1 de la reduction
int *buildLowMatrix(int **boundary, unsigned long long n);
int **buildBoundaryMatrix(int *reversed, unsigned long long max_name, int nb_pts);
int **reduceMatrix(int **boundary, unsigned long long n, int *low);

// Version 2 de la reduction
boundary_mat buildBoundaryMatrix2(int *reversed, unsigned long long max_name, int nb_pts);
int get_low(boundary_mat B, int j);
void reduceMatrixOptimized(boundary_mat B, db_int_list **simplexes_by_dims);
db_int_list **simpleByDims(boundary_mat B, int *reversed, int n, int D);

// Misc
boundary_mat boundary_init(int n);
void free_boundary(boundary_mat B);
void print_boundary(boundary_mat B);
int **boundary_to_mat(boundary_mat B);

#endif