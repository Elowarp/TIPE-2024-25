(*
 *  Name : Elowan
 *  Creation : 20-08-2024 21:59:16
 *  Last modified : 20-08-2024 21:59:16
 *)
open Dlist
open Partition

let _ =
    let n = 6 in (* Partition de 6 éléments *)
    let part = init_partition n in
    add_elmt_to_part part 0 0;
    add_elmt_to_part part 1 0;
    add_elmt_to_part part 2 1;
    add_elmt_to_part part 3 1;
    add_elmt_to_part part 4 1;
    add_elmt_to_part part 5 0;

    remove_elmt_from_part part 5;
    add_elmt_to_part part 5 2;
    remove_elmt_from_part part 0;
    add_elmt_to_part part 0 1;

    assert(Dlist.dlist_to_list part.part.(0) = [1]);
    assert(Dlist.dlist_to_list part.part.(1) = [2; 3; 4; 0]);
    assert(Dlist.dlist_to_list part.part.(2) = [5]);