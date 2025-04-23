/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 21-04-2025 18:44:32
 *  Last modified : 23-04-2025 22:54:15
 *  File : list.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "list.h"

db_int_list *create_list(){
    db_int_list *l = malloc(sizeof(db_int_list));
    l->nb = 0;
    l->start = NULL;
    l->end = NULL;
    return l;
}

bool is_empty_list(db_int_list *l){
    return l->nb == 0;
}

node *create_node(int v){
    node *n = malloc(sizeof(node));
    n->value = v;
    n->next = NULL;
    n->prec = NULL;
    return n;
}

// Insert n avant v (n avec next et prec NULL)
void insert_before(db_int_list *l, node *n, node *v){
    if (v->prec == NULL){
        v->prec = n;
        n->next = v;
        l->start = n;
    } else {
        v->prec->next = n;
        n->prec = v->prec;
        n->next = v;
        v->prec = n;
    }
    l->nb++;

}

// Insert n après v (n avec next et prec NULL)
void insert_after(db_int_list *l, node *n, node *v){
    if (v->next == NULL){
        v->next = n;
        n->prec = v;
        l->end = n;
    } else {
        v->next->prec = n;
        n->next = v->next;
        n->prec = v;
        v->next = n; 
    }
    l->nb++;
    
}

void append_list(db_int_list *l, int v){
    node *n = create_node(v);
    if (is_empty_list(l)){
        l->start = n;
        l->end = n;
        l->nb++;
    } else {
        node *c = l->start;
        bool is_c_greater = false;
        bool is_elmt_found_in_list = false;
        
        // après execution, c le plus grand noeud plus petit que v ou
        // le dernier noeud de la liste
        while(c->next != NULL && !is_c_greater && !is_elmt_found_in_list){
            if (c->value < v) c = c->next;
            else if (c->value == v) is_elmt_found_in_list = true;
            else is_c_greater = true;
        }

        // Ajoute que s'il n'est pas déjà présent
        if (!is_elmt_found_in_list){
            if (is_c_greater) insert_before(l, n, c);
            // Si c est le dernier de la liste
            else if (c->value < v) insert_after(l, n ,c); 
            else insert_before(l, n, c);
        }
    }
}

// Supprime le noeud c de la liste l en libérant la mémoire
void remove_node(db_int_list *l, node *c){
    // Si milieu de liste
    if (c->prec != NULL && c->next != NULL){
        c->prec->next = c->next;
        c->next->prec = c->prec;

    // Sinon si fin de liste 
    } else if (c->prec != NULL){
        c->prec->next = NULL;
        l->end = c->prec;

    // Sinon si debut de liste
    } else if (c->next != NULL){
        c->next->prec = NULL;
        l->start = c->next;

    // Sinon si les deux (liste = [c])
    } else {
        l->start = NULL;
        l->end = NULL;

    }

    l->nb--;
    free(c);
}

// Supprime l'élément v de la liste l
void remove_list(db_int_list *l, int v){
    if (is_empty_list(l)) return;

    node *c = l->start;
    bool is_found = false;
    while(c != NULL && !is_found){
        if (c->value == v){
            is_found = true;
            remove_node(l, c);
        }
        c = c->next;
    }
}

// Crée une nouvelle liste contenant les elmts de l1 et l2
db_int_list *join_list(db_int_list *l1, db_int_list *l2){
    db_int_list *l = create_list();
    node *c1 = l1->end;
    node *c2 = l2->end;

    // Ajoute les éléments par ordre décroissant (donc append en O(1)
    // puisque pas besoin de parcourir toute la liste l)
    while(c1 != NULL && c2 != NULL){
        if(c1->value < c2->value){
            append_list(l, c2->value);
            c2 = c2->prec;
        } else {
            append_list(l, c1->value);
            c1 = c1->prec;
        }
    }

    // Si on arrive ici c'est que c1 = NULL ou c2 = NULL donc qu'une seule des 
    // deux boucles n'est exécutée : on garde l'ordre
    while(c1 != NULL){
        append_list(l, c1->value);
        c1 = c1->prec;
    }

    while(c2 != NULL){
        append_list(l, c2->value);
        c2 = c2->prec;
    }

    return l;
}

// Crée une nouvelle liste contenant suelement les éléments soit 
// dans l1 soit dans l2 mais pas des deux
db_int_list *xor_list(db_int_list *l1, db_int_list *l2){
    db_int_list *l = create_list();
    node *c1 = l1->end;
    node *c2 = l2->end;

    // Ajoute les éléments par ordre décroissant (donc append en O(1)
    // puisque pas besoin de parcourir toute la liste l)
    while(c1 != NULL && c2 != NULL){
        if(c1->value != c2->value){ // Evite le cas de deux mêmes indices
            if(c1->value < c2->value){
                append_list(l, c2->value);
                c2 = c2->prec;
            } else {
                append_list(l, c1->value);
                c1 = c1->prec;
            }
        } else {
            c1 = c1->prec;
            c2 = c2->prec;
        }
    }

    // Si on arrive ici c'est que c1 = NULL ou c2 = NULL donc qu'une seule des 
    // deux boucles n'est exécutée : on garde l'ordre
    while(c1 != NULL){
        append_list(l, c1->value);
        c1 = c1->prec;
    }

    while(c2 != NULL){
        append_list(l, c2->value);
        c2 = c2->prec;
    }

    return l;
}


void print_list(db_int_list *l){
    node *c = l->start;
    
    printf("[");
    while(c != NULL){
        printf("%d", c->value);
        if (c->next != NULL) printf("; ");
        c = c->next;
    }
    printf("]\n");
}

int len_list(db_int_list *l){
    return l->nb;
}

void free_list(db_int_list *l){
    node *c = l->start;
    while(c != NULL){
        node *v = c;
        c = c->next;
        free(v);
    }
    free(l);
}