/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 16:30:38
 *  Last modified : 08-10-2024 15:27:07
 *  File : misc.c
 */

#include <stdio.h>
#include <stdlib.h>

#include "structures/geometry.h"

void print_err(char* str){
    fprintf(stderr, "[ERROR] %s", str);
}

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

// Liste de triangle vers fichier texte
void triangleListToFile(TriangleList *list, Point* pts, int n, char *filename){
    FILE *f = fopen(filename, "w"); 
    if (f == NULL) {
        printf("Impossible d'ouvrir le fichier !\n");
        exit(1);
    }

    // Ecriture des points dans le fichier
    for(int i=0;i<n;i++){
        fprintf(f, "v %d %f %f\n", i, pts[i].x, pts[i].y);
    }

    // Ecriture des faces dans le fichier
    TriangleList *current = list;
    while(current != NULL){
        fprintf(f, "t %d %d %d\n", current->t->p1,
                        current->t->p2,
                        current->t->p3);
        current = current->next;
    }

    fclose(f);
}

void filtrationToFile(Filtration *filtration, Point* pts, int n, char *filename){
    FILE *f = fopen(filename, "w");
    if (f == NULL) {
        printf("Impossible d'ouvrir le fichier !\n");
        exit(1);
    }

    // Ecriture des points dans le fichier
    for(int i=0;i<n;i++){
        fprintf(f, "v %d %f %f\n", i, pts[i].x, pts[i].y);
    }

    // Ecriture des faces dans le fichier
    for(int i=0;i<filtration->size;i++){
        if(filtration->filt[i] != -1){
            Simplex s = simplexFromId(i, n);
            fprintf(f, "t %d %d %d %d\n", s.i, s.j, s.k, filtration->nums[i]);
        }
    }

    fclose(f);

}