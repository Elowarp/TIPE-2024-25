/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 13:55:46
 *  Last modified : 14-09-2024 22:18:56
 *  File : geometry.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "geometry.h"

PointCloud *pointCloudInit(int size){
    PointCloud *pointCloud = malloc(sizeof(PointCloud));
    pointCloud->pts = malloc(size * sizeof(Point));
    pointCloud->weights = malloc(size * sizeof(float));
    pointCloud->size = size;
    return pointCloud;
};


void pointCloudFree(PointCloud *pointCloud){
    free(pointCloud->pts);
    free(pointCloud->weights);
    free(pointCloud);
};