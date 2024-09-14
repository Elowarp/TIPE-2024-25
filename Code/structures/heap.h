/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:29
 *  Last modified : 14-09-2024 22:48:18
 *  File : heap.h
 */
#ifndef HEAP_H
#define HEAP_H

typedef struct {
    int a;
    int *N_a_t;
    float r;
    int t;
} HeapNode; 

typedef struct heap_t {
    HeapNode **heap; // Tableau de pointeurs
    int maxSize;
} Heap;

Heap *heapInit(int maxSize);
HeapNode *heapNodeInit(int a, int *N_a_t, float r, int t);

int heapSize(Heap *H);
void heapInsert(Heap *H, HeapNode *node);
HeapNode *heapPop(Heap *H);
HeapNode *heapTop(Heap *H);

void heapNodeFree(HeapNode *node);
void heapFree(Heap *H);

#endif