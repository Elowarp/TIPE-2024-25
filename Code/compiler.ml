(*
 *  Name : Elowan
 *  Creation : 30-06-2024 14:43:38
 *  Last modified : 30-06-2024 14:43:38
 *  File : compiler.ml
 *)

open Turing
open Parser

let blank = "_"

let luring_to_turing (filename: string) : string Turing.t =
    let prgm = Parser.parse filename in

    (* On crée autant d'états que de ligne *)
    let nb_states = ref (List.length prgm) in
    let sigma = Array.of_list (Parser.get_symb prgm blank) in
    let (tm: string Turing.t) = {
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
        | Parser.Move (line, shift) :: q -> 
            add_move_tm tm (line-1) line shift; build_program q
        | Parser.Write (line, Symb(letter)) :: q -> 
            add_write_tm tm (line-1) line letter; build_program q
        | Parser.Goto (line, Cst(line_moving)) :: q -> 
            add_goto_tm tm (line-1) (line_moving-1); build_program q
        | Parser.If (line, Symb(letter), Cst(line_moving)) :: q -> 
            add_if_tm tm (line-1) (line_moving-1) letter; build_program q
        | Parser.End (line) :: q -> tm.f <- (line-1)::(tm.f) ; build_program q
        | Parser.Nothing (line) :: q -> add_nothing_tm tm (line-1) line; build_program q
        | _ -> failwith "Erreur creation machine de turing : code programme non attendu" 
    in build_program prgm

let transition_to_string (q1: int) (read_letter: 'a) (q2: int) (write_letter: 'a)
  (shift: Turing.move) (repr_letter: 'a -> string): string = 
    let move_string = match shift with Turing.LEFT -> "L" | Turing.RIGHT -> "R" in
    let l = [string_of_int q1; 
        repr_letter read_letter; 
        string_of_int q2; 
        write_letter; 
        move_string] 
    in (String.concat "," l)^"\n"

let turing_to_tm_file (filename: string) (tm: 'a Turing.t) (repr_letter: 'a -> string): unit =
    let oc = open_out filename in 
    output_string oc ((string_of_int tm.nb_states)^"\n");
    output_string oc ((string_of_int (Array.length tm.sigma))^"\n");
    output_string oc ((repr_letter tm.blank)^"\n");
    output_string oc ((string_of_int tm.i)^"\n");
    output_string oc ((String.concat "," 
        (List.map (fun e -> string_of_int e) tm.f))^"\n");
    
    Hashtbl.iter (fun k v -> 
        let q1, read_letter = k in 
        let q2, write_letter, shift = v in 
        output_string oc (transition_to_string q1 read_letter q2 write_letter shift repr_letter)
    ) tm.delta;

    close_out oc