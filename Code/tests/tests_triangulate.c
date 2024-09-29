/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-09-2024 15:46:36
 *  Last modified : 29-09-2024 16:03:37
 *  File : tests_triangulate.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

#include "../structures/triangulate.h"
#include "../misc.h"

void tests_triangulate(){
    int n = 100;
    int xmax = 100;
    int ymax = 100;
    srand(time(NULL));
    
    Point *pts = malloc(n * sizeof(Point));
    for(int i=0;i<n;i++){
        pts[i] = (Point) {rand()%xmax, rand()%ymax};
    }

    TriangleList *triangulation = triangulate(pts, n);
    triangleListToFile(triangulation, pts, n, "triangulation.txt");
}