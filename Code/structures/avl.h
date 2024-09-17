/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:39
 *  Last modified : 17-09-2024 16:48:15
 *  File : avl.h
 */
#ifndef AVL_H
#define AVL_H

typedef struct AVL_t {
    struct AVL_t *left;
    struct AVL_t *right;
    int height;
    int key; // Valeur de comparaison
    void *elmt;
} AVL;

AVL *avlInit(int key, void* elmt);
AVL *avlInsert(AVL *avl, int key, void* elmt);
AVL *avlSearch(AVL *avl, int key);
AVL *avlDelete(AVL *avl, int key);
void avlFree(AVL *avl);

#endif