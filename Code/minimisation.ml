(*
 *  Name : Elowan
 *  Creation : 09-08-2024 15:31:23
 *  Last modified : 22-08-2024 11:30:53
 *)

open Partition
open Dlist
open Automaton
open Turing

(* Calcul du tableau des transitions inverses d'un automate *)
let inv (a: 'a Automaton.t): int dlist array array =
    let n = a.nb_states in
    let m = Array.length a.sigma in
    let inv = Array.make_matrix n m Nil in
    for q=0 to n-1 do
        for letter=0 to m - 1 do
            match Hashtbl.find_opt a.delta (q, a.sigma.(letter)) with
            | None -> ()
            | Some p -> inv.(p).(letter) <- add_dlist_elmt inv.(p).(letter) q
        done
    done;
    inv

(* Exécute la fonction f sur les éléments de a-1 P *)
let iter_inv (f: int -> unit) (part: partition) (inv: int dlist array array) 
  (p: int) (a: int) =
    assert(0 <= p && p < Array.length part.part);
    assert(0 <= a && a < Array.length inv.(0));
    
    (* Parcours des éléments de la partition P *)
    Dlist.iter (fun state ->
        (* Parcours des éléments de a-1 P *)
        Dlist.iter (fun prev_state -> 
            (* Printf.printf "q: %d prev_state: %d\n" state prev_state; *)
            f prev_state
        ) inv.(state).(a);

    ) part.part.(p)
    
(* Récupérations des classes tq la classe inter a-1 P est non vide et 
met dans cl_to_slice le nom des classes à scinder *)
let get_met_class (part: partition) (share: int array) (inv: int dlist array array)
  (cl_to_slice: int dlist ref) (p: int) (a: int): unit = 
    iter_inv (fun q ->
        let i = part.class_names.(q) in
        if share.(i) = 0 then
            begin
            share.(i) <- 1;
            cl_to_slice := add_dlist_elmt !cl_to_slice i
            end
        else
            share.(i) <- share.(i) + 1;
    ) part inv p a


(* Algorithme de Hopcroft *)
let hopcroft_algo (a: 'a Automaton.t): 'a Automaton.t = 
    let n = a.nb_states in
    let m = Array.length a.sigma in

    (* Partition des états *)
    let part = init_partition n in

    (*Calcule du tableau des inverses de l'automate *)
    let inv = inv a in
    (* Affiche inv *)
    (* for i=0 to n-1 do
        for j=0 to m-1 do
            print_dlist inv.(i).(j)
        done
    done; print_newline (); *)

    (* Remplissage de la partition avec deux parties disjointes, les états 
    acceptants et les autres *)
    for q=0 to n-1 do
        if List.mem q a.f then (* Si acceptant *)
            add_elmt_to_part part q 1
        else
            add_elmt_to_part part q 0
    done;
    let count = ref 2 in (* Noms de la prochaine classe crée *)

    (* Tableau d'appartenance de couples (P, a) pour la scission *)
    let l = Array.make_matrix n m false in 
    let l_dlist = ref Nil in

    (* Remplissage de l par la partie de plus petit cardinal entre les états 
    acceptants et les non acceptants *)
    if part.card.(0) <= part.card.(1) then
        for b=0 to m-1 do
            l.(0).(b) <- true;
            l_dlist := add_dlist_elmt !l_dlist (0, b)
        done
    else
        for b=0 to m-1 do
            l.(1).(b) <- true;
            l_dlist := add_dlist_elmt !l_dlist (1, b)
        done;

    while !l_dlist <> Nil do 
        (* Bloc a *)
        (* Récupération d'une coupe *)
        let ((p, letter), l_dlist_tmp) = remove_dlist !l_dlist in
        l_dlist := l_dlist_tmp;
        l.(p).(letter) <- false;

        (* Affiche la partie, la lettre et l'état de l *)
        (* Printf.printf "Classe : %d, lettre : %d\n" p letter; flush_all ();
        print_string "Coupes restantes : \n";
        for i=0 to n-1 do
            for j=0 to m-1 do
                Printf.printf "(%d; %d, %b) " i j l.(i).(j)
            done;
            Printf.printf "\n"
        done; flush_all (); *)

        (* Liste des noms des classes à scinder *)
        let cl_to_slice = ref Nil in 
        (* Tableaux des cardinaux des classes tq classe inter a-1 P *)
        let share = Array.make n 0 in
        (* twins[i] = Nom de la nouvelle classe créee pour briser
         la classe de nom i *)
        let twins = Array.make n 0 in
        
        (* Bloc b *)
        get_met_class part share inv cl_to_slice p letter;
        (* print_string "fin getmetclass\n"; *)
        (* Affiche les classes obtenues *)
        (* Dlist.iter (fun i -> Printf.printf "  Classe rencontree %d\n" i) !cl_to_slice; flush_all (); *)

        (* Bloc c *)
        (* Itération sur les classes B à scinder *)
        Dlist.iter (fun b -> 
            (* Printf.printf "Classe %d à scinder de cardinal %d\n" i part.card.(i); flush_all ();
            Printf.printf "Son intersection avec a-1 P de card : %d\n" share.(i); flush_all (); *)
            let moved_elmt = ref 0 in
            iter_inv ( (* Itération sur les états de B inter a-1 P*)
            fun q -> (* Etat de a-1 P *)
                (* Si B inter a-1 P n'est pas égal à B <=> B.a n'est pas inclus
                dans P *)
                let i = part.class_names.(q) in
                (* Printf.printf "q = %d i = %d\n" q i ; flush_all (); *)
                if share.(i) < part.card.(i) + !moved_elmt && i = b then 
                    begin
                    (* Printf.printf "On brise la classe %d\n" i; flush_all (); *)
                    if twins.(i) = 0 then 
                        begin
                        twins.(i) <- !count;
                        incr count;
                        end;
    
                    (* Supprimer q de sa classe et l'inserer dans twins[i]*)
                    remove_elmt_from_part part q;
                    add_elmt_to_part part q twins.(i);
                    incr moved_elmt

                end;
                (* Partition.print_partition part; *)
            ) part inv p letter;

            iter_inv (
            fun q -> 
                let i = part.class_names.(q) in
                (* Printf.printf "encore q = %d\n" q;
                Printf.printf "i = %d b=%d\n" i b; *)
                if share.(b) < part.card.(b) + !moved_elmt && i = twins.(b) then 
                    begin
                    (* print_string "Rajout des coupes\n"; *)
                    (* Bloc d *)
                    for letter=0 to m-1 do
                        (* Si la coupe est déjà à faire, on la remplace par la coupe des deux 
                        sous ensembles coupés *) 
                        if l.(b).(letter) then 
                            begin
                            l_dlist := add_dlist_elmt !l_dlist (i, letter);
                            l.(i).(letter) <- true
                            end
                        else
                            if part.card.(b) + !moved_elmt < share.(b) then 
                                begin
                                l_dlist := add_dlist_elmt !l_dlist (b, letter);
                                l.(b).(letter) <- true
                                end
                            else
                                begin
                                l_dlist := add_dlist_elmt !l_dlist (i, letter);
                                l.(i).(letter) <- true
                                end
                    done
                    end
            ) part inv p letter;) !cl_to_slice;
        (* print_newline () *)
    done;

    (* Partition.print_partition part; *)

    (* Création de l'automate minimal *)
    let min_automaton = {
        nb_states = !count;
        sigma = Array.copy a.sigma;
        i = part.class_names.(a.i);
        f = [];
        delta = Hashtbl.create 36
    } in 

    (* Liste des états acceptant sans doublons *)
    let f = ref [] in 
    for i=0 to n-1 do
        if List.mem i a.f && 
          not (List.mem part.class_names.(i) !f) then
            f := part.class_names.(i) :: !f
    done;
    min_automaton.f <- !f;

    (* Remplissage de la table de transition *)
    for q=0 to a.nb_states - 1 do
        for letter=0 to m-1 do
            let class_name = part.class_names.(q) in
            match Hashtbl.find_opt a.delta (q, a.sigma.(letter)) with
                | None -> ()
                | Some p -> 
                    match Hashtbl.find_opt min_automaton.delta (class_name, min_automaton.sigma.(letter)) with
                        | None -> Hashtbl.add min_automaton.delta (class_name, min_automaton.sigma.(letter)) (part.class_names.(p))
                        | Some q' -> ()
                    
        done
    done;

    min_automaton


(* Minimisation d'une machine de turing *)
let minimise_turing (tm : 'a Turing.t) (repr: 'a -> string)
  (unrepr_letter: string -> 'a): 'a Turing.t = 
    let equiv_automaton = Turing.turing_to_automaton tm repr in
    let min_automaton = hopcroft_algo equiv_automaton in
    Turing.automaton_to_turing min_automaton unrepr_letter