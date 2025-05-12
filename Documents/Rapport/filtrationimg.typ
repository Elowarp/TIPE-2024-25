/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 12-05-2025 08:28:15
 *  Last modified : 12-05-2025 09:06:46
 *  File : filtrationimg.typ
 */
#import "@preview/cetz:0.3.4"
#set page(width:200pt, height: 200pt, fill: none, margin: 2pt)
#cetz.canvas({
        import cetz.draw: *
        set-style(text: (size:10pt))
        let lines((x, y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "9": line(p0, p1, p2, fill: red.transparentize(75%), name:"9"), 
                "4": line(p0, p1, name:"4"), 
                "5": line(p1, p2, name:"5"), 
                "6": line(p2, p3, name:"6"), 
                "7": line(p3, p0, name:"7"), 
                "8": line(p0, p2, name:"8"), 
            )
        }

        let pts((x,y)) = {
            let p0 = (1+x, 0+y)
            let p1 = (0+x, 1+y)
            let p2 = (-1+x, 0+y)
            let p3 = (0+x, -1+y)
            (
                "0": (p0, "south-west"), 
                "1": (p1, "south-west"), 
                "2": (p2, "north-east"), 
                "3": (p3, "north-east")
            )
        }

        let draw_point(name, (p, anchor), drawtext:true) = {
            circle(p, radius: (0.05), fill: black, name:name)
            if drawtext {
                if anchor == "north-east"{
                    content(name, anchor:anchor, pad(right: .7em, text($p_name$)))
                } else {
                    content(name, anchor:anchor, pad(left: .7em, text($p_name$)))
                }

            }
        }

        let draw_line(id, l, drawtext:true) = {
            l
            if drawtext {
                if (id > 8) {
                    content(str(id), anchor: "mid", text($tau_id$))
                } else {
                    set-style(content: (frame: "circle", stroke:none, fill:white,))
                    content(str(id), anchor: "mid", text($sigma_id$))
                }
            }
        }

        group(name: "K_0", {
            let origin = (0, 0)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v))
            }
        })

        group(name: "K_1", {
            let origin = (3.5, 0)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }

            for i in range(4, 7) {
                draw_line(i, lines(origin).at(str(i)))
            }

        })

        group(name: "K_2", {
            let origin = (0, -3.5)
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }

            for i in range(4,7) {
                draw_line(i, lines(origin).at(str(i)), drawtext: false)
            }

            draw_line(7, lines(origin).at("7"))
            draw_line(8, lines(origin).at("8"))

        })

        group(name: "K_3", {
            let origin = (3.5, -3.5)

            for i in range(8, 3, step:-1) {
                draw_line(i, lines(origin).at(str(i)), drawtext: false)
            }

            draw_line(9, lines(origin).at("9"))
            
            for i in range(4) {
                let (p, v) = pts(origin).at(str(i))
                draw_point(str(i), (p, v), drawtext: true)
            }
        })

        for i in range(4){
            content(("K_",str(i),".south").join(""), 
                anchor:"north", 
                pad(top: 1em, text($K_#i$))
            )
        }
        

    })