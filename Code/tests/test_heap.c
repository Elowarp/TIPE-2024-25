/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:51:29
 *  Last modified : 14-09-2024 22:55:04
 *  File : test_heap.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../structures/heap.h"

int main(){
    Heap *H = heapInit(10);
    assert(heapSize(H) == 0);

    HeapNode *node1 = heapNodeInit(1, NULL, 1.0, 1);
    HeapNode *node2 = heapNodeInit(2, NULL, 2.0, 2);
    HeapNode *node3 = heapNodeInit(3, NULL, 3.0, 3);

    heapInsert(H, node2);
    heapInsert(H, node1);
    heapInsert(H, node3);

    assert(heapSize(H) == 3);
    assert(heapTop(H) == node1);

    HeapNode *min = heapPop(H);
    assert(min == node1);
    assert(heapSize(H) == 2);
    assert(heapTop(H) == node2);

    heapFree(H);
    heapNodeFree(node1);
    heapNodeFree(node2);
    heapNodeFree(node3);

    return 0;
}