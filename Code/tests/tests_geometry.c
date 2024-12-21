/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-09-2024 16:57:12
 *  Last modified : 08-12-2024 21:26:39
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

    simplexFree(s);
    
}