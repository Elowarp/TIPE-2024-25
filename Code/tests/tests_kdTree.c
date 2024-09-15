/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 14:05:45
 *  Last modified : 15-09-2024 16:58:10
 *  File : tests_kdTree.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../structures/geometry.h"
#include "../structures/kdTree.h"

void test_kdTree(){
    // Exemple du cours 
    Point a = {1, 1.10}, 
        b = {2, 2.4}, 
        c = {1, 3}, 
        d = {3, 3.4}, 
        e = {4, 2.5}, 
        f = {5.25, 1}, 
        g = {5, 2}, 
        h = {7, 3.2};
        
    Point pts[] = {a, b, c, d, e, f, g, h};
    KDTree *tree = kdTreeInit(pts, 8, 0);

    assert(pointAreEqual(tree->point, d));
    assert(pointAreEqual(tree->left->point, b));
    assert(pointAreEqual(tree->right->point, g));
    assert(pointAreEqual(tree->left->left->point, a));
    assert(pointAreEqual(tree->left->right->point, c));
    assert(pointAreEqual(tree->right->left->point, f));
    assert(pointAreEqual(tree->right->right->point, e));
    assert(pointAreEqual(tree->right->right->right->point, h));

    // Test knn
    Point pt = {6, 4};
    int k = 3;
    Point* result = kdTreeNearestNeighbor(tree, pt, k);

    // Afficher les résultats
    for (int i = 0; i < k; i++){
        printf("Point %d : (%f, %f)\n", i, result[i].x, result[i].y);
    }

    assert(pointAreEqual(result[0], h) || pointAreEqual(result[0], e) || pointAreEqual(result[0], g));
    assert(pointAreEqual(result[1], h) || pointAreEqual(result[1], e) || pointAreEqual(result[1], g));
    assert(pointAreEqual(result[2], h) || pointAreEqual(result[2], e) || pointAreEqual(result[2], g));

    free(result);
    kdTreeFree(tree);
}