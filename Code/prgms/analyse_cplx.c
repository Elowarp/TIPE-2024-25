/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-04-2025 22:30:19
 *  Last modified : 25-04-2025 21:05:27
 *  File : analyse_cplx.c
 *  Ce fichier a pour but de produire un fichier sur différents temps 
 *  d'exécution en fonction de la version de réduction
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "../src/geometry.h"
#include "../src/persDiag.h"

// Crée un nuage de n points aléatoire 
PointCloud *create_random(int n){
    PointCloud *X = pointCloudInit(n);
    for(int i=0; i<n; i++){
        X->pts[i].x = rand()%100;
        X->pts[i].y = rand()%100;
        X->weights[i] = rand()%50;
    }

    return X;
}


int main(){
    int seed = 0;
    srand(seed);

    int nb_sizes = 11;
    int sizes[11] = {5, 10, 20, 30, 40, 50, 60, 65, 70, 75, 80};
   
    
    FILE *file = fopen("times_cmpx.dat", "w");
    for(int i=7; i<nb_sizes; i++){
        printf("Traitement taille=%d\n", sizes[i]);
        PointCloud *X = create_random(sizes[i]);
        Filtration *f = buildFiltration(X);     
        
        printf("Debut V1\n");
        clock_t start_V1 = clock();
        PDCreateV1(f, X);
        clock_t end_V1 = clock();

        printf("Debut V2\n");
        clock_t start_V2 = clock();
        PDCreateV2(f, X);
        clock_t end_V2 = clock();

        double elapV1 = (double)(end_V1 - start_V1)/CLOCKS_PER_SEC;
        double elapV2 = (double)(end_V2 - start_V2)/CLOCKS_PER_SEC;
        filtrationFree(f);
        pointCloudFree(X);
        fprintf(file, "%d %f %f\n", sizes[i], elapV1, elapV2);
        fflush(file);
        printf("Fin traitement\n");
    }
    
    fclose(file);
}