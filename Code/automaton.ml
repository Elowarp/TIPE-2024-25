(*
 *  Name : Elowan
 *  Creation : 09-08-2024 15:33:20
 *  Last modified : 21-08-2024 20:32:27
 *)

type 'a t = { (* Type d'un automate deterministe *)
    mutable nb_states: int; (* Nombres d'états : 0, 1, ..., n-1*)
    sigma: 'a array;
    i: int;
    mutable f: int list;
    delta: (int * 'a, int) Hashtbl.t;
} 

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
    Printf.printf "Nombre d'états %d\n" a.nb_states;
    Printf.printf "Initial : %d\n" a.i;
    print_string "Finaux : ";
    List.iter (fun x -> print_int x ; print_string " ") a.f;
    print_newline ();
    print_transitions a print_letter;
    print_newline ()

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

(* Intersection de deux automates
Hypothèse: Le même sigma
*)
let intersection (a1: 'a t) (a2: 'a t): 'a t = 
    (* Fonction d'identification des états *)
    let id a1_q a2_q = 
        if a1.nb_states < a2.nb_states then
            a1_q * a2.nb_states + a2_q
        else
            a2_q * a1.nb_states + a1_q
    in

    let a = {
        nb_states = a1.nb_states * a2.nb_states;
        sigma = a1.sigma;
        i = id a1.i a2.i;
        f = [];
        delta = Hashtbl.create 10;
    } in

    (* Ajout des états finaux *)
    for i=0 to a1.nb_states - 1 do
        for j=0 to a2.nb_states - 1 do
            if List.mem i a1.f && List.mem j a2.f then
                    a.f <- (id i j) :: a.f
        done
    done;

    (* Ajout des transitions *)
    for i=0 to a1.nb_states - 1 do
        for j=0 to a2.nb_states - 1 do
            for k=0 to (Array.length a1.sigma) - 1 do
                match Hashtbl.find_opt a1.delta (i, a1.sigma.(k)), Hashtbl.find_opt a2.delta (j, a1.sigma.(k)) with
                | None, _ | _, None -> ()
                | Some q1, Some q2 -> 
                    Hashtbl.add a.delta (id i j, a1.sigma.(k)) (id q1 q2)
            done
        done
    done;
    a

let is_langage_empty (a: 'a t): bool = 
    if a.nb_states = 0 then true else

    (* Construction d'un tableau des états rencontrées *)
    let rec is_langage_empty_rec (q: int) (visited: bool array): bool = 
        (* Si on rencontre un état final pdt la visite : langage non vide*)
        if List.mem q a.f then false 

        (* Si on a déjà vu l'état : pas besoin de revisiter, RAS *)
        else if visited.(q) then true
                
        (* Sinon on visite les états suivants *)
        else
            begin
                visited.(q) <- true;
                let res = ref true in
                for i=0 to (Array.length a.sigma) - 1 do
                    match Hashtbl.find_opt a.delta (q, a.sigma.(i)) with
                    | None -> ()
                    | Some q' -> res := !res && (is_langage_empty_rec q' visited)
                done;
                !res
            end
    in
    is_langage_empty_rec a.i (Array.make a.nb_states false)

(* Automate qui accepte le langage complémentaire *)
let complementary (a: 'a t): 'a t = 
    let a' = {
        nb_states = a.nb_states;
        sigma = a.sigma;
        i = a.i;
        f = [];
        delta = Hashtbl.create 10;
    } in

    (* etat non finaux qui le deviennent et inversement *)
    for i=0 to a.nb_states - 1 do
        if not (List.mem i a.f) then
            a'.f <- i :: a'.f
    done;

    for i=0 to a.nb_states - 1 do
        for j=0 to (Array.length a.sigma) - 1 do
            match Hashtbl.find_opt a.delta (i, a.sigma.(j)) with
            | None -> Hashtbl.add a'.delta (i, a.sigma.(j)) i
            | Some q -> Hashtbl.add a'.delta (i, a.sigma.(j)) q
        done
    done;
    a'

let are_equivalent (a1: 'a t) (a2: 'a t): bool = 
    if is_langage_empty a1 && is_langage_empty a2 then true
    else if is_langage_empty a1 || is_langage_empty a2 then false
    else
        begin
            let a = intersection a1 (complementary a2) in
            let b = intersection a2 (complementary a1) in
            is_langage_empty a && is_langage_empty b
        end