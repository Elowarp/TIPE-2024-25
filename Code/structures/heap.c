/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:32:07
 *  Last modified : 17-09-2024 15:53:23
 *  File : heap.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "../misc.h"
#include "geometry.h"
#include "heap.h"

/*
L'implémentation du tas min a pour convention de prendre le premier élément
du tableau heap comme étant le nombre d'éléments du tas. 
*/

// Initialisation d'un noeud du tas
HeapNode *heapNodeInit(float priority, void *elmt){
    HeapNode *node = malloc(sizeof(HeapNode));
    node->elmt = elmt;
    node->priority = priority;
    return node;
}

// Fonction de comparaison pour un tas min
static int cmpMin(HeapNode *a, HeapNode *b){
    return a->priority < b->priority;
}

// Fonction de comparaison pour un tas max
static int cmpMax(HeapNode *a, HeapNode *b){
    return a->priority > b->priority;
}

// Initialisation d'un tas max
HeapMax *heapMaxInit(int maxSize){
    HeapMax *H = malloc(sizeof(HeapMax));
    H->heap = malloc((maxSize+1) * sizeof(HeapNode *));
    H->maxSize = maxSize;
    H->heap[0] = heapNodeInit(0, NULL);
    return H;
}

// Initialisation d'un tas min
HeapMin *heapMinInit(int maxSize){
    HeapMin *H = malloc(sizeof(HeapMin));
    H->heap = malloc((maxSize+1) * sizeof(HeapNode *));
    H->maxSize = maxSize;
    H->heap[0] = heapNodeInit(0, NULL);
    return H;
}

// Récupère le nombre d'éléments du tas max
int heapMaxSize(HeapMax *H){
    return H->heap[0]->priority;
}

// Récupère le nombre d'éléments du tas min
int heapMinSize(HeapMin *H){
    return H->heap[0]->priority;
}

// Modification du nombre d'éléments du tas max
static void sizeEdit(HeapNode **elmts, int size){
    elmts[0]->priority = size;
}

// Intervertit deux éléments du tas
static void swap(HeapNode **elmts, int i, int j){
    HeapNode *tmp = elmts[i];
    elmts[i] = elmts[j];
    elmts[j] = tmp;
}

// Remonte un élément du tas à sa place
static void percolateUp(HeapNode **elmts, int i, int (*cmp)(HeapNode *, HeapNode *)){
    while(i > 1 &&  cmp(elmts[i], elmts[i/2])){
        swap(elmts, i, i/2);
        i /= 2;
    }
}

// Insertion d'un noeud dans un tas max
void heapMaxInsert(HeapMax *H, HeapNode *node){
    if(heapMaxSize(H) >= H->maxSize){
        print_err("heapMaxInsert : Taille du tas excédée !");
        exit(1);
    }

    H->heap[heapMaxSize(H) + 1] = node;
    sizeEdit(H->heap, heapMaxSize(H) + 1);
    percolateUp(H->heap, heapMaxSize(H), cmpMax);
}

// Insertion d'un noeud dans un tas min
void heapMinInsert(HeapMin *H, HeapNode *node){
    if(heapMinSize(H) >= H->maxSize){
        print_err("heapMinInsert : Taille du tas excédée !");
        exit(1);
    }

    H->heap[heapMinSize(H) + 1] = node;
    sizeEdit(H->heap, heapMinSize(H) + 1);
    percolateUp(H->heap, heapMinSize(H), cmpMin);
}

// Descend un élément du tas à sa place
static void percolateDown(HeapNode **elmts, int i, int (*cmp)(HeapNode *, HeapNode *), int size){
    int child;
    while(2*i <= size){ // Tant que l'élément a un enfant
        child = 2*i;

        // On prend le plus petit des deux enfants
        if(child != size && cmp(elmts[child+1], elmts[child])){
            child++;
        }
        
        // Si l'élément est plus grand que son enfant, on l'échange
        if(cmp(elmts[child], elmts[i])){
            swap(elmts, i, child);
            i = child;
        } else {
            break;
        }
    }
}

// Récupère et supprime le premier élément du tas max
HeapNode *heapMaxPop(HeapMax *H){
    if(heapMaxSize(H) < 1){
        print_err("heapMaxPop : Tas max vide !\n");
        exit(1);
    }
    HeapNode *max = H->heap[1];
    H->heap[1] = H->heap[heapMaxSize(H)];
    sizeEdit(H->heap, heapMaxSize(H) - 1);
    percolateDown(H->heap, 1, cmpMax, heapMaxSize(H));
    return max;
}

// Récupère et supprime le premier élément du tas min
HeapNode *heapMinPop(HeapMin *H){
    if(heapMinSize(H) < 1){
        print_err("heapMinPop : Tas mmin vide !\n");
        exit(1);
    }
    HeapNode *min = H->heap[1];
    H->heap[1] = H->heap[heapMinSize(H)];
    sizeEdit(H->heap, heapMinSize(H) - 1);
    percolateDown(H->heap, 1, cmpMin, heapMinSize(H));
    return min;
}

// Récupère le premier élément du tas max
HeapNode *heapMaxTop(HeapMax *H){ 
    if(heapMaxSize(H) < 1){
        print_err("heapMaxPop : Tas max vide !\n");
        exit(1);
    }
    return H->heap[1];
}

// Récupère le premier élément du tas min
HeapNode *heapMinTop(HeapMin *H){ 
    if(heapMinSize(H) < 1){
        print_err("heapMinPop : Tas mmin vide !\n");
        exit(1);
    }
    return H->heap[1];
}

// Affiche le tas max
void heapMaxPrint(HeapMax *H, void (*print)(void *)){
    for(int i = 1; i <= heapMaxSize(H); i++){
        printf("Prio : %f ; Elmt : ", H->heap[i]->priority);
        print(H->heap[i]->elmt);
    }
}

// Affiche le tas min
void heapMinPrint(HeapMin *H, void (*print)(void *)){
    for(int i = 1; i <= heapMinSize(H); i++){
        print(H->heap[i]->elmt);
    }
}

// Libère la mémoire allouée pour un noeud du tas
void heapNodeFree(HeapNode *node){
    free(node);
}

// Libère la mémoire allouée pour le tas max
// /!\ Ne libère pas la mémoire des noeuds internes au tas
void heapMaxFree(HeapMax *H){
    free(H->heap);
    free(H);
}

// Libère la mémoire allouée pour le tas min
// /!\ Ne libère pas la mémoire des noeuds internes au tas
void heapMinFree(HeapMin *H){
    free(H->heap);
    free(H);
}