/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:32:07
 *  Last modified : 14-09-2024 23:08:32
 *  File : heap.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "heap.h"

/*
L'implémentation du tas min a pour convention de prendre le premier élément
du tableau heap comme étant le nombre d'éléments du tas. 

On trie les éléments du tas en fonction de leur valeur r.  
*/

// Initialisation d'un tas min
Heap *heapInit(int maxSize){
    Heap *H = malloc(sizeof(Heap));
    H->heap = malloc((maxSize+1) * sizeof(HeapNode *));
    H->maxSize = maxSize;
    H->heap[0] = heapNodeInit(0, NULL, 0.0, 0);
    return H;
}

// Initialisation d'un noeud du tas
HeapNode *heapNodeInit(int a, int *N_a_t, float r, int t){
    HeapNode *node = malloc(sizeof(HeapNode));
    node->a = a;
    node->N_a_t = N_a_t;
    node->r = r;
    node->t = t;
    return node;
}

// Récupère le nombre d'éléments du tas
int heapSize(Heap *H){
    return H->heap[0]->r;
}

// Modification du nombre d'éléments du tas
void sizeEdit(Heap *H, int size){
    H->heap[0]->r = size;
}

// Intervertit deux éléments du tas
void swap(Heap *H, int i, int j){
    HeapNode *tmp = H->heap[i];
    H->heap[i] = H->heap[j];
    H->heap[j] = tmp;
}

// Remonte un élément du tas à sa place
void percolateUp(Heap *H, int i){
    while(i > 1 && H->heap[i]->r < H->heap[i/2]->r){
        swap(H, i, i/2);
        i /= 2;
    }
}

// Insertion d'un noeud dans le tas
void heapInsert(Heap *H, HeapNode *node){
    H->heap[heapSize(H) + 1] = node;
    sizeEdit(H, heapSize(H) + 1);
    
    percolateUp(H, heapSize(H));
}

// Descend un élément du tas à sa place
void percolateDown(Heap *H, int i){
    int child;
    while(2*i <= heapSize(H)){ // Tant que l'élément a un enfant
        child = 2*i;

        // On prend le plus petit des deux enfants
        if(child != heapSize(H) && H->heap[child+1]->r < H->heap[child]->r){
            child++;
        }
        
        // Si l'élément est plus grand que son enfant, on l'échange
        if(H->heap[i]->r > H->heap[child]->r){
            swap(H, i, child);
            i = child;
        } else {
            break;
        }
    }
}

// Récupère et supprime le premier élément du tas
HeapNode *heapPop(Heap *H){
    HeapNode *min = H->heap[1];
    H->heap[1] = H->heap[heapSize(H)];
    sizeEdit(H, heapSize(H) - 1);
    percolateDown(H, 1);
    return min;
}

// Récupère le premier élément du tas
HeapNode *heapTop(Heap *H){
    return H->heap[1];
}

// Libère la mémoire allouée pour un noeud du tas
void heapNodeFree(HeapNode *node){
    free(node);
}

// Libère la mémoire allouée pour le tas
// /!\ Ne libère pas la mémoire des noeuds internes au tas
void heapFree(Heap *H){
    free(H->heap);
    free(H);
}