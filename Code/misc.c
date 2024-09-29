/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 16:30:38
 *  Last modified : 29-09-2024 15:54:49
 *  File : misc.c
 */

#include <stdio.h>
#include <stdlib.h>

#include "structures/geometry.h"

void print_err(char* str){
    fprintf(stderr, "[ERROR] %s", str);
}

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
