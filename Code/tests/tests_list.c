/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 22-04-2025 18:45:23
 *  Last modified : 23-04-2025 21:57:41
 *  File : tests_list.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../src/list.h"
#include "tests_list.h"

void tests_list(){
    printf("--- Tests list ---\n");
    db_int_list *l = create_list();
    printf("Liste vide : ");
    print_list(l);
    assert(len_list(l) == 0);
    assert(is_empty_list(l));

    append_list(l, 5);
    append_list(l, 0);
    append_list(l, 0);
    append_list(l, 4);
    append_list(l, 3);
    assert(len_list(l) == 4);
    printf("Liste ordonnée sans doublon de 5 0 0 4 3 : ");
    print_list(l);

    assert(is_empty_list(l) == false);

    printf("Meme liste apres suppression de 8 et 4 : ");
    remove_list(l, 8);
    remove_list(l, 4);
    assert(len_list(l) == 3);
    print_list(l);

    db_int_list *l2 = create_list();
    append_list(l2, 9);
    append_list(l2, 5);
    append_list(l2, 0);
    append_list(l2, -7);
    append_list(l2, -7);
    append_list(l2, 11);

    printf("Nouvelle liste de 9 5 0 -7 -7 et 11 : ");
    print_list(l2);
    db_int_list *l_join = join_list(l, l2);
    assert(len_list(l_join) == 6);
    printf("Union des deux listes précédentes : ");
    print_list(l_join);

    printf("Xor de cette union et de la liste 7 11 5 4 : ");
    db_int_list *l3 = create_list();
    append_list(l3, 7);
    append_list(l3, 11);
    append_list(l3, 5);
    append_list(l3, 4);
    db_int_list *l_xor = xor_list(l_join, l3);
    print_list(l_xor);
}