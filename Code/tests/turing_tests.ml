(*
 *  Name : Elowan
 *  Creation : 03-07-2024 17:45:25
 *  Last modified : 03-07-2024 21:26:25
 *)

open Turing

let are_hashtbl_equals tbl1 tbl2 = 
    let check = ref true in

    Hashtbl.iter (fun k v -> 
        match Hashtbl.find_opt tbl2 k with
            | None -> check := false 
            | Some v' -> check := !check&&(v = v')
    ) tbl1;

    Hashtbl.iter (fun k v -> 
        match Hashtbl.find_opt tbl1 k with
            | None -> check := false 
            | Some v' -> check := !check&&(v = v')
    ) tbl2;

    !check

(*** Tests ***)
let _ = (* Tests des bandes *)
    print_string "--- Tests des bandes de turing ---\n";
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
    assert(read_tape tape2 blank 6 = 'c');
    print_string "Ok\n"

let _ = (* Tests des machines de Turing *)
    (* Exemple de machine de turing qui ajoute 1 à un compteur binaire *)
    let init_number = [|0; 1; 1; 0; 1|] in
    let blank = -1 in
    let (tm1: int t) = {
        nb_states = 3;
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


    print_string "--- Tests de la fct run_turing ---\n";
    let final_tape = run_turing tm1 (array_to_tape init_number blank) in 

    (* Test du résultat de l'exécution de la machine de turing *)
    assert (tape_to_array final_tape blank = [|0; 1; 1; 1; 0|]);
    print_string "Ok\n";

    (* Test de la duplication *)
    print_string "--- Tests de la duplication de machine de turing ---\n";
    let tm1_dup = duplicate_turing tm1 in 
    assert(tm1.i = tm1_dup.i);
    assert(tm1.f = tm1_dup.f);
    assert(tm1.blank = tm1_dup.blank);
    assert(tm1.nb_states = tm1_dup.nb_states);
    assert(tm1.sigma = tm1_dup.sigma);
    assert(are_hashtbl_equals tm1.delta tm1_dup.delta);

    tm1_dup.nb_states <- 4;
    add_transition tm1_dup 2 0 2 1 LEFT;
    assert(tm1.nb_states <> tm1_dup.nb_states);
    assert(not (are_hashtbl_equals tm1.delta tm1_dup.delta));
    print_string "Ok\n";


    (* Test de la conversion en automate *)
    print_string "--- Tests de la conversion en automate ---\n";
    let tm = load_turing "turing_machines/increase_counter.tm" in 
    let a = turing_to_automaton tm (fun x -> x) in 
    let tm' = automaton_to_turing a (fun x -> x) in 
    assert(are_hashtbl_equals tm.delta tm'.delta);
    assert(tm.i = tm'.i);
    assert(tm.f = tm'.f);
    assert(tm.blank = tm'.blank);
    assert(tm.nb_states = tm'.nb_states);
    assert(tm.sigma = tm'.sigma);
    print_string "Ok\n"
