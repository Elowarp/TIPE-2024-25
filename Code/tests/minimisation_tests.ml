(*
*  Name : Elowan
*  Creation : 17-08-2024 19:36:14
*  Last modified : 17-08-2024 20:50:42
*)

open Automaton
open Dlist
open Minimisation

let _ = 
    (* Automate donné par Wikipédia en tant qu'exemple *)
    let test_automaton = 
        let a = {
            nb_states = 6;
            sigma = [|0; 1|];
            i = 0;
            f = [2; 3; 4];
            delta = Hashtbl.create 10;
        } in
    Automaton.add_transition a 0 0 1;
    Automaton.add_transition a 0 1 2;
    Automaton.add_transition a 1 0 0;
    Automaton.add_transition a 1 1 3;
    Automaton.add_transition a 2 0 4;
    Automaton.add_transition a 2 1 5;
    Automaton.add_transition a 3 0 4;
    Automaton.add_transition a 3 1 5;
    Automaton.add_transition a 4 0 4;
    Automaton.add_transition a 4 1 5;
    Automaton.add_transition a 5 0 5;
    Automaton.add_transition a 5 1 5; a in

    (* Test de la fonction de calcule des inverses des états *)
    let inv = Minimisation.inv test_automaton in
    let inv_array = Array.map (fun tab -> 
        Array.map (fun e -> Dlist.dlist_to_list e) tab) inv in
    assert (inv_array = [|
        [|[1]; []|];
        [|[0]; []|];
        [|[]; [0]|];
        [|[]; [1]|];
        [|[2; 3; 4]; []|];
        [|[5]; [2; 3; 4; 5]|];
    |]);
    
    (* Test de la fonction get met class *)
    print_string "--- Test de la fct get_met_class ---\n";
    let n = 6 in
    let part = {
        class_names = Array.make n (-1);
        card = Array.make n 0;
        index = Array.init n (fun i -> 
            {head = i; next = ref Nil; prev = ref Nil}
        );
        part = Array.make n Nil
    } in
    let share = Array.make n 0 in   

    for q=0 to n-1 do
        if List.mem q test_automaton.f then (* Si acceptant *)
            add_elmt_to_part part q 1
        else
            add_elmt_to_part part q 0
    done;

    (* A developper *)
    let cl = ref Dlist.Nil in
    Minimisation.get_met_class part share inv cl 0 1;
    Dlist.print_dlist !cl; flush_all ();


    (* Test de l'algorithme de Hopcroft *)
    print_string "--- Test de l'algorithme de Hopcroft ---\n";
    print_string "Automate initial : \n";
    print_automaton test_automaton (fun x -> print_int x); flush_all ();

    print_string "Automate minimisé : \n";
    let min_automaton = Minimisation.hopcroft_algo test_automaton in
    print_automaton min_automaton (fun x -> print_int x); flush_all ()