(*
 *  Name : Elowan
 *  Creation : 26-06-2024 10:59:40
 *  Last modified : 22-08-2024 11:33:43
 *  File : turing.ml
 *)

(*
    Note : Afin d'avoir une meilleure visibilité, dans tous les affichages, le 
    caractère blanc est affiché _ à la place de celui mis au départ
*)

open Automaton

type 'a tape = (int, 'a) Hashtbl.t 
type move = LEFT | RIGHT
type 'a t = { (* Type d'une machine de turing *)
    mutable nb_states: int; (* Nombres d'états : 0, 1, ..., n-1*)
    sigma: 'a array;
    blank: 'a;
    i: int;
    mutable f: int list;
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

(* Prend un tableau et le caractère blanc et créer une bande *)
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

let print_tape (tape: 'a tape) (blank: 'a) ?(show_cursor=false) ?(cursor=0)
  ?(state=(-1)) (print_letter: 'a -> unit): unit = 
    let a, offset = tape_to_array_with_offset tape blank in 
    if state != -1 then (
        print_string "Etat : ";
        print_int state
    );
    print_string " [ ... ";

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

(* Fonction qui créer une liste de transition a afficher dans le fichier 
d'export. Elle merge les transitions qui partent/viennent des mêmes noeuds
avec la même déplacement en une transition, affichant Sigma \ E avec E 
l'ensemble des symboles ne faisant pas parties du merge *)
let transition_listing (tm: 'a t) (repr_letter: 'a -> string): string list = 
    let transitions = ref [] in 
    let transitions_tmp = Hashtbl.create 36 in

    (* Fonction qui produit un string qui affiche la bonne transition *)
    let register_transition q1 q2 shift read_val write_val =
        transitions := (string_of_int q1 ^ " -> " ^ string_of_int q2 ^ 
            " [ label = \"" ^ read_val ^ " → " ^ write_val ^ " " ^ 
            (match shift with LEFT -> "Left" | RIGHT -> "Right") ^ "\" ]\n") :: !transitions
    in

    (* Stockage dans transitions_tmp des lettres à écrire et lue pour un même
    triplet d'état + déplacement *)
    Hashtbl.iter (fun k v -> 
        let q1, read_letter = k in 
        let q2, write_letter, shift = v in

        let key = (q1, q2, shift) in
        let value = (read_letter, write_letter) in

        match Hashtbl.find_opt transitions_tmp key with
            | None -> Hashtbl.add transitions_tmp key [value]
            | Some l -> Hashtbl.replace transitions_tmp key (value::l)
    ) tm.delta;

    (* On merge une fois des transitions par état, et on merge les transtions 
    qui ont quasi toutes la meme lettre à écrire ou qui quasi toutes ont la
    même lettre lu et écrite *)
    (* On veut sauvegarder celles non merged pour pouvoir l'indiquer dans 
    la création de la transition, et de créer des transitions spéciales pour elles *)
    Hashtbl.iter (fun k v -> 
        let q1, q2, shift = k in 
        let l = v in 

        let read_letters = List.map (fun (x, _) -> x) l in 
        let write_letters = List.map (fun (_, x) -> x) l in 

        (* Fait la liste des transitions telles que on laisse la lettre écrite
         invariante *)
        let invariants = ref [] in
        let variants = ref [] in
        let rec aux l1 l2 = match l1, l2 with
            | [], [] -> ()
            | x::q, y::q' -> 
                if x = y then invariants := (x,x)::!invariants
                else variants := (x,y)::!variants;
                aux q q'
            | _, _ -> failwith "Erreur de taille"
        in aux read_letters write_letters;

        (* Si la liste des invariants est plus grande que la moitié des lettres 
        on les merge toutes ensembles *)
        if List.length !invariants > 1 then 
            begin
                let read_val = 
                    if List.length !invariants = Array.length tm.sigma then 
                        "Σ"
                    else
                        "[ " ^ 
                            List.fold_left (fun acc (x, _) -> 
                                if acc = "" then repr_letter x 
                                else acc ^ ", " ^ repr_letter x
                            ) "" !invariants 
                        ^ " ]"
                in 

                let write_val = 
                    if List.length !invariants = Array.length tm.sigma then 
                        "Σ"
                    else
                        "[ " ^ 
                            List.fold_left (fun acc (_, x) -> 
                                if acc = "" then repr_letter x 
                                else acc ^ ", " ^ repr_letter x
                            ) "" !invariants 
                        ^ " ]"
                in

                register_transition q1 q2 shift read_val write_val;

                (* On garde les invariants et on crée une transition pour les autres *)
                List.iter (fun (x, y) -> 
                    register_transition q1 q2 shift (repr_letter x) (repr_letter y)
                ) !variants
            end
        else
            begin
            (* Sinon on cherche les transitions telles quelles écrivent la même 
                lettre *)
            (* S'il y en a assez on les merge, sinon on ajoute les transitions 
                telles quelle *)
            (* Compte le nb d'occurrence de chaque lettre écrite *)
            let count_write_letters = Array.make (Array.length tm.sigma + 1) 0 in 

            List.iter (fun x -> 
                match Array.find_index (fun e -> x=e) tm.sigma with
                            (* Cas symbole blanc *)
                    | None -> count_write_letters.(Array.length tm.sigma) 
                                <- count_write_letters.(Array.length tm.sigma) + 1 

                    | Some i -> count_write_letters.(i) <- count_write_letters.(i) + 1
            ) write_letters;

            (* Recherche de la plus grande occurrence *)
            let max = ref 0 in
            let max_i = ref 0 in
            for i=0 to Array.length tm.sigma - 1 do 
                if count_write_letters.(i) > !max then 
                    begin
                        max := count_write_letters.(i);
                        max_i := i
                    end
            done;

            if !max > 1 then (* On groupe selon la lettre *)
            begin
                (* On crée la liste des lettres à grouper *)
                let letters_to_group = 
                    let rec aux l1 l2 = match l1, l2 with
                        | [], [] -> []
                        | x::q, y::q' -> 
                            if y=tm.sigma.(!max_i) then x::(aux q q')
                            else aux q q'
                        | _, _ -> failwith "Erreur de taille"
                    in aux read_letters write_letters
                in

                (* Construction de la string du merged *)
                let read_val = 
                    if List.length letters_to_group = Array.length tm.sigma then 
                        "Σ"
                    else
                    "[ " ^ 
                        List.fold_left (fun acc x -> 
                            if acc = "" then repr_letter x 
                            else acc ^ "," ^ repr_letter x
                        ) "" letters_to_group 
                    ^ " ]"
                in

                (* On ajoute la transition merged *)
                register_transition q1 q2 shift read_val (repr_letter tm.sigma.(!max_i));

                (* On ajoute les transitions restantes *)
                let rec aux l1 l2 = match l1, l2 with
                    | [], [] -> ()
                    | x::q, y::q' -> 
                        if y <> tm.sigma.(!max_i) then 
                            register_transition q1 q2 shift (repr_letter x) (repr_letter y);
                        aux q q'
                    | _, _ -> failwith "Erreur de taille"
                in aux read_letters write_letters
            end
            else
            begin
                (* On ajoute les transitions telles quelles *)
                List.iter (fun (x, y) -> 
                    register_transition q1 q2 shift (repr_letter x) (repr_letter y)
                ) l
            end
        end;

    ) transitions_tmp;

    !transitions

let turing_to_pdf (tm: 'a t) (repr_letter: 'a -> string): unit = 
    let oc = open_out "export.dot" in 
    output_string oc "digraph G {\n"; 
    output_string oc (string_of_int tm.i ^"[shape=box];\n"); 
    List.iter (fun x -> output_string oc (string_of_int x ^"[shape=doublecircle];\n")) tm.f;
    for i=0 to tm.nb_states - 1 do
        if not (List.mem i tm.f) && i <> tm.i then 
            output_string oc (string_of_int i ^"[shape=circle];\n")
    done;

    let transitions = transition_listing tm repr_letter in
    List.iter (fun x -> output_string oc (x ^ ";\n")) transitions;

    output_string oc "}";
    close_out oc;
    let _ = Sys.command "dot -Tpdf export.dot > export.pdf" in 
    Sys.remove "export.dot"

let add_transition (tm: 'a t) (q1: int) (read_letter: 'a) (q2: int)
  (write_letter: 'a) (shift: move): unit = 
    assert((q1 >= 0) && (q1 < tm.nb_states));
    assert((q2 >= 0) && (q2 < tm.nb_states));
	(* assert(Array.mem read_letter (tm.sigma) || read_letter = tm.blank); *)
	(* assert(Array.mem write_letter (tm.sigma) || write_letter = tm.blank); *)

    match Hashtbl.find_opt (tm.delta) (q1, read_letter) with
        | None -> Hashtbl.add (tm.delta) (q1, read_letter) (q2, write_letter, shift)
        | Some (q2', write_letter', shift') -> (
            (* Test de si une transition identique n'existe déjà pas *)
            if (q2' <> q2 || write_letter' <> write_letter || shift' <> shift) then
                begin
                    Printf.printf "Etat %d vers %d \n" q1 q2;
                    failwith "Indeterminisation de la machine de turing !"
                end
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

let print_transitions (tm: 'a t) (print_letter: 'a -> unit): unit = 
    for i=0 to tm.nb_states - 1 do 
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

let print_turing (tm: 'a t) (print_letter: 'a -> unit): unit = 
    print_string "Affichage d'une machine de turing : \n";
    Printf.printf "Nombre d'états %d\n" tm.nb_states;
    Printf.printf "Initial : %d\n" tm.i;
    print_string "Finaux : ";
    List.iter (fun x -> print_int x ; print_string " ") tm.f;
    print_newline ();
    print_string "Blanc : ";
    print_letter (tm.blank);
    print_newline ();
    print_transitions tm print_letter;
    print_newline ()

let duplicate_turing (tm: 'a t): 'a t = 
    let tm_new = {
        nb_states = tm.nb_states;
        sigma = Array.copy tm.sigma;
        blank=tm.blank;
        i=tm.i;
        f=tm.f;
        delta = Hashtbl.create 36
    } in 

    Hashtbl.iter (fun k v -> 
        Hashtbl.add tm_new.delta k v   
    ) tm.delta;

    tm_new

let run_turing (tm: 'a t) ?(print_step=false) 
  ?(print_letter= fun _ -> ()) (tape: 'a tape): 'a tape =
    let cursor = ref 0 in 
    let state = ref tm.i in  
    let working_tape = copy_tape tape in 
    let break = ref false in 

    if print_step then
        print_tape working_tape ~show_cursor:true ~cursor:!cursor 
          ~state:!state tm.blank print_letter;

    while not (List.mem !state tm.f) && not !break do
        let read_letter = read_tape working_tape tm.blank !cursor in
        
        (* Une étape d'avancement *)
        match Hashtbl.find_opt tm.delta (!state, read_letter) with
            | None -> (
                print_string "Erreur : Etat ";
                print_int !state;
                print_string " avec le symbole ";
                print_letter read_letter;
                print_newline ();
                failwith "Erreur execution, aucune transition à suivre !"
            )
            | Some(q2, write_letter, shift) -> 
                state := q2;
                write_tape working_tape tm.blank !cursor write_letter; 

                if shift = LEFT then decr cursor
                else incr cursor;

                (* Affichage étape par étape *)
                if print_step then 
                    print_tape working_tape ~show_cursor:true ~cursor:!cursor 
                        ~state:!state tm.blank print_letter;
    done;

    if print_step then 
        print_tape working_tape tm.blank print_letter;

    working_tape

let load_turing (filename: string): string t = 
    let ic = open_in filename in 
    let nb_states = ref 0 in
    let nb_symboles = ref 0 in
    let blank = ref "_" in
    let initial_state = ref 0 in
    let final_states = ref [] in
    let delta = Hashtbl.create 36 in

    let line_to_trans_infos str = 
        let l = String.split_on_char ',' str in 
        (
            int_of_string (List.nth l 0),
            List.nth l 1,
            int_of_string (List.nth l 2),
            List.nth l 3,
            if List.nth l 4 = "R" then RIGHT else LEFT
        )
    in

    (
        try
            nb_states := int_of_string (String.trim (input_line ic));
            nb_symboles := int_of_string (String.trim (input_line ic));
            blank := String.trim (input_line ic); 
            initial_state := int_of_string (String.trim (input_line ic));
            final_states := 
                List.map (fun x -> int_of_string x) 
                    (String.split_on_char ',' (String.trim (input_line ic)));

        with Failure _ -> 
            Printf.printf "Problèmes avec les entiers donnés en début de fichier\n"
    );

    let (tm_temp: string t) = {
        nb_states = !nb_states;
        sigma = [||];
        blank = !blank;
        i = !initial_state; 
        f = !final_states; 
        delta = delta
    } in

    let symbols = Hashtbl.create 36 in (* Hashtbl caractère -> indice *)
    let indice = ref 0 in

    (* Parcours de toutes les transitions *)
    try
        while true do 
            let q1, read_letter, q2, write_letter, shift = line_to_trans_infos(String.trim (input_line ic)) in 
            add_transition tm_temp q1 read_letter q2 write_letter shift;

            if read_letter <> !blank then
                match Hashtbl.find_opt symbols read_letter with 
                    | None -> Hashtbl.add symbols read_letter !indice; incr indice
                    | Some _ -> ();

            if write_letter <> !blank then
                match Hashtbl.find_opt symbols write_letter with 
                    | None -> Hashtbl.add symbols write_letter !indice; incr indice
                    | Some _ -> ()
        done;
        let (tm: string t) = {nb_states=0; sigma=[||]; blank="_"; i=0; f=[]; delta=Hashtbl.create 36} in tm
    with 
        | Failure _ -> 
            Printf.printf "Problemes avec des transitions\n"; exit(1)
        | End_of_file -> 
            let sigma = Array.of_list (
                        Hashtbl.fold (
                        fun k v acc -> 
                            k::acc
                    ) symbols []
                )
            in
            
            {
                nb_states = !nb_states;
                sigma = sigma;
                blank = !blank;
                i = !initial_state; 
                f = !final_states; 
                delta = delta
            }

(* Transformation de machines de turing en automates *)

(* Fonctions de création des lettres depuis une machine de turing et l'opération inverse *)
let merge_letters (l1: 'a) (l2: 'a) (k: move) (repr: 'a -> string): string = 
    match k with 
        | RIGHT -> (repr l1) ^ "R" ^ (repr l2) 
        | LEFT -> (repr l1) ^ "L" ^ (repr l2)

let unmerge_letters (s: string) (unrepr: string -> 'a): ('a * 'a * move) = 
    let n = String.length s in 
    match String.index_opt s 'R' with 
    | Some i -> 
        let l1 = unrepr (String.sub s 0 i) in 
        let l2 = unrepr (String.sub s (i+1) (n-i-1)) in 
        (l1, l2, RIGHT)
    | None ->
        match String.index_opt s 'L' with
        | None -> failwith ("Lettre non conformes " ^ s)
        | Some i -> 
            let l1 = unrepr (String.sub s 0 i) in 
            let l2 = unrepr (String.sub s (i+1) (n-i-1)) in 
            (l1, l2, LEFT)

let turing_to_automaton (tm: 'a t) (repr_letter: 'a -> string): string Automaton.t =
    (* 
    Pour deux lettres a et b ainsi qu'une direction K, on ajoute au nouvel 
    alphabet la lettre aKb, soit pour |sigma| = n, |sigma'| = 2((n+1)^2) + 1 
    (en comptant le blanc, et qu'on stock tel quel est en derniere position)
    *)
    let n = Array.length tm.sigma in
    let sigma' = Array.make (2*(n+1)*(n+1) + 1) (repr_letter tm.blank) in

    let count = ref 0 in 
    for i=0 to n-1 do
        for j=0 to n-1 do
            sigma'.(!count) <- merge_letters tm.sigma.(i) tm.sigma.(j) LEFT repr_letter;
            incr count;
            sigma'.(!count) <- merge_letters tm.sigma.(i) tm.sigma.(j) RIGHT repr_letter;
            incr count;
        done;

        sigma'.(!count) <- merge_letters tm.sigma.(i) tm.blank RIGHT repr_letter;
        incr count;
        sigma'.(!count) <- merge_letters tm.blank tm.sigma.(i) RIGHT repr_letter;
        incr count;

        sigma'.(!count) <- merge_letters tm.sigma.(i) tm.blank LEFT repr_letter;
        incr count;
        sigma'.(!count) <- merge_letters tm.blank tm.sigma.(i) LEFT repr_letter;
        incr count;
    done;

    sigma'.(!count) <- merge_letters tm.blank tm.blank RIGHT repr_letter;
    incr count;
    sigma'.(!count) <- merge_letters tm.blank tm.blank LEFT repr_letter;
    incr count;

    let (a: 'a Automaton.t) = {
        nb_states = tm.nb_states;
        sigma = sigma';
        i = tm.i;
        f = tm.f;
        delta = Hashtbl.create 36;
    } in 

    Hashtbl.iter (fun (k: int* 'a) (v: int * 'a * move) -> 
        let q1, read_letter = k in 
        let q2, write_letter, shift = v in
        let read_letter' = merge_letters read_letter write_letter shift repr_letter in
        Automaton.add_transition a q1 read_letter' q2 
    ) tm.delta;
    a

(* Convertit un automate en machine de turing *)
let automaton_to_turing (a: string Automaton.t) (unrepr_letter: string -> 'a): 'a t =
    let blank = unrepr_letter (a.sigma.(Array.length a.sigma - 1)) in
    
    (* Récupère toutes les lettres utilisées dans l'automate *)
    let sigma_tmp = Hashtbl.create 36 in
    let rec get_letters l acc = match l with 
        | [] -> ()
        | x::q -> 
            (* Passe le cas du symbole juste blanc *)
            if x = blank then get_letters q acc else 

            (* Ajout des deux lettres dans la hashtable *)
            let l1, l2, k = unmerge_letters x unrepr_letter in 
            let count = ref 0 in
            if l1 <> blank then (match Hashtbl.find_opt sigma_tmp l1 with 
                | None -> (Hashtbl.add sigma_tmp l1 acc; incr count)
                | Some _ -> ());

            if l2 <> blank then (match Hashtbl.find_opt sigma_tmp l2 with 
                | None -> (Hashtbl.add sigma_tmp l2 (acc + !count); incr count)
                | Some _ -> ());

            get_letters q (acc + !count)
    in get_letters (Array.to_list a.sigma) 0;

    (* Création de l'alphabet de la machine de turing *)
    let sigma = Array.make (Hashtbl.length sigma_tmp) 
        (unrepr_letter (a.sigma.(Array.length a.sigma - 1))) in
    Hashtbl.iter (fun k v -> sigma.(v) <- unrepr_letter k) sigma_tmp;

    let t = {
        nb_states = a.nb_states;
        sigma = sigma;
        blank = unrepr_letter (a.sigma.(Array.length a.sigma - 1));
        i = a.i;
        f = a.f;
        delta = Hashtbl.create 36
    } in

    (* Ajout des transitions de la machine de turing *)
    Hashtbl.iter (fun k v -> 
        let q1, read_letter = k in 
        let q2 = v in
        let l1, l2, k = unmerge_letters read_letter unrepr_letter in 
        let read_letter' = l1 in 
        let write_letter' = l2 in 
        let shift = k in 
        add_transition t q1 read_letter' q2 write_letter' shift
    ) a.delta;

    t