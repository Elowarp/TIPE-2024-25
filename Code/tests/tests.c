/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 13:36:27
 *  Last modified : 17-09-2024 16:48:55
 *  File : tests.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "tests_kdTree.h"
#include "tests_heap.h"
#include "tests_avl.h"

int main(){
    test_kdTree();
    test_heap();
    tests_avl();
    return 0;
}