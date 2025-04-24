/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 23-04-2025 20:33:47
 *  Last modified : 24-04-2025 21:27:05
 *  File : tests_reduc.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "tests_reduc.h"
#include "../src/geometry.h"
#include "../src/reduc.h"
#include "../src/misc.h"

void tests_reduc(){
    printf("--- Tests reduc.h ---\n");
    
    int N = 11; // Nombre de points
    int n = 23; // Nombre de simplexes

    // Filtration sur laquelle les tests se reposent 
    // basé sur https://iuricichf.github.io/ICT/algorithm.html
    Simplex **simPts = malloc(N*sizeof(Simplex *)); 
    for(int i=0; i<N; i++) simPts[i] = simplexInit(-1, -1, i);

    Simplex **simEdges = malloc(N*sizeof(Simplex *));
    simEdges[0] = simplexInit(-1, 0, 3);
    simEdges[1] = simplexInit(-1, 1, 5);
    simEdges[2] = simplexInit(-1, 2, 6);
    simEdges[3] = simplexInit(-1, 3, 4);
    simEdges[4] = simplexInit(-1, 5, 6);
    simEdges[5] = simplexInit(-1, 3, 7);
    simEdges[6] = simplexInit(-1, 3, 8);
    simEdges[7] = simplexInit(-1, 8, 4);
    simEdges[8] = simplexInit(-1, 9, 5);
    simEdges[9] = simplexInit(-1, 10, 6);
    simEdges[10] = simplexInit(-1, 7, 8);

    Simplex *f = simplexInit(3, 7, 8); // Face

    Filtration *base_filt = filtrationInit(simplexMax(N));
    for(int i=0; i<3; i++) filtrationInsert(base_filt, simPts[i], N, 1, i);
    for(int i=3; i<7; i++) filtrationInsert(base_filt, simPts[i], N, 2, i);
    for(int i=0; i<5; i++) filtrationInsert(base_filt, simEdges[i], N, 2, i+7);
    for(int i=7; i<N; i++) filtrationInsert(base_filt, simPts[i], N, 3, i+5);
    for(int i=5; i<N; i++) filtrationInsert(base_filt, simEdges[i], N, 3, i+11);
    filtrationInsert(base_filt, f, N, 3, 22);

    int *reversed = reverseIdAndSimplex(base_filt);

    // Matrice de bordure associée à une filtration
    int **trueBoundary = calloc(n, sizeof(int*));
    boundary_mat B = boundary_init(n); // Temporaire, à remplacer par testB1 plus bas
    
    // Calcule la véritable matrice de bordure
    for(int i=0; i<n; i++){
        trueBoundary[i] = calloc(n, sizeof(int));
        for(int j=0; j<n; j++){
            bool condition = 
                (i==0 && j==7) || 
                (i==1 && j==8) || 
                (i==2 && j==9) || 
                (i==3 && j==7) || (i==3 && j==10) || (i==3 && j==16) || (i==3 && j==17) ||
                (i==4 && j==10) || (i==4 && j==18) ||
                (i==5 && j==8) || (i==5 && j==11) || (i==5 && j==19) ||
                (i==6 && j==9) || (i==6 && j==11) || (i==6 && j==20) ||
                (i==12 && j==16) || (i==12 && j==21) ||
                (i==13 && j==17) || (i==13 && j==18) || (i==13 && j==21) ||
                (i==14 && j==19) || 
                (i==15 && j==20) ||
                (i==16 && j==22) ||
                (i==17 && j==22) ||
                (i==21 && j==22);

            if (condition){
                trueBoundary[i][j] = 1;
                append_list(B.s[j], i);
            }
            else trueBoundary[i][j] = 0;
        }
    }

    // Teste la construction de la matrice de bordure
    // Version 1
    int **testB1 = buildBoundaryMatrix(reversed, base_filt->max_name, N);
    for(int i=0; i<base_filt->max_name; i++){
        for(int j=0; j<base_filt->max_name; j++){
            assert(testB1[i][j] == trueBoundary[i][j]);
        }
    } 

    // Test la construction de la matrice de bordure
    // Version 2
    boundary_mat testB2_bound = buildBoundaryMatrix2(reversed, base_filt->max_name, N);
    int **testB2 = boundary_to_mat(testB2_bound);
    for(int i=0; i<base_filt->max_name; i++){
        for(int j=0; j<base_filt->max_name; j++){
            assert(testB2[i][j] == trueBoundary[i][j]);
        }
    } 

    // Teste si low est correcte
    // Vraie matrice low d'exemple
    int *true_low = malloc(n*sizeof(int));
    for(int i=0; i<n; i++){
        true_low[i] = -1;
    }
    true_low[7] = 3;
    true_low[8] = 5;
    true_low[9] = 6;
    true_low[10] = 4;
    true_low[11] = 6;
    true_low[16] = 12;
    true_low[17] = 13;
    true_low[18] = 13;
    true_low[19] = 14;
    true_low[20] = 15;
    true_low[21] = 13;
    true_low[22] = 21;

    int *test_lowV1 = buildLowMatrix(testB1, n);
    int *test_lowV2 = buildLowMatrix(testB2, n);
    for(int j=0; j<23; j++){
        assert(test_lowV1[j] == true_low[j]);
        assert(test_lowV2[j] == true_low[j]);

    }

    // Teste si la liste de listes par dimension est bonne :
    int D = 2; // Nombre de dimensions des simplexes 
    db_int_list **dims = simpleByDims(B, reversed, N);
    for(int i=0; i<=DIM; i++){
        printf("Les simplexes de dimension %d :\n", i);
        print_list(dims[i]);
    }

    // Teste la réduction
    // Véritable matrice réduite
    int **true_reduced = malloc(n*sizeof(int *));
    for(int i=0; i<n; i++){
        true_reduced[i] = malloc(n*sizeof(int));
        for(int j=0; j<n; j++){
            bool condition = 
                (i==0 && j==7) || 
                (i==1 && j==8) || (i==1 && j==11) ||
                (i==2 && j==9) || (i==2 && j==11) ||
                (i==3 && j==7) || (i==3 && j==10) || (i==3 && j==16) || (i==3 && j==17) ||
                (i==4 && j==10) ||
                (i==5 && j==8) || (i==5 && j==19) ||
                (i==6 && j==9) || (i==6 && j==20) ||
                (i==12 && j==16) ||
                (i==13 && j==17) ||
                (i==14 && j==19) || 
                (i==15 && j==20) ||
                (i==16 && j==22) ||
                (i==17 && j==22) ||
                (i==21 && j==22);
            if (condition) true_reduced[i][j] = 1;
            else true_reduced[i][j] = 0;
        }
    }

    printf("Matrice de bordure : \n");
    printMatrix(trueBoundary, n, n);

    // Teste si la matrice de la V1 est bien réduite
    int *low = buildLowMatrix(trueBoundary, n);
    int **reducedV1 = reduceMatrix(trueBoundary, n, low);
    for(int i=0; i<n; i++){
        for(int j=0; j<n; j++)
            assert(reducedV1[i][j] == true_reduced[i][j]);
    }

    // Teste si la matrice de la V2 est bien réduite
    reduceMatrixOptimized(testB2_bound, dims);
    printf("Affichage de la matrice réduite : \n");
    print_boundary(testB2_bound);
    
    int **reducedV2 = boundary_to_mat(testB2_bound);
    for(int i=0; i<n; i++){
        for(int j=0; j<n; j++)
            assert(reducedV2[i][j] == true_reduced[i][j]);
    }

    // Tests de low après réduction
    int *true_low_reduced = malloc(23*sizeof(int));
    for(int i=0; i<23; i++){
        true_low_reduced[i] = -1;
    }
    true_low_reduced[7] = 3;
    true_low_reduced[8] = 5;
    true_low_reduced[9] = 6;
    true_low_reduced[10] = 4;
    true_low_reduced[11] = 2;
    true_low_reduced[16] = 12;
    true_low_reduced[17] = 13;
    true_low_reduced[19] = 14;
    true_low_reduced[20] = 15;
    true_low_reduced[22] = 21;

    int *test_low_reducedV1 = buildLowMatrix(reducedV1, n);
    int *test_low_reducedV2 = buildLowMatrix(reducedV2, n);

    for(int j=0; j<23; j++){
        assert(true_low_reduced[j] == test_low_reducedV1[j]);
        assert(true_low_reduced[j] == test_low_reducedV2[j]);

    }


    // Libérations
    for(int i=0; i<N; i++){
        free(simPts[i]);
        free(simEdges[i]);
    }
    free(f);
    filtrationFree(base_filt);
    free(reversed);
    for(int i=0; i<n; i++){
        free(trueBoundary[i]);
        free(testB1[i]);
        free(testB2[i]);
    }
    free(trueBoundary);
    free_boundary(B);
    free(testB1);
    free(testB2);
    free_boundary(testB2_bound);
    free(true_low);
    free(test_lowV1);
    free(test_lowV2);
    for(int i=0; i<n; i++){
        free(true_reduced[i]);
        free(reducedV1[i]);
        free(reducedV2[i]);
    }
    for(int i=0; i<=D; i++)
        free_list(dims[i]);
    free(dims);
    free(low);
    free(true_low_reduced);
    free(test_low_reducedV1);
    free(test_low_reducedV2);
}