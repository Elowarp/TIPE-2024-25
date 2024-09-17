/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:17:29
 *  Last modified : 17-09-2024 15:49:29
 *  File : heap.h
 */
#ifndef HEAP_H
#define HEAP_H

#include "geometry.h"

typedef struct {
    float priority;
    void *elmt;
} HeapNode; 

typedef struct {
    HeapNode **heap; // Tableau de pointeurs
    int maxSize;
} HeapMin;

typedef struct {
    HeapNode **heap; // Tableau de pointeurs
    int maxSize;
} HeapMax;

extern HeapNode *heapNodeInit(float priority, void *elmt);
extern HeapMax *heapMaxInit(int maxSize);
extern HeapMin *heapMinInit(int maxSize);
 
extern int heapMaxSize(HeapMax *H);
extern int heapMinSize(HeapMin *H);
extern void heapMaxInsert(HeapMax *H, HeapNode *node);
extern void heapMinInsert(HeapMin *H, HeapNode *node);
extern HeapNode *heapMaxPop(HeapMax *H);
extern HeapNode *heapMinPop(HeapMin *H);
extern HeapNode *heapMaxTop(HeapMax *H);
extern HeapNode *heapMinTop(HeapMin *H);
extern void heapMaxPrint(HeapMax *H, void (*print)(void *));
extern void heapMinPrint(HeapMin *H, void (*print)(void *));

extern void heapNodeFree(HeapNode *node);
extern void heapMaxFree(HeapMax *H);
extern void heapMinFree(HeapMin *H);
#endif