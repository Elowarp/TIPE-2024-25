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

(* Construit les instructions en suivant les règles de dérivation des 
   grammaires A S et P *)
let rec parse_A (l: Lexer.t list) : exp_arith * Lexer.t list = 
  match l with 
    | (_, LCst(i))::q -> (Cst(i), q)
    | (_, LSymb(s))::q -> (Symb(s), q)
    | _ -> failwith "Erreur parsing, expression arithmétique attendue"

and parse_S (l: Lexer.t list) : shift * Lexer.t list = 
    match l with 
        | (_, LLeft)::q -> (Left, q)
        | (_, LRight)::q -> (Right, q)
        | _ -> failwith "Erreur parsing, expression de direction attendue"

and parse_P (l: Lexer.t list) : program list = 
    let code, q = 
        match l with 
            | (code_line, LIf)::q -> (
                let (symb, q') = parse_A q in
                match q' with 
                    | (_, LGo)::q' -> 
                        let (line, q') = parse_A q' in (
                            match symb, line with 
                                | Symb(_), Cst(_) -> (If(code_line, symb, line), q')
                                | Cst(s), Cst(_) -> (If(code_line, Symb(string_of_int s), line), q')
                                | _, _-> failwith "Erreur parsing, symbole et/ou ligne attendu"
                        )
                        
                    | _ -> failwith "Erreur parsing, Go attendue"
            )
            | (code_line, LWrite)::q -> 
                let symb, q' = parse_A q in (
                    match symb with 
                        | Symb(s) -> (Write(code_line, Symb(s)), q')
                        | Cst(s) -> (Write(code_line, Symb(string_of_int s)), q')
                )
            | (code_line, LMove)::q -> let dir, q' = parse_S q in (Move(code_line, dir), q')
            | (code_line, LGoto)::q -> let symb, q' = parse_A q in (
                match symb with
                    | Cst(c) -> (Goto(code_line, Cst(c)), q')
                    | _ -> failwith "Erreur parsing, ligne attendue"
                )
            | (code_line, LNothing)::q -> (Nothing (code_line), q)
            | (code_line, LEnd)::q -> (End (code_line), q)
            | _ -> failwith "Erreur parsing, expression manquante"
    in

    (* Vérifie que l'on ne puisse pas continuer à construire le programme *)
    match q with 
        | [] -> [code]
        | _ -> let next_code = parse_P q in (code::next_code)  

(* Transforme un fichier en liste de commande interprétable *)
let parse (filename: string): program list =
    let lexems = analyse_file filename in
    let prgm = parse_P lexems in
    prgm

(* Ajout un élément que s'il n'est pas déjà présent *)
let rec add_unique (e: 'a) (l: 'a list): 'a list =
    match l with 
        | [] -> [e]
        | h::q -> if h = e then l else h::(add_unique e q)

(* Retourne tous les symboles utilisés dans le programme *)
let get_symb (prgm: program list) (blank: string): string list =
    let rec aux prgm acc = match prgm with
        | [] -> acc
        | code::q -> (
            match code with 
            | If(_, Symb(s), _) -> 
                if s <> blank then aux q (add_unique s acc) else aux q acc
            | Write(_, Symb(s)) -> 
                if s <> blank then aux q (add_unique s acc) else aux q acc
            | _ -> aux q acc
        )
    in aux prgm []

(* Créer le gadget de la machine de turing pour l'instruction move *)
let add_move_tm  (tm: string Turing.t) (start_state: int) (end_state: int)
  (shift: shift): unit = 
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
                tm.blank Turing.RIGHT
        )

(* Créer le gadget de la machine de turing pour l'instruction write *)
let add_write_tm  (tm: string Turing.t) (start_state: int) (end_state: int)
  (write_letter: string): unit=
    tm.nb_states <- tm.nb_states + 1;
    for i=0 to Array.length (tm.sigma) - 1 do
        add_transition tm start_state tm.sigma.(i) (tm.nb_states-1) 
            write_letter Turing.RIGHT;
        add_transition tm (tm.nb_states-1) tm.sigma.(i) end_state 
            tm.sigma.(i) Turing.LEFT
    done;
    
    (* Cas du caractère blanc *)
    add_transition tm start_state tm.blank (tm.nb_states-1) 
        write_letter Turing.RIGHT;
    add_transition tm (tm.nb_states-1) tm.blank end_state 
        tm.blank Turing.LEFT
    
(* Créer le gadget de la machine de turing pour l'instruction goto *)
let add_goto_tm (tm: string Turing.t) (start_state: int) (end_state: int): unit = 
    tm.nb_states <- tm.nb_states + 1;
    for i=0 to Array.length (tm.sigma) - 1 do
        add_transition tm start_state tm.sigma.(i) (tm.nb_states-1) 
            tm.sigma.(i) Turing.RIGHT;
        add_transition tm (tm.nb_states-1) tm.sigma.(i) end_state 
            tm.sigma.(i) Turing.LEFT
    done;

    (* Cas du caractère blanc *)
    add_transition tm start_state tm.blank (tm.nb_states-1) 
        tm.blank Turing.RIGHT;
    add_transition tm (tm.nb_states-1) tm.blank end_state 
        tm.blank Turing.LEFT

(* Créer le gadget de la machine de turing pour l'instruction if *)
let add_if_tm (tm: string Turing.t) (start_state: int) (end_state: int) 
  (read_letter: string): unit = 
    tm.nb_states <- tm.nb_states + 2;
    
    for i=0 to Array.length (tm.sigma) - 1 do
        if tm.sigma.(i) = read_letter then 
            add_transition tm start_state tm.sigma.(i) (tm.nb_states-2)
                read_letter Turing.RIGHT
        else
            add_transition tm start_state tm.sigma.(i) (tm.nb_states-1) 
                tm.sigma.(i) Turing.RIGHT;
            
        add_transition tm (tm.nb_states-2) tm.sigma.(i) end_state 
            tm.sigma.(i) Turing.LEFT;
        add_transition tm (tm.nb_states-1) tm.sigma.(i) (start_state+1) 
            tm.sigma.(i) Turing.LEFT
    done;

    (* Cas du caractère blanc *)
    if read_letter = tm.blank then 
        add_transition tm start_state tm.blank (tm.nb_states-2) 
            tm.blank Turing.RIGHT
    else
        add_transition tm start_state tm.blank (tm.nb_states-1) 
            tm.blank Turing.RIGHT;
  
    add_transition tm (tm.nb_states-2) tm.blank end_state 
        tm.blank Turing.LEFT;
    add_transition tm (tm.nb_states-1) tm.blank (start_state+1) 
        tm.blank Turing.LEFT

let add_nothing_tm (tm: string Turing.t) (start_state: int) (end_state: int): unit =
    add_goto_tm tm start_state end_state