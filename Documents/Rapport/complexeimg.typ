/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 12-05-2025 08:47:14
 *  Last modified : 12-05-2025 08:49:24
 *  File : complexeimg.typ
 */
#import "@preview/cetz:0.3.4"
#set page(width:125pt, height: 100pt, fill: none)
#cetz.canvas({
        import cetz.draw: *
        scale(2)
        let p1 = (-1, 0, 0)
        let p2 = (0.75, 0, 0)
        let p3 = (0.25, 0, 1)
        let t = (0, 1, 0)
        let trièdre = {
            line(p1, t, p2, p1, name:"face1")
            line(p1, t, p3, p1, name:"face2", fill: red.transparentize(75%))
            line(p1, t, stroke: 3pt)
            line(p2, t, p3, p2, name:"face3", )
        }
        trièdre
    })