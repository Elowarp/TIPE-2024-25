(*
 *  Name : Elowan
 *  Creation : 26-06-2024 10:59:40
 *  Last modified : 26-06-2024 11:15:40
 *  File : turgin.ml
 *)

(*
    Note : Afin d'avoir une meilleure visibilité, dans tous les affichages, le 
    caractère blanc est affiché _ à la place de celui mis au départ
*)

type 'a tape = (int, 'a) Hashtbl.t 
type move = LEFT | RIGHT
type 'a turing_machine = {
    nb_state: int; (* Nombres d'états : 0, 1, ..., n-1*)
    sigma: 'a array;
    blank: 'a;
    i: int;
    f: int list;
    delta: (int * 'a, int * 'a * move) Hashtbl.t;
} 

(*** Fonctions d'opérations sur la bande d'une machine de turing ***)
let init_tape () = Hashtbl.create 36

let copy_tape (tape: 'a tape): 'a tape = Hashtbl.copy tape

let read_tape (tape: 'a tape) (blank: 'a) (cursor: int): 'a = 
    (* Si on ne peut lire le caractère dans la bande, c'est qu'on lit un 
        caractère blanc*)
    match Hashtbl.find_opt tape cursor with 
        | None -> blank
        | Some c -> c

let write_tape (tape: 'a tape) (blank: 'a) (cursor: int) (write_letter: 'a): unit =
    (* Si on veut écrire un caractère blanc, on supprime l'occurrence dans la hastbl*) 
    match Hashtbl.find_opt tape cursor with 
        | None -> if write_letter <> blank then Hashtbl.add tape cursor write_letter
        | Some c -> if write_letter = blank then Hashtbl.remove tape cursor
        else Hashtbl.replace tape cursor write_letter

let array_to_tape (a: 'a array) (blank: 'a): 'a tape = 
    let tape = init_tape () in 
    for i=0 to Array.length a - 1 do
        Hashtbl.add tape i a.(i)
    done;
    tape

(* Renvoie un tableau des éléments de la bande dans l'ordre ainsi que le décalage 
   d'indice entre 0 et le plus petit élément (en terme d'indice) de la bande *)
let tape_to_array_with_offset (tape: 'a tape) (blank: 'a): ('a array * int) =
    (* Récupère l'indice minimum de la Hashtbl *)
    let min = Hashtbl.fold (
        fun (k:int) (v:'a) (acc: int option) -> 
            match acc with 
            | None -> Some(k) 
            | Some(k') -> if k' < k then Some(k') 
                else Some(k) 
    ) tape None in

    (* Récupère l'indice maximum de la Hashtbl *)
    let max = Hashtbl.fold (
        fun (k:int) (v:'a) (acc: int option) -> 
            match acc with 
            | None -> Some(k) 
            | Some(k') -> if k' > k then Some(k') 
                else Some(k) 
    ) tape None in

    (* Créer un tableau de la taille max-min + 1 rempli qu'avec des symboles blancs *)
    let a, offset = 
        match min with 
            | None -> ([||], 0) (* Aucun élément dans sur la bande *)
            | Some min -> (
                match max with 
                    | None -> failwith "Cas impossible"
                    | Some max -> 
                        (Array.make (max-min+1) blank, min)
            )
    in

    (* Rempli le tableau *)
    Hashtbl.iter (
        fun (k:int) (v: 'a) -> 
            a.(k-offset) <- v
    ) tape;

    (a, offset)

let tape_to_array (tape: 'a tape) (blank: 'a) = 
    let a, _ = tape_to_array_with_offset tape blank in a

let print_tape (tape: 'a tape) (blank: 'a) ?(show_cursor=false) ?(cursor=0) (print_letter: 'a -> unit): unit = 
    let a, offset = tape_to_array_with_offset tape blank in 
    print_string "[ ... ";

    Array.iteri (
        fun i x -> 
            if show_cursor && i=(cursor-offset) then (
                print_string "\x1b[41m"; (* Met la couleur en violet *)
                if x = blank then print_string "_" 
                else print_letter x; print_string " ";
                print_string "\x1b[0m" (* Met la couleur de base *)

            ) else (
                if x = blank then print_string "_" 
                else print_letter x; print_string " "
            )
    ) a;

    if show_cursor then
        if (cursor-offset) >= Array.length a then 
            (
                for i=0 to (cursor-offset) - Array.length a - 1 do 
                    print_string "_ "
                done;
                
                print_string "\x1b[41m"; (* Met la couleur en violet *)
                print_string "_"; print_string " ";
                print_string "\x1b[0m" (* Met la couleur de base *)
            );

    print_string "... ]";
    print_newline ()

(*** Fonctions de manipulation des machines de turing ***)
let add_transition (tm: 'a turing_machine) (q1: int) (read_letter: 'a) (q2: int)
  (write_letter: 'a) (shift: move): unit = 
    assert((q1 >= 0) && (q1 < tm.nb_state));
    assert((q2 >= 0) && (q2 < tm.nb_state));
	assert(Array.mem read_letter (tm.sigma) || read_letter = tm.blank);
	assert(Array.mem write_letter (tm.sigma) || write_letter = tm.blank);

    match Hashtbl.find_opt (tm.delta) (q1, read_letter) with
        | None -> Hashtbl.add (tm.delta) (q1, read_letter) (q2, write_letter, shift)
        | Some q -> (
            failwith "Indéterminisation de la machine de turing !"
        )

let print_transition (q1: int) (read_letter: 'a) (q2: int) (write_letter: 'a) 
  (shift: move) (print_letter: 'a -> unit): unit = 
    print_int q1;
    print_string ";"; 
    print_letter read_letter;
    print_string " -> ";
    print_int q2;
    print_string ";"; 
    print_letter write_letter;
    if shift = LEFT then print_string ";Left"
    else print_string ";Right";
    print_newline ()


let print_transitions (tm: 'a turing_machine) (print_letter: 'a -> unit): unit = 
    for i=0 to tm.nb_state - 1 do 
        for j=0 to (Array.length tm.sigma) - 1 do
            match Hashtbl.find_opt tm.delta (i, tm.sigma.(j)) with
            | None -> ()
            | Some (q, c, shift) -> print_transition i (tm.sigma.(j)) q c shift print_letter
        done;

        (* Affichage du caractère blanc *)
        match Hashtbl.find_opt tm.delta (i, tm.blank) with
            | None -> ()
            | Some (q2, write_letter, shift) -> 
                print_transition i (tm.blank) q2 write_letter shift (
                    fun x -> if x=tm.blank then print_string "_" else print_letter x
                )

    done

let print_turing (tm: 'a turing_machine) (print_letter: 'a -> unit): unit = 
    print_string "Affichage d'une machine de turing : \n";
    Printf.printf "Initial : %d\n" tm.i;
    print_string "Finaux : ";
    List.iter (fun x -> print_int x ; print_string " ") tm.f;
    print_newline ();
    print_string "Blanc : ";
    print_letter (tm.blank);
    print_newline ();
    print_transitions tm print_letter;
    print_newline ()

let run_turing (tm: 'a turing_machine) ?(print_step=false) 
  ?(print_letter= fun _ -> ()) (tape: 'a tape): 'a tape =
    let cursor = ref 0 in 
    let state = ref tm.i in  
    let working_tape = copy_tape tape in 
    let break = ref false in 

    while not (List.mem !state tm.f) && not !break do
        let read_letter = read_tape working_tape tm.blank !cursor in
        
        (* Une étape d'avancement *)
        match Hashtbl.find_opt tm.delta (!state, read_letter) with
            | None -> break := true (* Pas de quoi avancer, on s'arrête *)
            | Some(q2, write_letter, shift) -> 
                state := q2;
                write_tape working_tape tm.blank !cursor write_letter; 

                (* Affichage étape par étape *)
                if print_step then 
                    print_tape working_tape ~show_cursor:true ~cursor:!cursor 
                                tm.blank print_letter;

                if shift = LEFT then decr cursor
                else incr cursor
    done;

    if print_step then 
        print_tape working_tape tm.blank print_letter;

    working_tape


(*** Tests ***)
let _ = (* Tests des bandes *)
    let init_array = [||] in 
    let blank = '_' in
    let tape = array_to_tape init_array blank in
    
    assert(tape = init_tape ()); (* Test si la bande est bien vide *)
    
    (* Tests de Write et Read tape *)
    write_tape tape blank 0 'a';
    write_tape tape blank 1 'b';
    write_tape tape blank (-2) 'a';
    write_tape tape blank 4 'c';
    write_tape tape blank 0 'b';
    assert(read_tape tape blank 0 = 'b');
    assert(read_tape tape blank (-2) = 'a');
    assert(read_tape tape blank 1 = 'b');
    assert(read_tape tape blank 25 = blank);
    assert(read_tape tape blank (-1) = blank);
    
    (* Tests de la conversion en tableau *)
    assert(tape_to_array_with_offset tape blank = (
        [|'a'; blank; 'b'; 'b'; blank; blank; 'c'|], -2));
    
    (* Tests de la reconversion en bande (avec l'offset qui a changé) *)
    let tape2 = array_to_tape [|'a'; blank; 'b'; 'b'; blank; blank; 'c'|] blank in
    assert(read_tape tape2 blank 0 = 'a');
    assert(read_tape tape2 blank 2 = 'b');
    assert(read_tape tape2 blank 3 = 'b');
    assert(read_tape tape2 blank 27 = blank);
    assert(read_tape tape2 blank 1 = blank);
    assert(read_tape tape2 blank 6 = 'c')


let _ = (* Tests des machines de Turing *)
    (* Exemple de machine de turing qui ajoute 1 à un compteur binaire *)
    let init_number = [|0; 1; 1; 0; 1|] in
    let blank = -1 in

    let (tm1: int turing_machine) = {
        nb_state = 3;
        sigma = [|0; 1|];
        blank = blank;
        i=0;
        f=[2];
        delta = Hashtbl.create 36
    } in 

    add_transition tm1 0 0 0 0 RIGHT;
    add_transition tm1 0 1 0 1 RIGHT;
    add_transition tm1 0 blank 1 blank LEFT;
    add_transition tm1 1 0 2 1 LEFT;
    add_transition tm1 1 1 1 0 LEFT;
    add_transition tm1 1 blank 2 1 LEFT;
    print_turing tm1 print_int;

    print_string "Affichage de l'exécution d'un compteur binaire en machine de turing\n";
    print_string "Bande de départ : ";
    print_tape (array_to_tape init_number blank) blank print_int;

    let final_tape = run_turing tm1 ~print_step:true ~print_letter:print_int 
        (array_to_tape init_number blank) in 

    print_string "Bande obtenue : ";
    print_tape final_tape blank print_int;
    assert (tape_to_array final_tape blank = [|0; 1; 1; 1; 0|])