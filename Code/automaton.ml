(*
 *  Name : Elowan
 *  Creation : 09-08-2024 15:33:20
 *  Last modified : 09-08-2024 17:26:20
 *)

type 'a t = { (* Type d'un automate deterministe *)
    mutable nb_states: int; (* Nombres d'états : 0, 1, ..., n-1*)
    sigma: 'a array;
    i: int;
    mutable f: int list;
    delta: (int * 'a, int) Hashtbl.t;
} 

let add_transition (a: 'a t) (q1: int) (read_letter: 'a) (q2: int): unit = 
    assert ((q1 >= 0) && (q1 < a.nb_states));
    assert ((q2 >= 0) && (q2 < a.nb_states));
	assert (Array.mem read_letter (a.sigma));

    match Hashtbl.find_opt (a.delta) (q1, read_letter) with
        | None -> Hashtbl.add (a.delta) (q1, read_letter) q2
        | Some q2' -> (
            (* Test de si une transition identique n'existe déjà pas *)
            if q2' <> q2 then
                begin
                    Printf.printf "Etat %d vers %d \n" q1 q2;
                    failwith "Indeterminisation de l'automate !"
                end
        )

let print_transition (q1: int) (read_letter: 'a) (q2: int) (print_letter: 'a -> unit): unit = 
    print_int q1;
    print_string "; \""; 
    print_letter read_letter;
    print_string "\" -> ";
    print_int q2;
    print_newline ()

let print_transitions (a: 'a t) (print_letter: 'a -> unit): unit = 
    for i=0 to a.nb_states - 1 do 
        for j=0 to (Array.length a.sigma) - 1 do
            match Hashtbl.find_opt a.delta (i, a.sigma.(j)) with
            | None -> ()
            | Some q -> print_transition i a.sigma.(j) q print_letter
        done
    done

let print_automaton (a: 'a t) (print_letter: 'a -> unit): unit = 
    print_string "Affichage d'un automate : \n";
    Printf.printf "Initial : %d\n" a.i;
    print_string "Finaux : ";
    List.iter (fun x -> print_int x ; print_string " ") a.f;
    print_newline ();
    print_transitions a print_letter;
    print_newline ()