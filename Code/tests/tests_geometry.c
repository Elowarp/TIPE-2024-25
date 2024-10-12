/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-09-2024 16:57:12
 *  Last modified : 12-10-2024 22:35:44
 *  File : tests_geometry.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../src/geometry.h"

void test_geometry(){
    // Tests points
    Point p1 = {1, 2};
    Point p2 = {3, 4};

    assert(!pointAreEqual(p1, p2));
    assert(pointAreEqual(p1, p1));

    EdgeList *edges = edgeListInit(0, 1, 1);
    edgeListInsert(edges, 1, 2, 2);
    edgeListInsert(edges, 2, 0, 3);
    edgeListInsert(edges, 2, 3, 3);
    edgeListInsert(edges, 0, 1, 4);
    edgeListInsert(edges, 2, 1, 5);
    edgeListInsert(edges, 4, 4, 4);
    edgeListInsert(edges, 7, 9, 4);

    assert(edgeListCount(edges, edges) == 2);
    assert(edgeListCount(edges, edges->next) == 2);
    assert(edgeListCount(edges, edges->next->next) == 1);

    EdgeList *elmt = edgeListInit(0, 1, 1);
    edges = edgeListRemove(edges, elmt);

    assert(edges->p1 == 1);
    assert(edges->p2 == 2);
    assert(edges->next->p1 == 2);
    assert(edges->next->p2 == 0);
    assert(edges->next->next->p1 == 2);
    assert(edges->next->next->p2 == 3);

    edges = removeDoubledEdges(edges);
    assert(edges->p1 == 2);
    assert(edges->p2 == 0);
    
    // Tests triangles
    Triangle *t1 = createTriangle(1, 2, 3);
    Triangle *t2 = createTriangle(1, 3, 2);
    Triangle *t3 = createTriangle(2, 1, 3);
    Triangle *t4 = createTriangle(4, 5, 6);

    assert(triangleAreEqual(t1, t2));
    assert(triangleAreEqual(t1, t3));
    assert(triangleAreEqual(t2, t3));
    
    TriangleList *triangles = triangleListInit(t1);
    assert(triangles->next == NULL);

    triangleListInsert(triangles, t4);
    assert(triangles->next != NULL);
    assert(triangles->next->next == NULL);

    triangleListInsert(triangles, t3);
    triangles = triangleListRemove(triangles, t2); // T2 est égal à T1
    triangles = triangleListRemove(triangles, t4);
    assert(triangles->next == NULL);

    triangleListFree(triangles);

    free(t1);
    free(t2);
    free(t3);
    free(t4);

    // Tests circle
    Point center = {0, 0};
    float radius = 1.0;
    Point p_circle = {0, 1};
    assert(inCircle(&center, radius, &p_circle));
    p_circle.x = 2;
    assert(!inCircle(&center, radius, &p_circle));
    
    // Tests simplex
    Simplex *s = simplexInit(2, 3, 1);
    assert(s->i == 1);
    assert(s->j == 2);
    assert(s->k == 3);

    assert(simplexId(s, 3) == 78);

    Simplex s2 = simplexFromId(52, 3);
    assert(s2.i == -1);
    assert(s2.j == 0);
    assert(s2.k == 2);

    free(s);

}