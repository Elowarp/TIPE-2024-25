/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:39
 *  Last modified : 14-09-2024 22:22:06
 *  File : avl.h
 */
#ifndef AVL_H
#define AVL_H

typedef struct AVLNode_t {
    struct AVLNode_t *left;
    struct AVLNode_t *right;
    int height;
    int key;
    int column; // Peut changer
} AVLNode;

#endif