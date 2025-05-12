/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 12-05-2025 09:35:05
 *  Last modified : 12-05-2025 09:40:08
 *  File : notationSimplexe.typ
 */
#import "@preview/cetz:0.3.4"
#set align(center)
#set page(width:90pt, height: 90pt, fill: none, margin: 2pt)
        #cetz.canvas({
            import cetz.draw: *
            scale(1)
            set-style(text: (size:10pt))
            let lines((x, y)) = {
                let p0 = (1+x, 0+y)
                let p1 = (0+x, 1+y)
                let p2 = (-1+x, 0+y)
                let p3 = (0+x, -1+y)
                (
                    "10": line(p0, p2, p3, fill: red.transparentize(75%), name:"10"),
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
                        content(name, anchor:anchor, pad(right: .2em, text($p_name$)))
                    } else {
                        content(name, anchor:anchor, pad(left: .3em, text($p_name$)))
                    }

                }
            }

            let draw_txt(id, dx, dy) = {
                content(str(id), anchor: "mid", 
                    [#move(dx:dx, dy:dy, text($sigma_id$))]
                )
            }
            let draw_line(id, l, drawtext:true) = {
                l
                if drawtext {
                    if (id > 8) {
                        content(str(id), anchor: "mid", text($tau_id$))
                    } else {
                        if id == 4 {
                            draw_txt(id, 6pt, -5pt)
                        } else if id == 5 {
                            draw_txt(id, -6pt, -6pt)
                        } else if id == 6 {
                            draw_txt(id, -6pt, 4pt)
                        } else if id == 7 {
                            draw_txt(id, 6pt, 4pt)
                        } else {
                            draw_txt(id, 0pt, 3pt)
                        }
                    }
                }
            }

            group(name: "K_3", {
                let origin = (0, 0)

                for i in range(10, 3, step:-1) {
                    draw_line(i, lines(origin).at(str(i)))
                }

                for i in range(4) {
                    let (p, v) = pts(origin).at(str(i))
                    draw_point(str(i), (p, v))
                }
            })
        })