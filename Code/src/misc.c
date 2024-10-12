/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 16:30:38
 *  Last modified : 12-10-2024 22:37:02
 *  File : misc.c
 */

#include <stdio.h>
#include <stdlib.h>

#include "geometry.h"

void print_err(char* str){
    fprintf(stderr, "[ERROR] %s", str);
}

// Copie une matrice
int **copy_matrix(int **t, int n){
    int **copy = malloc(n * sizeof(int*));
    for(int i = 0; i<n; i++){
        copy[i] = malloc(n * sizeof(int));
        for(int j = 0; j<n; j++){
            copy[i][j] = t[i][j];
        }
    }
    return copy;
}

// Affiche une matrice
void printMatrix(int **matrix, int n, int m){
    for(int i = 0; i<n; i++){
        for(int j = 0; j<m; j++){
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}