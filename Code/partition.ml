(*
 *  Name : Elowan
 *  Creation : 20-08-2024 20:59:31
 *  Last modified : 20-08-2024 20:59:31
 *)
open Dlist

(* Partition avec ajout et suppression en O(1) *)
type partition = {
    class_names: int array; (* Noms des classes auquels appartient les éléments *)
    card: int array;        (* Nombre d'éléments des classes *)
    index: int cell array;  (* Tableau des cellules dans la partition *)
    part: int dlist array;  (* Liste doublement chainées des éléments par classes *)
}

let init_partition (n: int): partition = {
    class_names = Array.make n (-1);
    card = Array.make n 0;
    index = Array.init n (fun i -> 
        {head = i; next = ref Nil; prev = ref Nil}
    );
    part = Array.make n Nil
}


(* Suppression de l'élément elmt de la classe cl de la partition courante *)
let remove_elmt_from_part (part: partition) (elmt: int): unit = 
    let cl_index = part.class_names.(elmt) in 
    if cl_index = -1 then () else (* Si l'élément n'est dans aucune classe *)
    begin
        part.card.(cl_index) <- part.card.(cl_index) - 1;
        part.class_names.(elmt) <- -1;

        (* Printf.printf "Suppressions de %d de la partition %d\n" elmt cl_index; flush_all (); *)

        (* Renouage des maillons *)
        (match !(part.index.(elmt).prev) with 
            | Nil -> part.part.(cl_index) <- !(part.index.(elmt).next)
            | DList l -> 
                l.next := !(part.index.(elmt).next);
        
        match !(part.index.(elmt).next) with 
            | Nil -> ()
            | DList l -> 
                l.prev := !(part.index.(elmt).prev));

        part.index.(elmt).prev := Nil;
        part.index.(elmt).next := Nil

    end

(* Ajout de l'élément elmt à la classe de nom cl_index *)
let add_elmt_to_part (part: partition) (elmt: int) (cl_index: int): unit = 
    (* Suppression de la potentiel partie où l'elmt est *)
    remove_elmt_from_part part elmt; 

    part.card.(cl_index) <- part.card.(cl_index) + 1;
    part.class_names.(elmt) <- cl_index;

    (* Printf.printf "Ajout de %d à la partition %d\n" elmt cl_index; flush_all (); *)

    (* Ajout de elmt à la classe cl *)
    match part.part.(cl_index) with
        | Nil -> part.part.(cl_index) <- DList part.index.(elmt)
        | DList l' -> 
            part.part.(cl_index) <- add_dlist_node part.part.(cl_index) part.index.(elmt)

let print_partition (part: partition): unit = 
    let classes = Hashtbl.create 10 in 
    for i=0 to Array.length part.class_names - 1 do
        if part.class_names.(i) <> -1 then
        match Hashtbl.find_opt classes part.class_names.(i) with
            | None -> Hashtbl.add classes part.class_names.(i) part.part.(part.class_names.(i))
            | Some _ -> ()
    done; 

    Hashtbl.iter (fun k v -> 
        Printf.printf "Classe %d (Card : %d): " k part.card.(k); Dlist.print_dlist v)
        classes