(*
 *  Name : Elowan
 *  Creation : 21-08-2024 22:02:12
 *  Last modified : 21-08-2024 22:02:12
 *)

open Automaton

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
            sigma = [|"a"; "b"|];
            i=7;
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
        Automaton.add_transition a 5 "1" 5; a in

    let minimised_test_automaton = 
        let a = {
            nb_states = 3;
            sigma = [|0; 1|];
            i = 0;
            f = [1];
            delta = Hashtbl.create 10;
        } in
        Automaton.add_transition a 0 0 0;
        Automaton.add_transition a 0 1 1;
        Automaton.add_transition a 1 0 1;
        Automaton.add_transition a 1 1 2;
        Automaton.add_transition a 2 0 2;
        Automaton.add_transition a 2 1 2; a 
    in

    (* Test is_langage_empty *)
    print_string "--- Test de is_langage_empty ---\n";
    assert (is_langage_empty test_automaton = false);
    assert (is_langage_empty empty_automaton = true);
    assert (is_langage_empty test2_automaton = false);
    print_string "Ok\n";

    (* Test intersection *)
    print_string "--- Test de intersection ---\n";
    let inter_test_automaton = intersection test_automaton minimised_test_automaton in
    assert (is_langage_empty inter_test_automaton = false);

    let inter_test_automaton = intersection test2_automaton empty_automaton in
    assert (is_langage_empty inter_test_automaton = true);
    print_string "Ok\n";

    (* Test complementary *)
    print_string "--- Test de complementary ---\n";
    let comp_test_automaton = complementary test_automaton in
    assert (
        is_langage_empty (intersection comp_test_automaton test_automaton) = true
    );

    let comp_test2_automaton = complementary test2_automaton in
    assert (
        is_langage_empty (intersection comp_test2_automaton test2_automaton) = true
    );
    print_string "Ok\n";

    (* Test are_equivalent *)
    print_string "--- Test de are_equivalent ---\n";
    assert (are_equivalent test_automaton test_automaton = true);
    assert (are_equivalent test2_automaton empty_automaton = false);
    assert (are_equivalent test2_automaton test2_automaton = true);
    assert (are_equivalent test_automaton minimised_test_automaton = true);
    print_string "Ok\n";
