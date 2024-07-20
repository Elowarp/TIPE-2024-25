(*
 *  Name : Elowan
 *  Creation : 26-06-2024 10:59:45
 *  Last modified : 07-07-2024 17:30:20
 *  File : interpreteur.ml
 *)

open Turing
open Compiler

let blank = "_"

let run_luring (filename: string) ?(verbose=false) (in_tape: string Turing.tape): unit = 
    let tm = Compiler.luring_to_turing filename in
    
    Turing.turing_to_pdf tm (fun e -> e);

    let out_tape = 
        if verbose then Turing.run_turing tm ~print_step:true 
            ~print_letter:print_string in_tape
        else Turing.run_turing tm in_tape
    in
    print_string "Bande résultante : ";
    Turing.print_tape out_tape blank print_string

let string_to_array str =
    let n = String.length str in
    let a = Array.make n "" in 
    for i=0 to n-1 do 
        a.(i) <- Char.escaped (str.[i]);
    done; 
    a

let get_params () = 
    try
        let filename = Sys.argv.(1) in
    
        (* Demander la bande *)
        print_string "Vous êtes en train d'exécuter le fichier ";
        print_string filename;
        print_string ", il faut une entrée pour l'exécution de ce programme, ";
        print_string "merci de l'écrire : (le caractère blanc est le caractère _ )\n";
        let tape_str =  read_line () in
        let tape = Turing.array_to_tape (string_to_array tape_str) blank in 
        print_string "Votre bande est celle ci : ";
        print_tape tape blank print_string;
        (filename, tape)

    with Invalid_argument _ -> print_string "Il manque le nom du fichier pour l'exécution !\n"; exit(1)

let _ = 
    let filename, tape = get_params () in
    print_string "Exécution du programe : \n";
    run_luring filename tape