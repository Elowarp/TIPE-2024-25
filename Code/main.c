/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:08:19
 *  Last modified : 25-04-2025 21:22:21
 *  File : main.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "src/geometry.h"
#include "src/persDiag.h"
#include "src/misc.h"

int main(int argc, char *argv[]){
    if (argc<2){
        print_err("Il faut un nom de ville !\n");
        return 1;
    } 

    bool euclidean = false;
    char *name = malloc((strlen(argv[1])+1)*sizeof(char));
    strcpy(name, argv[1]);

    if (argc==3) {
        if (strcmp(argv[1], "-e")!=0) {
            print_err("Trop d'options ! -e pour choisir des distances euclidiennes\n");
            return 1;
        } else {
            name = realloc(name, (strlen(argv[2])+1)*sizeof(char));
            strcpy(name, argv[2]);
            euclidean = true;
        }
    }
    
    char *pts_filename = malloc((strlen(name) + 14)*sizeof(char)); 
    char *pd_filename = malloc((strlen(name) + 16)*sizeof(char));
    char *death_filename = malloc((strlen(name) + 22)*sizeof(char));

    strcpy(pts_filename, "data/");
    strcpy(pd_filename, "exportedPD/");
    strcpy(death_filename, "exportedPD/");
    strcat(pts_filename, name);
    strcat(pd_filename, name);
    strcat(death_filename, name);
    strcat(pts_filename, "_pts.txt");
    strcat(pd_filename, ".dat");
    strcat(death_filename, "_death.txt");
    
    char *dist_filename = NULL;
    if (!euclidean){
        dist_filename = malloc((strlen(name) + 15)*sizeof(char)); 
        strcpy(dist_filename, "data/");
        strcat(dist_filename, name);
        strcat(dist_filename, "_dist.txt");
    }

    // Routine principale
    printf("Chargement de l'ensemble des points...\n");
    PointCloud *X = pointCloudLoad(pts_filename, dist_filename);
    printf("Construction d'une filtration...\n");
    Filtration *filt = buildFiltration(X);
    printf("Construction du diagramme de persistance...\n");
    PersistenceDiagram *pd = PDCreateV1(filt, X);
    
    printf("Exportation du diagramme de persistance...\n");
    PDExport(pd, pd_filename, death_filename, false);

    PDFree(pd);
    filtrationFree(filt);
    pointCloudFree(X);
    free(pts_filename);
    free(dist_filename);
    free(pd_filename);
    free(death_filename);
    free(name);
    printf("Fin des calculs et de l'exportation\n");
    return 0;
}