/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 22:16:39
 *  Last modified : 15-09-2024 13:02:39
 *  File : avl.h
 */
#ifndef AVL_H
#define AVL_H

typedef struct AVL_t {
    struct AVL_t *left;
    struct AVL_t *right;
    int height;
    int key;
    int column; // Peut changer
} AVL;

#endif