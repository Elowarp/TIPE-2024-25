/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 24-09-2024 16:57:12
 *  Last modified : 23-04-2025 22:41:38
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

    Simplex s0 = simplexFromId(52, 3);
    assert(s0.i == -1);
    assert(s0.j == 0);
    assert(s0.k == 2);

    simplexFree(s);

    // Tests des dimensions de simplexes
    Simplex *s1 = simplexInit(0, -1, -1);   // Point
    Simplex *s2 = simplexInit(0, 1, -1);    // Arête
    Simplex *s3 = simplexInit(0, 1, 2);     // Triangle

    assert(dimSimplex(s1) == 0);
    assert(dimSimplex(s2) == 1);
    assert(dimSimplex(s3) == 2);

    // Tests de faces
    Simplex *s4 = simplexInit(0, 1, 2);
    Simplex *s5 = simplexInit(0, 1, 3);
    Simplex *s6 = simplexInit(2, 1, -1);

    assert(isFaceOf(s4, s5) == 0); // Pb de dimension
    assert(isFaceOf(s6, s4) == 1); // Ok
    assert(isFaceOf(s6, s5) == 0); // Pas une face

    simplexFree(s1);
    simplexFree(s2);
    simplexFree(s3);
    simplexFree(s4);
    simplexFree(s5);
    simplexFree(s6);
    
}