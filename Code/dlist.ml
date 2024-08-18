(*
 *  Name : Elowan
 *  Creation : 12-08-2024 08:56:06
 *  Last modified : 12-08-2024 09:21:18
 *)
type 'a cell = {head : 'a; mutable next : 'a dlist ref; mutable prev : 'a dlist ref}
and 'a dlist = Nil | DList of 'a cell

(* Ajout d'un element à une liste chainée en place *)
let add_dlist_elmt (l: 'a dlist) (x: 'a): 'a dlist = match l with
    | Nil -> DList {head = x; next = ref Nil; prev = ref Nil}
    | DList l' -> 
        let new_cell = {head = x; next = ref (DList l'); prev = ref Nil} in
        l'.prev := DList new_cell;
        DList new_cell

(* Ajout d'un maillon à une liste chainée *)
(* On suppose que le maillon n'est relié à aucune autre liste par son prev et next *)
let add_dlist_node (l: 'a dlist) (elmt: 'a cell): 'a dlist = match l with 
    | Nil -> DList elmt
    | DList l' -> 
        l'.prev := DList elmt;
        elmt.next := DList l';
        DList elmt


let remove_dlist (l: 'a dlist): ('a * 'a dlist) = 
    match l with
    | Nil -> failwith "Liste vide"
    | DList l' -> 
        match !(l'.next) with
        | Nil -> (l'.head, Nil)
        | DList l'' -> 
            l''.prev := Nil;
            (l'.head, DList l'')

let top_dlist (l: 'a dlist): 'a = match l with
    | Nil -> failwith "Liste vide"
    | DList l' -> l'.head

let iter (f: 'a -> unit) (l: 'a dlist): unit = 
    let rec iter_aux f l = match l with
        | Nil -> ()
        | DList l' -> 
            f l'.head;
            iter_aux f !(l'.next)
    in iter_aux f l

(* Affiche liste doublement chainées *)
let print_dlist (l: 'a dlist): unit = 
    if l = Nil then print_string "[]\n" else
    begin
        print_string "[ ";
        let rec print_dlist_aux l = match l with
            | Nil -> print_string "]\n"
            | DList l' -> 
                Printf.printf "%d " l'.head;
                print_dlist_aux !(l'.next)
        in print_dlist_aux l
    end

(* Convertit une dlist en liste *)
let dlist_to_list (l: 'a dlist): 'a list = 
    let rec dlist_to_list_aux l acc = match l with
        | Nil -> acc
        | DList l' -> dlist_to_list_aux !(l'.next) (l'.head :: acc)
    in dlist_to_list_aux l []


(* Tests *)
(* let _ = 
    let l = DList {head = 2; next = ref Nil; prev = ref Nil} in
    let l' = DList {head = 1; next = ref Nil; prev = ref l} in

    (match l with 
        | DList q -> q.next := l'
        | _ -> ());

    print_dlist l;
    let l = add_dlist_elmt l 3 in
    print_dlist l;
    let (x, l) = remove_dlist l in
    Printf.printf "x = %d\n" x;
    print_dlist l;
    let x = top_dlist l in
    Printf.printf "x = %d\n" x;
    print_dlist l *)