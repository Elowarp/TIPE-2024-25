/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:01:34
 *  Last modified : 23-04-2025 22:48:26
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
    // Tests boundary matrix
    // Création d'une filtration à la main dont on connait la matrice
    // basé sur https://iuricichf.github.io/ICT/algorithm.html
    
    // Définition de la filtration 
    int N = 11; // Nombre de points dans la filtration
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

    int max_simplex = (N+1)*(N+1)*(N+1);
    Filtration *base_filt = filtrationInit(max_simplex);
    for(int i=0; i<3; i++) filtrationInsert(base_filt, simPts[i], N, 1, i);
    for(int i=3; i<7; i++) filtrationInsert(base_filt, simPts[i], N, 2, i);
    for(int i=0; i<5; i++) filtrationInsert(base_filt, simEdges[i], N, 2, i+7);
    for(int i=7; i<N; i++) filtrationInsert(base_filt, simPts[i], N, 3, i+5);
    for(int i=5; i<N; i++) filtrationInsert(base_filt, simEdges[i], N, 3, i+11);
    filtrationInsert(base_filt, f, N, 3, 22);

    int *reversed = reverseIdAndSimplex(base_filt);

    filtrationPrint(base_filt, N, true);

    int *low = malloc(base_filt->max_name*sizeof(int));
    for(int i=0; i<base_filt->max_name; i++){
        low[i] = -1;
    }
    low[7] = 3;
    low[8] = 5;
    low[9] = 6;
    low[10] = 4;
    low[11] = 6;
    low[16] = 12;
    low[17] = 13;
    low[18] = 13;
    low[19] = 14;
    low[20] = 15;
    low[21] = 13;
    low[22] = 21;

    // Tests de l'extraction des paires par rapport à la filtration initiale
    unsigned long long size_pairs_filt;
    Tuple *pairs_filt = extractPairsFilt(low, base_filt, &size_pairs_filt,
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
    PointCloud *X = pointCloudInit(N);
    
    // On se fiche de la valeur des points pour l'instant
    for(int i=0; i<N; i++)
        X->pts[i] = (Point) {0, 0}; 
    
    
    PersistenceDiagram *pd = PDCreate(base_filt, X);

    c = 0;
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        if (pd->pairs[i].y != -1){
            assert(pd->pairs[i].x == pair.x && 
                pd->pairs[i].y == pair.y);
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
    free(reversed);
    free(low);
    free(pairs_filt);
    PDFree(pd);
    free(X->pts);
    free(X);
    filtrationFree(base_filt);
}