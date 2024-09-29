/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 15:52:06
 *  Last modified : 29-09-2024 15:51:50
 *  File : misc.h
 */
#ifndef MISC_H
#define MISC_H

#include <stdio.h>

extern void print_err(char* str);
extern void triangleListToFile(TriangleList *list, Point *pts, int n, char *filename);

#endif