(*
 *  Name : Elowan
 *  Creation : 24-08-2024 13:02:06
 *  Last modified : 25-08-2024 22:30:42
 *)

open Turing

let build_tm (n: int): string Turing.t =
    let sigma = 
        (* C'est un alphabet avec tous les chiffres de 0 à n-1 (en string), avec
            les chaines de caractères "kV" et "kB", k étant un chiffre de 0 à n-1,
            caractérisant la couleur d'un sommet 
            On rajoute de plus les symboles $ et ; pour délimiter les sommets 
            de leurs voisins
        *)
        let a = Array.make (3*n + 2) "" in
        for i = 0 to n - 1 do
            a.(i) <- string_of_int i;
            a.(n + i) <- string_of_int i ^ "V";
            a.(2*n + i) <- string_of_int i ^ "B";
        done;
        a.(3*n) <- "$";
        a.(3*n + 1) <- ";";
        a
    in

    let m = Array.length sigma in (* Nombre de symboles *)

    let tm = {
        nb_states = 31*n+8; (* d'après les calculs *)
        sigma = sigma;
        blank = "_";
        i = 0;
        f = [31*n+7];
        delta = Hashtbl.create 36;
    } in
    (* On veut lire le nom du premier sommet *)
    Hashtbl.add tm.delta (0, "$") (0, "$", RIGHT);

    (* On réserve les 2n premiers états à la lecture des états selon les couleurs 
    de coloration. Elles seront plus simple à acceder par la partie visite 
    Donc on veut lire le sommet 5 avec la couleur bleue, on va dans l'état 5 + n + 1 = B_5
    et si c'est pour la couleur verte, on va dans l'état 5 + 1 = V_5 *)

    (* Renvoie la lettre associé au sommet s et à la couleur color *)
    let colored_edge (s: int) (color: int): string =
        if color = 0 then sigma.(n + s) else sigma.(2*n + s)
    in

    (* Renvoie le sommet vers lequel il faut aller si on veut le visiter 
    en lui appliquant la couleur color *)
    let visite_edge_color (s: int) (color: int): int =
        n*color + s + 1
    in

    (* Lien entre l'état initial et les sommets qui vont lire et être mit à jour par 
    premiere couleur *)
    for i=0 to n-1 do 
        Hashtbl.add tm.delta (0, string_of_int (i)) (i+1, colored_edge (i) 0, RIGHT)
    done;

    (* Donc les 2n premiers états sont réservés *)

    (* Création du bloc prédécésseur du bloc visite *)
    for color=0 to 1 do (* Il en faut un pour chaque sommet, et pour chaque couleur *)
        for i=0 to n-1 do
            (* l'état 2*n + 8*i + k + 9*n*color correspond à l'état k pour la couleur 
            k sur le schema de construction dans le 1er bloc *)

            (* On remplace utilise offset pour plus de clareté *)
            let offset = 2*n + (9*n - 2)*color + 8*i in

            (* Color_i, ; -> 1, ;, R *)
            Hashtbl.add tm.delta (visite_edge_color i color, ";") (offset + 1 , ";", RIGHT);

            (* Construction de toutes les boucles que l'on retrouve dans le bloc *)
            for letter=0 to m-1 do 
                (* 1, letter -> 1, letter, R *)
                Hashtbl.add tm.delta (offset + 1, sigma.(letter)) 
                    (offset + 1, sigma.(letter), RIGHT);

                (* 2 letter -> 2, letter, R *)
                Hashtbl.add tm.delta (offset + 2, sigma.(letter)) 
                    (offset + 2, sigma.(letter), RIGHT);

                (* 4, letter -> 4, letter, L *)
                Hashtbl.add tm.delta (offset + 4, sigma.(letter)) 
                    (offset + 4, sigma.(letter), LEFT);

                if letter <> i then 
                    Hashtbl.add tm.delta (offset + 5, sigma.(letter)) 
                        (offset + 5, sigma.(letter), LEFT);
                
                if sigma.(letter) <> "$" then 
                    Hashtbl.add tm.delta (offset + 6, sigma.(letter)) 
                        (offset + 6, sigma.(letter), RIGHT);

                if sigma.(letter) <> ";" && 
                  sigma.(letter) != colored_edge i color then
                    Hashtbl.add tm.delta (offset + 7, sigma.(letter)) 
                        (offset + 7, sigma.(letter), RIGHT);
            done;

            (* Construction des transitions unitaires entre états *)
            (* 1, _ -> 2, _ R *)
            Hashtbl.add tm.delta (offset + 1, tm.blank) 
                (offset + 2, tm.blank, RIGHT);

            (* 2, _ -> 3, i R *)
            Hashtbl.add tm.delta (offset + 2, tm.blank) 
                (offset + 3, colored_edge i color, RIGHT);

            (* 3, _ -> 4, _ L *)
            Hashtbl.add tm.delta (offset + 3, tm.blank) 
                (offset + 4, tm.blank, LEFT);

            (* 4, _ -> 5, _ L *)
            Hashtbl.add tm.delta (offset + 4, tm.blank) 
                (offset + 5, tm.blank, LEFT);

            (* 5, _ -> 6, _ R *)
            Hashtbl.add tm.delta (offset + 5, tm.blank) 
                (offset + 6, tm.blank, RIGHT);

            (* 6, $ -> 7, $ R *)
            Hashtbl.add tm.delta (offset + 6, "$") 
                (offset + 7, "$", RIGHT);

            (* 7, ; -> 6, ; R *)
            Hashtbl.add tm.delta (offset + 7, ";") 
                (offset + 6, ";", RIGHT);

            (* 7, "icolor" -> 8, "icolor" R *)
            Hashtbl.add tm.delta (offset + 7, colored_edge i color) 
                (offset + 8, colored_edge i color, RIGHT);
        done
    done;

    (** Donc les 19n - 2 premiers états sont réservés *)

    (* Création des fonctions de visites *)
    (* 19n - 1 est pour colorier les états qui viennent en vert *)
    (* 19n est pour colorier les états qui viennent en bleu *)
    let visite_block_color color = 19*n - 1 + color  in

    (* On relie le bloc précédent aux briques visites
    en inversant les couleurs de visite *)
    for i=0 to n-1 do 
        let offset color = (9*n - 2)*color + 2*n + 8*i in
        Hashtbl.add tm.delta (offset 1 + 8, ";") (visite_block_color 0, ";", RIGHT);
        Hashtbl.add tm.delta (offset 0 + 8, ";") (visite_block_color 1, ";", RIGHT);
    done;

    for color=0 to 1 do
        (* Comme précédemment, offset color + q revient à regarder 
        l'état k_q du bloc visiter, la couleur permettant de distinguer
        les deux blocs visite*)        
        
        for i=0 to n-1 do
            let offset color = (19*n) + (3*n)*color +3*i in

            (* block color, i -> k_1, i L *)
            Hashtbl.add tm.delta (visite_block_color color, string_of_int i) 
                (offset color + 1, string_of_int i, LEFT);
            
            (* k_1, _ -> k_2, _, R *)
            Hashtbl.add tm.delta (offset color + 1, tm.blank) 
                (offset color + 2, tm.blank, RIGHT);

            (* k_2, $ -> k_3, $, R *)
            Hashtbl.add tm.delta (offset color + 2, "$") 
                (offset color + 3, tm.blank, RIGHT);

            (* k_3, ; -> k_2, ;, R *)
            Hashtbl.add tm.delta (offset color + 3, ";") 
                (offset color + 2, ";", RIGHT);

            (* k_3, i -> B_k, i, R *)
            Hashtbl.add tm.delta (offset color + 3, string_of_int i) 
                (visite_edge_color i color, colored_edge i color, RIGHT);

            for letter=0 to m-1 do
                (* k_1, letter -> k_1, letter, L *)
                Hashtbl.add tm.delta (offset color+1, sigma.(letter)) 
                    (offset color+1, sigma.(letter), LEFT);

                if tm.sigma.(letter) <> "$" then
                    (* k_2, letter -> k_2, letter, R *)
                    Hashtbl.add tm.delta (offset color+2, sigma.(letter)) 
                        (offset color+2, sigma.(letter), RIGHT);

                if tm.sigma.(letter) <> ";" && letter <> i then
                    (* k_3, letter -> k_3, letter, R *)
                    Hashtbl.add tm.delta (offset color+3, sigma.(letter)) 
                        (offset color+3, sigma.(letter), RIGHT)
            done
        done
    done;

    (* On a donc utilisé les 25n premiers états*)

    (* Lien entre le premier etat de la visite bleue, et du début de la partie basse *)
    (* visite_block_blue, $ -> 25n+2 $, R *)
    Hashtbl.add tm.delta (visite_block_color 1, "$") (25*n + 1, "$", RIGHT);

    (* Idem pour vert *)
    (* visite_block_green, $ -> 25+2 $, R *)
    Hashtbl.add tm.delta (visite_block_color 0, "$") (25*n + 1, "$", RIGHT);

    (* Offset du début de la partie basse du schema *)
    let offset = 25*n + 1 in

    for letter=0 to m-1 do
        (* 1, letter -> 1, letter, R*)
        Hashtbl.add tm.delta (offset+1, sigma.(letter)) 
            (offset+1, sigma.(letter), RIGHT);

        (* 2, letter -> 2, letter, R *)
        Hashtbl.add tm.delta (offset + 2, sigma.(letter)) 
            (offset + 2, sigma.(letter), RIGHT);

        (* 3, letter -> 4, _, L *)
        Hashtbl.add tm.delta (offset + 3, sigma.(letter)) 
            (offset + 4, tm.blank, LEFT);
    done;

    (* 1, _ -> 2, _, R *)
    Hashtbl.add tm.delta (offset+1, tm.blank) (offset + 2, tm.blank, RIGHT);

    (* 2, _ -> 3, _, L *)
    Hashtbl.add tm.delta (offset + 2, tm.blank) (offset + 3, tm.blank, LEFT);

    (* 4, _ -> q_acc, _, L *)
    Hashtbl.add tm.delta (offset + 4, tm.blank) (tm.nb_states - 1, tm.blank, LEFT);

    (*29n +4*)
    for i=0 to n-1 do
        (* Offset tq offset+q = k_q *)
        let offset = 25*n + 4 + 4*i in

        (* 4, k -> k_1 L*)
        Hashtbl.add tm.delta (25*n + 4, string_of_int i) 
            (offset + 1, string_of_int i, LEFT);
        
        for letter = 0 to m-1 do 
            (* 1, letter -> 1, letter L*)
            Hashtbl.add tm.delta (offset + 1, sigma.(letter)) 
                (offset + 1, sigma.(letter), LEFT);

            (* 2, letter -> 2, letter L*)
            Hashtbl.add tm.delta (offset + 2, sigma.(letter)) 
                (offset + 2, sigma.(letter), LEFT);

            if sigma.(letter) <> "$" then
                (* 3, letter -> 3, letter R*)
                Hashtbl.add tm.delta (offset + 3, sigma.(letter)) 
                    (offset + 3, sigma.(letter), RIGHT);

            if sigma.(letter) <> ";" && sigma.(letter) <> colored_edge i 0
              && sigma.(letter) <> colored_edge i 1 then
                (* 4, letter -> 4, letter R*)
                Hashtbl.add tm.delta (offset + 4, sigma.(letter)) 
                    (offset + 4, sigma.(letter), RIGHT);
        done;

        (* 1, _ -> 2, _ L *)
        Hashtbl.add tm.delta (offset + 1, tm.blank) (offset + 2, tm.blank, LEFT);

        (* 2, _ -> 3, _ R *)
        Hashtbl.add tm.delta (offset + 2, tm.blank) (offset + 3, tm.blank, RIGHT);

        (* 3, $ -> 4, $ R *)
        Hashtbl.add tm.delta (offset + 3, "$") (offset + 4, "$", RIGHT);

        (* 4, ; -> 3, ; R *)
        Hashtbl.add tm.delta (offset + 4, ";") (offset + 3, ";", RIGHT);

        (* 4, iV -> V_5, iV R *)
        Hashtbl.add tm.delta (offset + 4, colored_edge i 0) 
            (29*n + 5, colored_edge i 0, RIGHT);

        (* 4, iB -> B_5, iB R *)
        Hashtbl.add tm.delta (offset + 4, colored_edge i 1) 
            (29*n + 6, colored_edge i 1, RIGHT);
    done;


    (* A partir d'ici, le premier état libre est le 29n + 7 *)

    let color_6 color = 29*n + 5 + color in    
    for color=0 to 1 do
        for i=0 to n-1 do 
            let offset color = 29*n + 6 + n*color + i in

            (* color_6, k -> kColor_7, k, R *)
            Hashtbl.add tm.delta (color_6 color, string_of_int i) 
                (offset color + 1, string_of_int i, RIGHT);

            (* kColor_7, sigma et _  -> bloc visite (1-color), sigma et _, L *)
            for letter=0 to m-1 do
                Hashtbl.add tm.delta (offset color + 1, sigma.(letter)) 
                    (19*n + (1-color), sigma.(letter), LEFT);
            done;
            Hashtbl.add tm.delta (offset color + 1, tm.blank) 
                (19*n + (1-color), tm.blank, LEFT);

            (* Boucle de transition sur color_6*)
            (* color_6, i(1-color) -> color_6, i(1-color), R*)
            Hashtbl.add tm.delta (color_6 color, colored_edge i (1-color)) 
                (color_6 color, colored_edge i (1-color), RIGHT);
        done;

        (* color_6, $, -> bloc fin de pile, $, R *)
        Hashtbl.add tm.delta (color_6 color, "$") 
            (25*n+2, "$", RIGHT);

        (* color_6, _ -> bloc fin de pile, _, L *)
        Hashtbl.add tm.delta (color_6 color, tm.blank) 
            (25*n+2, tm.blank, LEFT);
    done;

    tm

let _ = 
    let tm = build_tm 1 in
    Turing.turing_to_pdf tm (fun x -> x)