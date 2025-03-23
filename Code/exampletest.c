#include <stdio.h>
#include <stdlib.h>

#include "src/persDiag.h"
#include "src/geometry.h"
#include "src/misc.h"

int main(){
    int n = 4;
    Simplex **simPts = malloc(n*sizeof(Simplex *)); 
    for(int i=0; i<n; i++) simPts[i] = simplexInit(-1, -1, i);

    Simplex **simEdges = malloc(5*sizeof(Simplex *));
    simEdges[0] = simplexInit(-1, 0, 1);
    simEdges[1] = simplexInit(-1, 1, 2);
    simEdges[2] = simplexInit(-1, 2, 3);
    simEdges[3] = simplexInit(-1, 3, 0);
    simEdges[4] = simplexInit(-1, 0, 2);

    Simplex **simFaces = malloc(2*sizeof(Simplex *));
    simFaces[0] = simplexInit(0, 1, 2);
    simFaces[1] = simplexInit(0, 2, 3);

    int max_simplex = simplexMax(n);
    Filtration *base_filt = filtrationInit(max_simplex);
    for (int i=0; i<n; i++)
        filtrationInsert(base_filt, simPts[i], n, 0, i);
    for (int i=0; i<3; i++)
        filtrationInsert(base_filt, simEdges[i], n, 1, i+4);

    filtrationInsert(base_filt, simEdges[3], n, 2, 7);
    filtrationInsert(base_filt, simEdges[4], n, 3, 8);
    filtrationInsert(base_filt, simFaces[0], n, 3, 9);
    filtrationInsert(base_filt, simFaces[1], n, 4, 10);
    
    int *reverse = reverseIdAndSimplex(base_filt);
    int **boundary = buildBoundaryMatrix(reverse, base_filt->max_name, n);

    printf("Matrice B\n");
    printMatrix(boundary, base_filt->max_name, base_filt->max_name);

    int *low = buildLowMatrix(boundary, base_filt->max_name);
    printf("Low\n");
    printMatrix(&low, 1, base_filt->max_name);

    int **reduced = reduceMatrix(boundary, base_filt->max_name, low);
    printf("Matrice Bbar\n");
    printMatrix(reduced, base_filt->max_name, base_filt->max_name);

    int *low_reduced = buildLowMatrix(reduced, base_filt->max_name);
    printf("Low reduced\n");
    printMatrix(&low_reduced, 1, base_filt->max_name);

    PersistenceDiagram *pd = malloc(sizeof(PersistenceDiagram));

    // Extraction des paires
    Tuple *pairs = extractPairsFilt(low, base_filt, &(pd->size_pairs),
        reverse);

    // Assignation du rang d'apparition des simplexes dans la filtration 
    // depuis la liste de paires
    pd->pairs = malloc(pd->size_pairs * sizeof(Tuple));
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        pd->pairs[i].x = base_filt->filt[pairs[i].x];

        if (pairs[i].y != -1)
            pd->pairs[i].y = base_filt->filt[pairs[i].y];
        else
            pd->pairs[i].y = -1;
    }


    // Récupération des dimensions des simplexes et donc catégorises les 
    // classes d'homologie
    
    printf("Affichage des simplexes tuant des 1D homologies\n");
    pd->dims = malloc(pd->size_pairs * sizeof(int));
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        Simplex s = simplexFromId(pairs[i].x, n);
        
        pd->dims[i] = dimSimplex(&s);
        if(dimSimplex(&s) == 1) pd->size_death1D++;
    }
    
    // Rajoute les temps de naissance des tueurs de classes 1D 
    pd->death1D = malloc(pd->size_death1D * sizeof(Simplex));
    int c = 0;
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        Simplex s = simplexFromId(pairs[i].x, n);
        Simplex death_s = simplexFromId(pairs[i].y, n);
        if(dimSimplex(&s) == 1)
        {
            pd->death1D[c] = death_s;
            c++;
        }
    }

    PDExport(pd, "testpd.dat", "testpddeath.dat", true);
}