/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 13:36:27
 *  Last modified : 23-04-2025 21:10:31
 *  File : tests.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "tests_geometry.h"
#include "tests_persDiag.h"
#include "tests_list.h"
#include "tests_reduc.h"

int main(){
    test_geometry();
    tests_persDiag();
    tests_list();
    tests_reduc();
    return 0;
}