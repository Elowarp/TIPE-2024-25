/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 15-09-2024 14:05:17
 *  Last modified : 15-09-2024 16:59:17
 *  File : tests_heap.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../structures/heap.h"

void test_heap(){
    // Test tas min
    HeapMin *H = heapMinInit(10);
    assert(heapMinSize(H) == 0);

    HeapNode *node1 = heapNodeInit(1, NULL);
    HeapNode *node2 = heapNodeInit(2, NULL);
    HeapNode *node3 = heapNodeInit(3, NULL);

    heapMinInsert(H, node2);
    heapMinInsert(H, node1);
    heapMinInsert(H, node3);

    assert(heapMinSize(H) == 3);
    assert(heapMinTop(H) == node1);

    HeapNode *min = heapMinPop(H);
    assert(min == node1);
    assert(heapMinSize(H) == 2);
    assert(heapMinTop(H) == node2);

    // Test tas max
    HeapMax *H2 = heapMaxInit(10);
    assert(heapMaxSize(H2) == 0);

    HeapNode *node4 = heapNodeInit(1, NULL);
    HeapNode *node5 = heapNodeInit(2, NULL);
    HeapNode *node6 = heapNodeInit(3, NULL);

    heapMaxInsert(H2, node5);
    heapMaxInsert(H2, node4);
    heapMaxInsert(H2, node6);

    assert(heapMaxSize(H2) == 3);
    assert(heapMaxTop(H2) == node6);

    HeapNode *max = heapMaxPop(H2);
    assert(max == node6);
    assert(heapMaxSize(H2) == 2);
    assert(heapMaxTop(H2) == node5);

    heapMinFree(H);
    heapMaxFree(H2);

    heapNodeFree(node1);
    heapNodeFree(node2);
    heapNodeFree(node3);
    heapNodeFree(node4);
    heapNodeFree(node5);
    heapNodeFree(node6);
}