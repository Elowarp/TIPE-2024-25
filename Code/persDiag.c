/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:33:19
 *  Last modified : 14-09-2024 22:50:17
 *  File : persDiag.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "structures/geometry.h"
#include "persDiag.h"

PointCloud *pointCloudLoad(char *filename){
    FILE *file = fopen(filename, "r");
    if(file == NULL){
        fprintf(stderr, "Erreur: fichier introuvable %s\n", filename);
        exit(1);
    }

    int size;
    fscanf(file, "%d", &size);
    PointCloud *pointCloud = pointCloudInit(size);

    for(int i = 0; i < size; i++){
        fscanf(file, "%f %f", &(pointCloud->pts[i].x), &(pointCloud->pts[i].y));
    }

    fclose(file);
    return pointCloud;
};

int main(){
    PointCloud *pointCloud = pointCloudLoad("data/example.dat");
    
    for(int i = 0; i < pointCloud->size; i++){
        printf("%f %f\n", pointCloud->pts[i].x, pointCloud->pts[i].y);
    }

    pointCloudFree(pointCloud);
    return 0;
}