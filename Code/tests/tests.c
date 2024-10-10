/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 13:36:27
 *  Last modified : 08-10-2024 17:05:47
 *  File : tests.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "tests_kdTree.h"
#include "tests_heap.h"
#include "tests_avl.h"
#include "tests_geometry.h"
#include "tests_triangulate.h"
#include "tests_persDiag.h"

int main(){
    test_kdTree();
    test_heap();
    tests_avl();
    test_geometry();
    tests_triangulate();
    tests_persDiag();
    return 0;
}