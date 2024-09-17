/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 17-09-2024 16:46:24
 *  Last modified : 17-09-2024 16:48:42
 *  File : tests_avl.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../structures/avl.h"

void tests_avl(){
    AVL *avl = avlInit(10, NULL);
    avl = avlInsert(avl, 5, NULL);
    avl = avlInsert(avl, 15, NULL);
    avl = avlInsert(avl, 2, NULL);
    avl = avlInsert(avl, 7, NULL);

    assert(avlSearch(avl, 10) != NULL);
    assert(avlSearch(avl, 5) != NULL);
    assert(avlSearch(avl, 15) != NULL);
    assert(avlSearch(avl, 4) == NULL);

    avl = avlDelete(avl, 5);
    assert(avlSearch(avl, 5) == NULL);

    avlFree(avl);
}