/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:01:34
 *  Last modified : 21-12-2024 16:20:10
 *  File : tests_persDiag.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "tests_persDiag.h"
#include "../src/persDiag.h"
#include "../src/geometry.h"

void tests_persDiag(){
    // Tests des dimensions de simplexes
    Simplex *s1 = simplexInit(0, -1, -1);   // Point
    Simplex *s2 = simplexInit(0, 1, -1);    // Arête
    Simplex *s3 = simplexInit(0, 1, 2);     // Triangle

    assert(dimSimplex(s1) == 0);
    assert(dimSimplex(s2) == 1);
    assert(dimSimplex(s3) == 2);

    // Tests de faces
    Simplex *s4 = simplexInit(0, 1, 2);
    Simplex *s5 = simplexInit(0, 1, 3);
    Simplex *s6 = simplexInit(2, 1, -1);

    assert(isFaceOf(s4, s5) == 0); // Pb de dimension
    assert(isFaceOf(s6, s4) == 1); // Ok
    assert(isFaceOf(s6, s5) == 0); // Pas une face

    simplexFree(s1);
    simplexFree(s2);
    simplexFree(s3);
    simplexFree(s4);
    simplexFree(s5);
    simplexFree(s6);

    // Tests boundary matrix
    // Création d'une filtration à la main dont on connait la matrice
    // basé sur https://iuricichf.github.io/ICT/algorithm.html
    
    // Correspond au tableau des vi
    int n = 11;
    Simplex **simPts = malloc(n*sizeof(Simplex *)); 
    for(int i=0; i<n; i++) simPts[i] = simplexInit(-1, -1, i);

    Simplex **simEdges = malloc(11*sizeof(Simplex *));
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

    int max_simplex = (n+1)*(n+1)*(n+1);
    Filtration *base_filt = filtrationInit(max_simplex);
    for(int i=0; i<3; i++) filtrationInsert(base_filt, simPts[i], n, 1, i);
    for(int i=3; i<7; i++) filtrationInsert(base_filt, simPts[i], n, 2, i);
    for(int i=0; i<5; i++) filtrationInsert(base_filt, simEdges[i], n, 2, i+7);
    for(int i=7; i<n; i++) filtrationInsert(base_filt, simPts[i], n, 3, i+5);
    for(int i=5; i<11; i++) filtrationInsert(base_filt, simEdges[i], n, 3, i+11);
    filtrationInsert(base_filt, f, n, 3, 22);

    int *reversed = reverseIdAndSimplex(base_filt);

    filtrationPrint(base_filt, n, true);

    // Matrice de bordure associée à la filtration
    int trueBoundary[23][23];
    for(int i=0; i<23; i++){
        for(int j=0; j<23; j++){
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

            if (condition) trueBoundary[i][j] = 1;
            else trueBoundary[i][j] = 0;
        }
    }

    int **testBoundary = buildBoundaryMatrix(reversed, base_filt->max_name, n);

    // Teste de l'égalité de la matrice
    for(int i=0; i<23; i++){
        for(int j=0; j<23; j++){
            if (trueBoundary[i][j] != testBoundary[i][j])
                printf("i=%d, j=%d %d %d\n", i, j, trueBoundary[i][j], testBoundary[i][j]);
            assert(testBoundary[i][j] == trueBoundary[i][j]);
        }
    } 

    int *test_low = buildLowMatrix(testBoundary, 23);

    // Vraie matrice low d'exemple
    int *true_low = malloc(23*sizeof(int));
    for(int i=0; i<23; i++){
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

    for(int j=0; j<23; j++)
        assert(test_low[j] == true_low[j]);

    // Tests de réduction de la matrice
    int **reduced = reduceMatrix(testBoundary, 23, test_low);
    int **true_reduced = malloc(23*sizeof(int *));
    for(int i=0; i<23; i++){
        true_reduced[i] = malloc(23*sizeof(int));
        for(int j=0; j<23; j++){
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

    for(int i=0; i<23; i++){
        for(int j=0; j<23; j++)
            assert(reduced[i][j] == true_reduced[i][j]);
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

    for(int j=0; j<23; j++)
        assert(true_low_reduced[j] == test_low[j]);

    // Tests de l'extraction des paires
    // int size_pairs;
    // Tuple *pairs = extractPairs(test_low, 23, &size_pairs);
    // Tuple true_pairs[10] = {{21, 22}, {15, 20}, {14, 19}, {13, 17}, {12, 16},
    //     {2, 11}, {4, 10}, {6, 9}, {5, 8}, {3, 7}};
        
    // int c = 0;
    // for(int i=0; i<size_pairs; i++)
    //     if (pairs[i].y != -1){
    //         assert(pairs[i].x == true_pairs[c].x && 
    //             pairs[i].y == true_pairs[c].y);
    //         c++;
    //     }

    // Tests de l'extraction des paires par rapport à la filtration initiale
    unsigned long long size_pairs_filt;
    Tuple *pairs_filt = extractPairsFilt(test_low, base_filt, &size_pairs_filt,
        reversed);
    Tuple pair = {1, 2};
    unsigned long long c = 0;

    for(unsigned long long i=0; i<size_pairs_filt; i++){
        if (pairs_filt[i].y != -1){
            assert(c==0);
            assert(base_filt->filt[pairs_filt[i].x] == pair.x && 
                base_filt->filt[pairs_filt[i].y] == pair.y);
            c++;
        }
    }

    // Tests de création de diagramme de persistance
    PointCloud *X = pointCloudInit(11);
    
    // On se fiche de la valeur des points pour l'instant
    for(int i=0; i<11; i++)
        X->pts[i] = (Point) {0, 0}; 
    
    
    PersistenceDiagram *pd = PDCreate(base_filt, X);

    c = 0;
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        if (pd->pairs[i].y != -1){
            assert(pd->pairs[i].x == pair.x && 
                pd->pairs[i].y == pair.y);
                // printf("%d %d\n", pd->pairs[i].x, pd->pairs[i].y);
            c++;
        }
    }

    // Tests de l'exportation
    PDExport(pd, "exportedPD/test.dat", "exportedPD/test_death.txt", true);

    // Libération de la mémoire
    for(int i=0; i<11; i++) simplexFree(simPts[i]);
    for(int i=0; i<11; i++) simplexFree(simEdges[i]);
    simplexFree(f);
    free(simPts);
    free(simEdges);
    free(true_low);
    free(true_low_reduced);
    free(test_low);
    free(reversed);
    for(int i=0; i<23; i++){
        free(testBoundary[i]);
        free(reduced[i]);
    }
    free(true_reduced);
    free(testBoundary);
    free(reduced);
    // free(pairs);
    free(pairs_filt);
    PDFree(pd);
    free(X->pts);
    free(X);
    filtrationFree(base_filt);
}