/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 15:52:06
 *  Last modified : 29-09-2024 18:57:28
 *  File : misc.h
 */
#ifndef MISC_H
#define MISC_H

#include <stdio.h>

#include "structures/geometry.h"

extern void print_err(char* str);
extern PointCloud *pointCloudLoad(char *filename);
extern void triangleListToFile(TriangleList *list, Point *pts, int n, char *filename);

#endif