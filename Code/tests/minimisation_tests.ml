(*
*  Name : Elowan
*  Creation : 17-08-2024 19:36:14
*  Last modified : 22-08-2024 11:33:03
*)

open Automaton
open Dlist
open Minimisation
open Partition
open Turing

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

    let empty_automaton = 
        let a = {
            nb_states = 0;
            sigma = [|"a", "b"|];
            i=0;
            f = [];
            delta = Hashtbl.create 36;
        } in a 
    in

    (* Automate de geeksforgeeks *)
    let test2_automaton = 
        let a = {
            nb_states = 6;
            sigma = [|"0"; "1"|];
            i = 0;
            f = [1; 2; 5];
            delta = Hashtbl.create 10;
        } in 
        Automaton.add_transition a 0 "0" 1;
        Automaton.add_transition a 0 "1" 2;
        Automaton.add_transition a 1 "0" 3;
        Automaton.add_transition a 1 "1" 4;
        Automaton.add_transition a 2 "0" 4;
        Automaton.add_transition a 2 "1" 3;
        Automaton.add_transition a 3 "0" 5;
        Automaton.add_transition a 3 "1" 5;
        Automaton.add_transition a 4 "0" 5;
        Automaton.add_transition a 4 "1" 5;
        Automaton.add_transition a 5 "0" 5;
        Automaton.add_transition a 5 "1" 5;
        a
    in

    (* Test de la fonction de calcule des inverses des états *)
    print_string "--- Test de la fct inv ---\n";
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

    let inv_empty = Array.map (fun tab -> 
        Array.map (fun e -> Dlist.dlist_to_list e) tab) 
        (Minimisation.inv empty_automaton) in
    
    assert(inv_empty = [||]);

    let inv2 = Minimisation.inv test2_automaton in
    let inv_array2 = Array.map (fun tab -> 
        Array.map (fun e -> Dlist.dlist_to_list e) tab) 
        inv2 in

    assert(inv_array2 = [|
        [|[]; []|];
        [|[0]; []|];
        [|[]; [0]|];
        [|[1]; [2]|];
        [|[2]; [1]|];
        [|[3; 4; 5]; [3; 4; 5]|];
    |]);

    print_string "Ok\n";
    
    (* Test de la fonction get met class *)
    print_string "--- Test de la fct get_met_class ---\n";
    
    (* Partition *)
    let n = 6 in
    let part = Partition.init_partition n in

    for q=0 to n-1 do
        if List.mem q test_automaton.f then (* Si acceptant *)
            Partition.add_elmt_to_part part q 1
        else
            Partition.add_elmt_to_part part q 0
    done;

    let cl = ref Dlist.Nil in
    (* Les classes à scinder apres lecture de la 2eme lettre et depuis la partie 1*)
    let share = Array.make n 0 in
    Minimisation.get_met_class part share inv cl 0 1;
    assert(Dlist.dlist_to_list !cl = [0; 1]);
    
    (* Les classes à scinder apres lecture de la 1ere lettre et depuis la partie 2*)
    cl := Dlist.Nil;
    let share = Array.make n 0 in
    Minimisation.get_met_class part share inv cl 1 0;
    assert(Dlist.dlist_to_list !cl = [1]);

    (* Partition du 2eme automate *)
    let part2 = Partition.init_partition n in 

    for q=0 to n-1 do
        if List.mem q test2_automaton.f then (* Si acceptant *)
            Partition.add_elmt_to_part part2 q 1
        else
            Partition.add_elmt_to_part part2 q 0
    done;

    (* Les classes à scinder apres lecture de la 2eme lettre et depuis la partie 1*)
    cl := Dlist.Nil;
    let share = Array.make n 0 in   
    Minimisation.get_met_class part2 share inv2 cl 0 1;
    assert(Dlist.dlist_to_list !cl = [1]);

    (* Les classes à scinder apres lecture de la 1eme lettre et depuis la partie 2*)
    cl := Dlist.Nil;
    let share = Array.make n 0 in
    Minimisation.get_met_class part2 share inv2 cl 1 0;
    assert(Dlist.dlist_to_list !cl = [1; 0]);   
    print_string "Ok\n"; flush_all();


    (* Test de l'algorithme de Hopcroft *)
    print_string "--- Test de l'algorithme de Hopcroft ---\n";
    let min_automaton = Minimisation.hopcroft_algo test_automaton in
    assert(Automaton.are_equivalent test_automaton min_automaton);

    let min2_automaton = Minimisation.hopcroft_algo test2_automaton in 
    assert(Automaton.are_equivalent test2_automaton min2_automaton);
    print_string "Ok\n";

    (* Test de la minimisation d'une machine de turing *)
    print_string "--- Test de la minimisation d'une machine de turing ---\n";
    let tm = Turing.load_turing "turing_machines/big_increase_counter.tm" in
    let min_tm = Minimisation.minimise_turing tm (fun x -> x) (fun x -> x) in

    print_string "/!\\ Tester l'équivalence des machines de Turing est indécidable.\n";
    print_string "Donc nous décidons de juste tester quelques valeurs et des les prendre \
comme attestant de la validité de la minimisation. /!\\\n";

    let returned_array (tm: 'a Turing.t) (array: 'a array): 'a array = 
        let t = Turing.tape_to_array (
            Turing.run_turing tm (Turing.array_to_tape array tm.blank)
        ) tm.blank in t
    in 

    assert(min_tm.nb_states = 3);
    assert(min_tm.sigma = [|"0"; "1"|]);
    assert(returned_array tm [|"0"; "0"; "0"; "0"|] 
            = returned_array min_tm [|"0"; "0"; "0"; "0"|]);
    assert(returned_array tm [|"0"; "1"; "0"; "1"|] 
            = returned_array min_tm [|"0"; "1"; "0"; "1"|]);
    assert(returned_array tm [|"1"|] 
            = returned_array min_tm [|"1"|]);
    assert(returned_array tm [||] = returned_array min_tm [||]);
    print_string "Ok\n";

