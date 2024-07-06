(*
 *  Name : Elowan
 *  Creation : 03-07-2024 16:31:06
 *  Last modified : 03-07-2024 16:31:06
 *)

open Turing

let shift_to_string shift = 
    match shift with 
        | Turing.LEFT -> "Left"
        | Turing.RIGHT -> "Right"

(* Un fichier se decompose en plusieurs parties conformément au document history.md 
   date 3/07/24
   Et cette variable compte le nb de lignes avant que la partie "sommaire" ne débute
*)
let nb_lines_before_index = 1

let from_state_to_luring (tm: 'a Turing.t) (q: int) (nb_lines: int)
  (repr_letter: 'a -> string) 
  (code_acc: string list): int * string list = 
    let nb_lines = ref nb_lines in 
    let code = ref code_acc in 

    (* Calcule du nb de transitions *)
    for i=0 to Array.length tm.sigma - 1 do 
        match Hashtbl.find_opt tm.delta (q, tm.sigma.(i)) with 
            | None -> ()
            | Some _ -> nb_lines := !nb_lines + 1;
    done;
    (* Cas du caractère blanc *)
    (match Hashtbl.find_opt tm.delta (q, tm.blank) with 
        | None -> ()
        | Some _ -> nb_lines := !nb_lines + 1);


    (* Création des renvois aux transitions *)
    (* Sachant que chaque transition prend 3 lignes *)
    for i=0 to Array.length tm.sigma - 1 do 
        match Hashtbl.find_opt tm.delta (q, tm.sigma.(i)) with 
            | None -> ()
            | Some _ -> 
                code := ("If "^(repr_letter tm.sigma.(i))
                ^" Go "^(string_of_int (!nb_lines+1)))
                ::(!code);
                nb_lines := !nb_lines + 3;
    done;
    (* Cas du caractère blanc *)
    (match Hashtbl.find_opt tm.delta (q, tm.blank) with 
        | None -> ()
        | Some _ -> 
            code := ("If "^(repr_letter tm.blank)
            ^" Go "^(string_of_int (!nb_lines+1)))
            ::(!code);
            nb_lines := !nb_lines + 3);

    (* Création des transitions dans le fichier *)
    for i=0 to Array.length tm.sigma - 1 do 
        match Hashtbl.find_opt tm.delta (q, tm.sigma.(i)) with 
            | None -> ()
            | Some (q2, write_letter, shift) -> 
                code := ("Goto "^((string_of_int (q2+1+nb_lines_before_index))))
                ::("Move "^(shift_to_string shift))
                ::("Write "^(repr_letter write_letter))
                ::(!code);
    done;
    (match Hashtbl.find_opt tm.delta (q, tm.blank) with 
        | None -> ()
        | Some (q2, write_letter, shift) -> 
            code := ("Goto "^((string_of_int (q2+1+nb_lines_before_index))))
            ::("Move "^(shift_to_string shift))
            ::("Write "^(repr_letter write_letter))
            ::(!code));
    (!nb_lines, !code)
     

let tm_to_luring (out_filename: string) (tm: 'a Turing.t) (repr_letter: 'a -> string): unit = 
    (* Tableau des reférences des lignes vers lesquelles pointent les états *)
    let line_refs = Array.init tm.nb_states (fun x -> ref x) in

    let rec construct_code q line code_acc = 
        if q >= tm.nb_states then code_acc 
        else
            begin
            (line_refs.(q)) := line;
            if List.mem q tm.f then 
                    construct_code (q+1) (line+1) ("End"::code_acc)                
            else
                (
                    let nb_lines, code_acc = from_state_to_luring tm q line 
                        repr_letter code_acc in
                    construct_code (q+1) nb_lines code_acc
                )   
            end
    in 


    (* Redirection vers l'état initial, puis sommaire des lignes des états*) 
    let redirections = ref ["Goto "^(string_of_int (tm.i+2))] in 
    let code = construct_code 0 (tm.nb_states+1) [] in 
    (* +1 parce qu'on a déjà écrit la 1ere ligne pour aller à l'état initial  *)

    (* Boucle créant le sommaire *)
    for i=0 to tm.nb_states - 1 do 
        redirections := ("Goto "^(string_of_int (!(line_refs.(i))+1)))::!redirections;
    done;

    let oc = open_out out_filename in 
    output_string oc (String.concat "\n" (List.rev (code@(!redirections))))

let _ = 
    let filename = Sys.argv.(1) in 
    let exportname = Sys.argv.(2) in 

    tm_to_luring exportname (Turing.load_turing filename) (fun x -> x)