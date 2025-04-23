/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 22-04-2025 20:23:47
 *  Last modified : 23-04-2025 22:56:15
 *  File : reduc.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "geometry.h"
#include "misc.h"
#include "list.h"
#include "reduc.h"

// Renvoie la matrice low associée à une matrice de bordure O(n^2)
int *buildLowMatrix(int **boundary, unsigned long long n){
    int *low = malloc(n*sizeof(int));
    for(unsigned long long j=0; j<n; j++){
        low[j] = -1;
        for(unsigned long long i=0; i<n; i++)
            if(boundary[i][j] != 0) low[j] = i;
    }
    return low;
}


// Renvoie l'indice de la première colonne de la matrice low ayant la même valeur O(i)
int sameLow(int *low, int i){
    for(int j=i-1; j>=0; j--){
        if(low[i] == low[j] && low[i] != -1){
            return j;
        }
    }
    return -1;
}

// Met à jour la colonne j de la matrice low O(n)
void updateLow(int **boundary, int* low, int j, int n){ 
    low[j] = -1;
    for(int i=0; i<n; i++)
        if(boundary[i][j] != 0) low[j] = i;
}

// Construit la matrice de bordure associée à une filtration en O(max_name)
// reversed est le tableau des identifiants des simplexes dans la filtration 
// nb_pts est le nb de points dans l'ensemble
// max_name est le nom maximal attribué dans une filtration
int **buildBoundaryMatrix(int *reversed, unsigned long long max_name, int nb_pts){
    int **boundary = malloc(max_name * sizeof(int*));
    
    for(unsigned long long i = 0; i<max_name; i++){
        boundary[i] = malloc(max_name * sizeof(int));
        
        for(unsigned long long j = 0; j<max_name; j++){
            Simplex s1 = simplexFromId(reversed[i], nb_pts);
            Simplex s2 = simplexFromId(reversed[j], nb_pts);
            if (isFaceOf(&s1, &s2)) boundary[i][j] = 1;
            else boundary[i][j] = 0;
        }
    }

    return boundary;
}

// Standart Algorithm O(n^3)
int **reduceMatrix(int **boundary, unsigned long long n, int *low){
    int **reduced = copy_matrix(boundary, n); // O(n^2)
    for(unsigned long long i=0; i<n; i++){ 
        int j = sameLow(low, i); // O(n)
        while(j != -1){ // O(n) * O(n)
            // Soustraction de la colonne j à la colonne i
            for(unsigned long long k=0; k<n; k++){
                reduced[k][i] = (reduced[k][i] + reduced[k][j]) % 2;
            }
            
            updateLow(reduced, low, i, n);
            j = sameLow(low, i);
        }
    }
    return reduced;
}

// Récupère le plus grand indice de ligne tq la case est non nulle
// O(1)
int get_low(boundary_mat B, int j){
    if(is_empty_list(B.s[j])) return -1;
    else return B.s[j]->end->value;
}

// Renvoie un tableau dim de sorte que dim[i] est une liste de noms 
// de simplexes de dimension i ; il faut que D soit la dimension maximale
// de tous les simplexes O(nb total de simplexes^2)
db_int_list **simpleByDims(boundary_mat B, int *reversed, int n, int D){
    db_int_list **dims = malloc(sizeof(db_int_list*)*(D+1));
    for(int j=0; j<=D; j++)
        dims[j] = create_list();

    for(int i=0; i<B.n; i++){
        Simplex s = simplexFromId(reversed[i], n);
        append_list(dims[dimSimplex(&s)], i);
    }
    return dims;
}

// Construit la matrice de bordureV2 associée à une filtration en O(max_name)
// reversed est le tableau des identifiants des simplexes dans la filtration 
// nb_pts est le nb de points dans l'ensemble
// max_name est le nom maximal attribué dans une filtration
boundary_mat buildBoundaryMatrix2(int *reversed, unsigned long long max_name, int nb_pts){
    boundary_mat B = boundary_init(max_name);
    
    for(unsigned long long i = 0; i<max_name; i++){        
        for(unsigned long long j = 0; j<max_name; j++){
            Simplex s1 = simplexFromId(reversed[i], nb_pts);
            Simplex s2 = simplexFromId(reversed[j], nb_pts);
            if (isFaceOf(&s1, &s2)) append_list(B.s[j], i);
        }
    }

    return B;
}

// Réduit la matrice de bordure de façon intelligente 
// simplexes_by_dims est un tableau de listes de simplexes pour lequel l'indice
//      i correspond à la liste de simplexes de dimension i
void reduceMatrixOptimized(boundary_mat B, db_int_list **simplexes_by_dims){   
    // Réduction de chacune des matrices par les dimensions (de 0 à D-1)
    int D = 2; // Dimension maximale 
    for(int d=0; d<D; d++){ 
        // Simplexes de dimensions d+1 (cad consitituant les colonnes)
        db_int_list *simplexes = simplexes_by_dims[d+1];
        node *c = simplexes->end;

        // Boucle sur les colonnes en décroissante, dim[d+1] itérations au pire
        while(c != NULL){ 
            int j = c->value;
            node *c_i = c->prec;
            // Boucle tant qu'il y a une colonne i qui a le même low
            while(c_i != NULL) { // dim[d] itération au pire
                int i = c_i->value;
                int k = get_low(B, i);
                int k2 = get_low(B, j);

                // Si la colonne a le même low
                if (k == k2){
                    db_int_list *col = xor_list(B.s[i], B.s[j]); // O(l1 * l2)
                    free(B.s[j]);
                    B.s[j] = col;
                }
                
                c_i = c_i->prec;
            }

            c = c->prec;
        }
    }
}

// Initialise une matrice de bordure
boundary_mat boundary_init(int n){
    boundary_mat B;
    B.n = n;
    B.s = malloc(n*sizeof(db_int_list*));
    for(int i=0; i<n; i++)
        B.s[i] = create_list();

    return B;
}

// Création d'une matrice intxint a partir de la representation 
// boundary_mat
int **boundary_to_mat(boundary_mat B){
    // Allocations mémoires
    int **m = calloc(B.n, sizeof(int*));
    for(int i=0; i<B.n; i++)
        m[i] = calloc(B.n, sizeof(int));
    
    // Remplissage de la matrice
    // On rappelle que B.s[j] contient tous les indices i
    // de ligne ou m[i][j] != 0
    for(int j=0; j<B.n; j++){
        node *c = B.s[j]->start;
        while(c != NULL){
            m[c->value][j] = 1;
            c = c->next;
        }
    }

    return m;
}

// Affiche la matrice de bordure B
void print_boundary(boundary_mat B){
    int **m = boundary_to_mat(B);    

    for(int i=0; i<B.n; i++){
        for(int j=0; j<B.n; j++)
            printf("%d ", m[i][j]);
        
        printf("\n");
    }

    for(int i=0; i<B.n; i++)
        free(m[i]);

    free(m);
    
}

void free_boundary(boundary_mat B){
    for(int i=0; i<B.n; i++)
        free_list(B.s[i]);

    free(B.s);
}