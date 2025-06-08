/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 08-06-2025 10:48:19
 *  Last modified : 08-06-2025 10:50:27
 *  File : filtrationVR.typ
 */


#import "@preview/cetz:0.3.4"
#set align(center)
#set page(width: 180pt, height: 140pt, fill: none, margin: 2pt)

    #cetz.canvas({
        import cetz.draw: *
        let pts = {
            let p0 = (0, 4)
            let p1 = (0, 5)
            let p2 = (0.5, 4.5)
            let p3 = (1, 4.5)
            let p4 = (2, 3)
            let p5 = (2, 2)
            let p6 = (2, 6)
            let p7 = (2, 6.5)
            let p8 = (3, 5.5)
            let p9 = (4, 2)
            let p10 = (4, 3)
            let p11 = (5.5, 2.5)
            let p12 = (4, 4.5)
            (p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
        }

        line(pts.at(0), pts.at(1), pts.at(3), pts.at(0), fill: blue.transparentize(50%))

        line(pts.at(11), pts.at(10), pts.at(9), pts.at(11), fill: red.transparentize(75%))
        line(pts.at(11), pts.at(10), pts.at(12), pts.at(11), fill: red.transparentize(75%))
        line(pts.at(6), pts.at(7), pts.at(8), pts.at(6), fill: red.transparentize(75%))


        line(pts.at(3), pts.at(6))
        line(pts.at(0), pts.at(2))
        line(pts.at(1), pts.at(2))
        line(pts.at(3), pts.at(2))
        line(pts.at(3), pts.at(4))
        line(pts.at(4), pts.at(5))
        line(pts.at(4), pts.at(10))
        line(pts.at(5), pts.at(9))
        line(pts.at(10), pts.at(9))
        line(pts.at(10), pts.at(11))
        line(pts.at(9), pts.at(11))
        line(pts.at(12), pts.at(11))
        line(pts.at(12), pts.at(10))
        line(pts.at(12), pts.at(8))
        line(pts.at(7), pts.at(8))
        line(pts.at(7), pts.at(6))
        line(pts.at(8), pts.at(6))
        

        let draw_point(p) = {
            circle(p, radius: (0.05), fill: black)
        }
       
        for i in range(13) {
            let p = pts.at(i)
            draw_point(p)
        }

        // lines.at(0)
        
    })