/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 13:36:27
 *  Last modified : 12-10-2024 22:35:10
 *  File : tests.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "tests_geometry.h"
#include "tests_persDiag.h"

int main(){
    test_geometry();
    tests_persDiag();
    return 0;
}