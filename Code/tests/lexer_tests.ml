(*
*  Name : Elowan
*  Creation : 06-07-2024 11:09:24
*  Last modified : 06-07-2024 11:09:37
*  File : lexer_tests.ml
*)

open Lexer

let _ = 
    (* Test de la reconnaissance de tous les mots du lexique *)
    let rec lexical str_words lex_words = match str_words, lex_words with 
    | [], [] -> ()
    | [], _ | _, [] -> failwith 
        "Tous les motscles n'ont pas une association au lexique, ou inversement"
    | s::q, lex::r ->
        let lexems = analyse s 0 in 
        assert(List.length lexems = 1);  
        assert(List.nth lexems 0 = (0, lex));
        lexical q r   
    in lexical str_words lex_words;

    (* Tests de la reconnaissance de différents mots clés *)
    let s1 = "If 4 Goto 7 abc Right to _ ; End Nothing " in
    let l1 = [
        (1, LIf); (1, LCst(4)); (1, LGoto); (1, LCst(7));
        (1, LSymb("abc")); (1, LRight); (1, LSymb("to"));
        (1, LSymb("_")); (1, LSemiColon); (1, LEnd); 
        (1, LNothing)
    ] in
    assert(analyse s1 1 = (List.rev l1));

    (* Tests de la reconnaissance d'un fichier *)
    let s2 = "Write ka; Goto 1" in
    let l2 = [
        (2, LWrite); (2, LSymb "ka"); (2, LSemiColon);
        (2, LGoto); (2, LCst(1))
    ] in
    let oc = open_out "temp" in 
    output_string oc s1;
    output_string oc "\n";
    output_string oc s2;
    close_out oc;
    assert(analyse_file "temp" = (l1@l2));
    Sys.remove "temp";