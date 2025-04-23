/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 21-04-2025 18:44:39
 *  Last modified : 23-04-2025 23:02:46
 *  File : list.h
 */
#ifndef LIST_H
#define LIST_H

#include <stdbool.h>

// Listes ordonnées 
typedef struct node_t {
    int value;
    struct node_t* prec;
    struct node_t* next;
} node;

typedef struct {
    int nb;
    node *start;
    node *end;
} db_int_list;

db_int_list *create_list();
void append_list(db_int_list *l, int v);
void remove_list(db_int_list *l, int v);
bool is_empty_list(db_int_list *l);
db_int_list *join_list(db_int_list *l1, db_int_list *l2);
db_int_list *xor_list(db_int_list *l1, db_int_list *l2);
void print_list(db_int_list *l);
int len_list(db_int_list *l);
void free_list(db_int_list *l);


#endif