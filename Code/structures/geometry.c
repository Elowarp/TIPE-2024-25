/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 13:55:46
 *  Last modified : 15-09-2024 16:44:17
 *  File : geometry.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "geometry.h"

const int DIM = 2;

// Renvoie la distance euclidienne entre deux points
float dist_euclidean(Point p1, Point p2){
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y-p1.y, 2));
}

// Renvoie la distance entre deux points
// Cette fonction sert d'interface pour que l'on puisse facilement
// la modifier lors de l'application de notre programme à un sujet
float dist(Point p1, Point p2){
    return dist_euclidean(p1, p2);
}

// Affiche un point
void pointPrint(Point p){
    printf("(%f, %f)", p.x, p.y);
}

// Initialise un nuage de points
PointCloud *pointCloudInit(int size){
    PointCloud *pointCloud = malloc(sizeof(PointCloud));
    pointCloud->pts = malloc(size * sizeof(Point));
    pointCloud->weights = malloc(size * sizeof(float));
    pointCloud->size = size;
    return pointCloud;
};

// Teste si deux points sont égaux
bool pointAreEqual(Point p1, Point p2){
    return p1.x == p2.x && p1.y == p2.y;
};

// Libère un nuage de points
void pointCloudFree(PointCloud *pointCloud){
    free(pointCloud->pts);
    free(pointCloud->weights);
    free(pointCloud);
};