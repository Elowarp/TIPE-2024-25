(*
 *  Name : Elowan
 *  Creation : 26-06-2024 23:54:48
 *  Last modified : 29-06-2024 23:54:40
 *  File : parser.ml
 *)
open Lexer
open Turing

type shift = 
| Right
| Left

type exp_arith =
| Cst of int
| Symb of string

type program =
| Nothing of int
| Sequence of program list (* Sequence pas encore pris en charge *)
| If of int * exp_arith * exp_arith
| Write of int * exp_arith
| Move of int * shift
| Goto of int * exp_arith
| End of int

let blank = "_"

(* Construit les instructions en suivant les règles de dérivation des 
   grammaires A S et P *)
let rec parse_A (l: lexem list) : exp_arith * lexem list = 
  match l with 
    | (_, LCst(i))::q -> (Cst(i), q)
    | (_, LSymb(s))::q -> (Symb(s), q)
    | _ -> failwith "Erreur parsing, expression arithmétique attendue"

and parse_S (l: lexem list) : shift * lexem list = 
    match l with 
        | (_, LLeft)::q -> (Left, q)
        | (_, LRight)::q -> (Right, q)
        | _ -> failwith "Erreur parsing, expression de direction attendue"

and parse_P (l: lexem list) : program list = 
    let code, q = 
        match l with 
            | (code_line, LIf)::q -> (
                let (symb, q') = parse_A q in
                match q' with 
                    | (_, LGo)::q' -> 
                        let (line, q') = parse_A q' in (
                            match symb, line with 
                                | Symb(_), Cst(_) -> (If(code_line, symb, line), q')
                                | _, _-> failwith "Erreur parsing, symbole et/ou ligne attendu"
                        )
                        
                    | _ -> failwith "Erreur parsing, Go attendue"
            )
            | (code_line, LWrite)::q -> 
                let symb, q' = parse_A q in (
                    match symb with 
                        | Symb(s) -> (Write(code_line, Symb(s)), q')
                        | _ -> failwith "Erreur parsing, symbole attendu"
                )
            | (code_line, LMove)::q -> let dir, q' = parse_S q in (Move(code_line, dir), q')
            | (code_line, LGoto)::q -> let symb, q' = parse_A q in (
                match symb with
                    | Cst(c) -> (Goto(code_line, Cst(c)), q')
                    | _ -> failwith "Erreur parsing, ligne attendue"
                )
            | (code_line, LNothing)::q -> (Nothing (code_line), q)
            | (code_line, LEnd)::q -> (End (code_line), q)
            | _ -> failwith "Expression manquante"
    in

    (* Vérifie que l'on ne puisse pas continuer à construire le programme *)
    match q with 
        | [] -> [code]
        | _ -> let next_code = parse_P q in (code::next_code)  

let parse (filename: string): program list =
    let lexems = analyse_fichier filename in
    let prgm = parse_P lexems in
    prgm

let rec ajoute_no_doublons (e: 'a) (l: 'a list): 'a list =
    match l with 
        | [] -> [e]
        | h::q -> if h = e then l else h::(ajoute_no_doublons e q)
let get_symb (prgm: program list) (blank: string): string list =
    let rec aux prgm acc = match prgm with
        | [] -> acc
        | code::q -> (
            match code with 
            | If(_, Symb(s), _) -> 
                if s <> blank then aux q (ajoute_no_doublons s acc) else aux q acc
            | Write(_, Symb(s)) -> 
                if s <> blank then aux q (ajoute_no_doublons s acc) else aux q acc
            | _ -> aux q acc
        )
    in aux prgm []

let add_move_tm (start_state: int) (end_state: int) (tm: string turing_machine)
  (shift: shift) = 
    match shift with
        | Left -> (
            for i=0 to Array.length (tm.sigma) - 1 do
                add_transition tm start_state tm.sigma.(i) end_state 
                    tm.sigma.(i) Turing.LEFT
            done;
            add_transition tm start_state tm.blank end_state 
                tm.blank Turing.LEFT
        )
        | Right -> (
            for i=0 to Array.length (tm.sigma) - 1 do
                add_transition tm start_state tm.sigma.(i) end_state 
                    tm.sigma.(i) Turing.RIGHT
            done;
            add_transition tm start_state tm.blank end_state 
                tm.blank Turing.LEFT
        )

let add_write_tm (start_state: int) (end_state: int) (tm: string turing_machine)
  (write_letter: string) =
    tm.nb_states <- tm.nb_states + 1;
    for i=0 to Array.length (tm.sigma) - 1 do
        add_transition tm start_state (tm.sigma.(i)) (tm.nb_states-1) write_letter Turing.RIGHT;
        add_transition tm (tm.nb_states-1) (tm.sigma.(i)) end_state (tm.sigma.(i)) Turing.LEFT
    done;
    
    (* Cas du caractère blanc *)
    add_transition tm start_state tm.blank (tm.nb_states-1) write_letter Turing.RIGHT;
    add_transition tm (tm.nb_states-1) tm.blank end_state tm.blank Turing.LEFT
    
let add_goto_tm (start_state: int) (end_state: int) (tm: string turing_machine) = 
    tm.nb_states <- tm.nb_states + 1;
    for i=0 to Array.length (tm.sigma) - 1 do
        add_transition tm start_state tm.sigma.(i) (tm.nb_states-1) tm.sigma.(i) Turing.RIGHT;
        add_transition tm (tm.nb_states-1) tm.sigma.(i) end_state tm.sigma.(i) Turing.LEFT
    done;

    (* Cas du caractère blanc *)
    add_transition tm start_state tm.blank (tm.nb_states-1) tm.blank Turing.RIGHT;
    add_transition tm (tm.nb_states-1) tm.blank end_state tm.blank Turing.LEFT

let add_if_tm (start_state: int) (end_state: int) (tm: string turing_machine) 
  (read_letter: string) = 
    tm.nb_states <- tm.nb_states + 2;
    
    (* Cas on lit la lettre *)
    add_transition tm start_state read_letter (tm.nb_states-1) read_letter Turing.RIGHT;
    
    for i=0 to Array.length (tm.sigma) - 1 do
        if tm.sigma.(i) <> read_letter then 
            (* Cas de si on ne lit pas la lettre read_letter *)
            add_transition tm start_state (tm.sigma.(i)) (tm.nb_states-2) (tm.sigma.(i)) Turing.RIGHT;
            
        add_transition tm (tm.nb_states-1) (tm.sigma.(i)) end_state (tm.sigma.(i)) Turing.LEFT;
        add_transition tm (tm.nb_states-2) (tm.sigma.(i)) (start_state+1) (tm.sigma.(i)) Turing.LEFT
    done;

    (* Cas du caractère blanc *)
    if read_letter <> tm.blank then 
        add_transition tm start_state tm.blank (tm.nb_states-2) tm.blank Turing.RIGHT;
            
    add_transition tm (tm.nb_states-1) tm.blank end_state tm.blank Turing.LEFT;
    add_transition tm (tm.nb_states-2) tm.blank (start_state+1) tm.blank Turing.LEFT

let luring_to_turing (filename: string) : string turing_machine =
    let prgm = parse filename in

    (* On crée autant d'états que de ligne *)
    let nb_states = ref (List.length prgm) in
    let sigma = Array.of_list (get_symb prgm blank) in
    let (tm: string turing_machine) = {
        (* Toutes les lignes + l'état final de fin de prgm *)
        nb_states = !nb_states + 1; 
        sigma=sigma; 
        blank=blank; 
        i=0; 

        (* On termine le programme quoi qu'il arrive à la fin du prgm *)
        f=[!nb_states];  

        delta=Hashtbl.create 36
    } in
    
    (* Convertit la liste de commandes en états et transitions *)
    (* Les états commençant à 0, on doit soustraire 1 au nombre de lignes *)
    let rec build_program code = match code with 
        | [] -> tm
        | Move (line, shift) :: q -> 
            add_move_tm (line-1) line tm shift; build_program q
        | Write (line, Symb(letter)) :: q -> 
            add_write_tm (line-1) line tm letter; build_program q
        | Goto (line, Cst(line_moving)) :: q -> 
            add_goto_tm (line-1) line_moving tm; build_program q
        | If (line, Symb(letter), Cst(line_moving)) :: q -> 
            add_if_tm (line-1) (line_moving-1) tm letter; build_program q
        | End (line) :: q -> tm.f <- (line-1)::(tm.f) ; build_program q
        | Nothing (line) :: q -> build_program q
        | _ -> failwith "Erreur création machine de turing : code programme non attendu" 
    in build_program prgm

let _ = 
    let tm = luring_to_turing "luring_programs/ex1.lu" in 
    Turing.print_turing tm print_string;
    let tape = Turing.run_turing tm ~print_step:true ~print_letter:print_string
        (Turing.array_to_tape [|"a"; "_"; "b"|] blank) in ()