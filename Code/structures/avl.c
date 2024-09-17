/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 17-09-2024 16:11:05
 *  Last modified : 17-09-2024 16:52:57
 *  File : avl.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "avl.h"

// Initialisation d'un noeud
AVL *avlInit(int key, void* elmt) {
    AVL *avl = malloc(sizeof(AVL));
    avl->left = NULL;
    avl->right = NULL;
    avl->height = 1;
    avl->key = key;
    avl->elmt = elmt;
    return avl;
}

// Rotation droite
static AVL *rotateRight(AVL *avl){
    AVL *newRoot = avl->left;
    avl->left = newRoot->right;
    newRoot->right = avl;
    return newRoot;
}

// Rotation gauche
static AVL *rotateLeft(AVL *avl){
    AVL *newRoot = avl->right;
    avl->right = newRoot->left;
    newRoot->left = avl;
    return newRoot;
}

// Rotation droite-gauche
static AVL *rotateRightLeft(AVL *avl){
    avl->right = rotateRight(avl->right);
    return rotateLeft(avl);
}

// Rotation gauche-droite
static AVL *rotateLeftRight(AVL *avl){
    avl->left = rotateLeft(avl->left);
    return rotateRight(avl);
}

// Balance factor
static int balanceFactor(AVL *avl){
    if(avl == NULL){
        return 0;
    }
    if(avl->left == NULL && avl->right == NULL){
        return 0;
    }
    if(avl->left == NULL){
        return avl->right->height;
    }
    if(avl->right == NULL){
        return -avl->left->height;
    }
    return avl->right->height - avl->left->height;
}

// Insertion d'un noeud
AVL *avlInsert(AVL *avl, int key, void* elmt){
    if(avl == NULL){
        return avlInit(key, elmt);
    }
    if(key < avl->key){
        avl->left = avlInsert(avl->left, key, elmt);
        if(balanceFactor(avl) == 2){
            if(key < avl->left->key){
                avl = rotateRight(avl);
            } else {
                avl = rotateLeftRight(avl);
            }
        }
    } else {
        avl->right = avlInsert(avl->right, key, elmt);
        if(balanceFactor(avl) == 2){
            if(key > avl->right->key){
                avl = rotateLeft(avl);
            } else {
                avl = rotateRightLeft(avl);
            }
        }
    }

    if (balanceFactor(avl) < 0) {
        avl->height = 1 + avl->left->height;
    } else {
        avl->height = 1 + avl->right->height;
    }
    
    return avl;
}

// Recherche d'un noeud
AVL *avlSearch(AVL *avl, int key){
    if(avl == NULL){
        return NULL;
    }
    if(key == avl->key){
        return avl;
    }
    if(key < avl->key){
        return avlSearch(avl->left, key);
    }
    return avlSearch(avl->right, key);
}

// Suppression d'un noeud
AVL *avlDelete(AVL *avl, int key){
    if(avl == NULL){
        return NULL;
    }
    if(key == avl->key){
        // Si le noeud n'a pas d'enfants
        if(avl->left == NULL && avl->right == NULL){
            free(avl);
            return NULL;
        }

        // Si le noeud a un seul enfant
        if(avl->left == NULL){
            AVL *right = avl->right;
            free(avl);
            return right;
        }
        if(avl->right == NULL){
            AVL *left = avl->left;
            free(avl);
            return left;
        }

        // Si le noeud a deux enfants
        // On trouve le noeud de plus petite clé ds le ss arbre droit 
        AVL *min = avl->right;
        while(min->left != NULL){
            min = min->left;
        }

        // On remplace alors le noeud par celui trouvé 
        avl->key = min->key;
        avl->elmt = min->elmt;

        // On supprime le noeud trouvé
        avl->right = avlDelete(avl->right, min->key);
        return avl;
    }

    // Parcours de l'arbre
    if(key < avl->key){
        avl->left = avlDelete(avl->left, key);
    } else {
        avl->right = avlDelete(avl->right, key);
    }
    return avl;
}

// Libère la mémoire
void avlFree(AVL *avl){
    if(avl == NULL){
        return;
    }
    avlFree(avl->left);
    avlFree(avl->right);
    free(avl);
}