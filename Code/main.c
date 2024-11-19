/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-10-2024 17:08:19
 *  Last modified : 12-11-2024 15:49:25
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

    strcpy(pts_filename, "data/");
    strcpy(pd_filename, "exportedPD/");
    strcat(pts_filename, name);
    strcat(pd_filename, name);
    strcat(pts_filename, "_pts.txt");
    strcat(pd_filename, ".dat");
    
    char *dist_filename = NULL;
    if (!euclidean){
        dist_filename = malloc((strlen(name) + 15)*sizeof(char)); 
        strcpy(dist_filename, "data/");
        strcat(dist_filename, name);
        strcat(dist_filename, "_dist.txt");
    }

    // Routine principale
    PointCloud *X = pointCloudLoad(pts_filename, dist_filename);
    Filtration *filt = buildFiltration(X);
    PersistenceDiagram *pd = PDCreate(filt, X);
    
    PDExport(pd, pd_filename, false);

    PDFree(pd);
    filtrationFree(filt);
    pointCloudFree(X);
    free(pts_filename);
    free(dist_filename);
    free(pd_filename);
    return 0;
}