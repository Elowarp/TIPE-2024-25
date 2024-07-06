(*
 *  Name : Elowan
 *  Creation : 03-07-2024 23:07:56
 *  Last modified : 03-07-2024 23:07:56
 *)

open Turing
open Lexer
open Parser

let are_hashtbl_equals tbl1 tbl2 = 
    let check = ref true in

    Hashtbl.iter (fun k v -> 
        match Hashtbl.find_opt tbl2 k with
            | None -> check := false 
            | Some v' -> check := !check&&(v = v')
    ) tbl1;

    Hashtbl.iter (fun k v -> 
        match Hashtbl.find_opt tbl1 k with
            | None -> check := false 
            | Some v' -> check := !check&&(v = v')
    ) tbl2;

    !check

let _ = 
    (* Test du parsing des lexems *)
    let lex_if = [(1, LIf); (1, LSymb("a")); (1, LGo); (1, LCst 4)] in
    let lex_write = [(2, LWrite); (2, LSymb("pka"))] in 
    let lex_goto = [(3, LGoto); (3, LCst(2))] in 
    let lex_move = [(4, LMove); (4, LRight)] in 
    let lex_end = [(5, LEnd)] in 
    let lex_nothing = [(6, LNothing)] in
    (*let lex_semicolon = [(7, LSemiColon)] in*) (*Non pris en charge*)

    assert(parse_P lex_if = [If(1, Symb "a", Cst 4)]);
    assert(parse_P lex_write = [Write(2, Symb "pka")]);
    assert(parse_P lex_goto = [Goto(3, Cst 2)]);
    assert(parse_P lex_move = [Move(4, Right)]);
    assert(parse_P lex_end = [End(5)]);
    assert(parse_P lex_nothing = [Nothing(6)]);
    (*assert(parse_P lex_semicolon = [Semicolon(7)]);*) (*Non pris en charge*)

    let oc = open_out "temp" in 
    let s1 = "If abc Go 4\n" in
    let s2 = "Write bc\n" in 
    let s3 = "Nothing" in 
    let prgm = [
        If(1, Symb("abc"), Cst(4));
        Write(2, Symb("bc"));
        Nothing(3);
    ] in
    output_string oc s1;
    output_string oc s2;
    output_string oc s3;
    close_out oc;

    assert(parse "temp" = prgm);
    Sys.remove "temp";

    (* Test de l'ajout sans doublons *)
    assert(add_unique 2 [] = [2]);
    assert(add_unique 2 [2] = [2]);
    assert(add_unique 2 [4; 2; 3] = [4; 2; 3]);
    assert(add_unique 9 [4; 2; 3] = [4; 2; 3; 9]);

    (* Test de la détection de tous les symboles *)
    assert(get_symb [] "_" = []);
    assert(get_symb prgm "_" = ["abc"; "bc"]);
    assert(get_symb prgm "bc" = ["abc"]);
    assert(get_symb [Goto(1, Cst 1); Nothing(3)] "_" = []);

    (* Test des ajouts des gadgets *)
    let blank = "_" in
    let tm_init = {
        nb_states = 2;
        sigma = [|"a"; "b"|];
        blank = blank;
        i=0;
        f=[1];
        delta = Hashtbl.create 36
    } in 

    let tm_move = duplicate_turing tm_init in
    Turing.add_transition tm_move 0 "a" 1 "a" RIGHT;
    Turing.add_transition tm_move 0 "b" 1 "b" RIGHT;
    Turing.add_transition tm_move 0 blank 1 blank RIGHT;

    let tm_init_move = duplicate_turing tm_init in
    add_move_tm tm_init_move 0 1 Right;

    (* Le gadget move est bien inséré *)
    assert(are_hashtbl_equals tm_move.delta tm_init_move.delta);

    (* Test de l'écriture de a depuis l'état 0 vers l'état 1 *)
    let tm_write = duplicate_turing tm_init in
    tm_write.nb_states <- 3;
    Turing.add_transition tm_write 0 "a" 2 "a" RIGHT;
    Turing.add_transition tm_write 0 "b" 2 "a" RIGHT;
    Turing.add_transition tm_write 0 blank 2 "a" RIGHT;

    Turing.add_transition tm_write 2 "a" 1 "a" LEFT;
    Turing.add_transition tm_write 2 "b" 1 "b" LEFT;
    Turing.add_transition tm_write 2 blank 1 blank LEFT;

    let tm_init_write = duplicate_turing tm_init in
    add_write_tm tm_init_write 0 1 "a";
    assert(are_hashtbl_equals tm_write.delta tm_init_write.delta);
    
    (* Test du renvoie à la ligne 2*)
    let tm_goto = duplicate_turing tm_init in 
    tm_goto.nb_states <- 3;
    Turing.add_transition tm_goto 0 "a" 2 "a" RIGHT;
    Turing.add_transition tm_goto 0 "b" 2 "b" RIGHT;
    Turing.add_transition tm_goto 0 blank 2 blank RIGHT;

    Turing.add_transition tm_goto 2 "a" 1 "a" LEFT;
    Turing.add_transition tm_goto 2 "b" 1 "b" LEFT;
    Turing.add_transition tm_goto 2 blank 1 blank LEFT;

    let tm_init_goto = duplicate_turing tm_init in
    add_goto_tm tm_init_goto 0 1;
    assert(are_hashtbl_equals tm_goto.delta tm_init_goto.delta);

    (* Test du si a alors go 3 sinon go 2 *)
    let tm_if = duplicate_turing tm_init in 
    tm_if.nb_states <- 5;
    Turing.add_transition tm_if 0 "a" 3 "a" RIGHT;

    Turing.add_transition tm_if 3 "a" 2 "a" LEFT;
    Turing.add_transition tm_if 3 "b" 2 "b" LEFT;
    Turing.add_transition tm_if 3 blank 2 blank LEFT;

    Turing.add_transition tm_if 0 "b" 4 "b" RIGHT;
    Turing.add_transition tm_if 0 blank 4 blank RIGHT;

    Turing.add_transition tm_if 4 "a" 1 "a" LEFT;
    Turing.add_transition tm_if 4 "b" 1 "b" LEFT;
    Turing.add_transition tm_if 4 blank 1 blank LEFT;

    let tm_init_if = duplicate_turing tm_init in
    tm_init_if.nb_states <- 3;
    add_if_tm tm_init_if 0 2 "a";
    assert(are_hashtbl_equals tm_if.delta tm_init_if.delta)