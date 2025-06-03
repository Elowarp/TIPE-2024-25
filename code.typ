#set heading(numbering: "I.1.1 -")
#set document(
  title: "TIPE : Persistance homologique (Code)"
)
#set page("presentation-4-3", columns: 2, margin: 25pt, footer: context [
        #set align(center)
        #counter(page).display(
            "1 sur 1",
            both: true
        )
    ])
#set text(size:13pt)

#let files = (
    "src": ("geometry.c", "geometry.h", "list.c", "list.h", "misc.c", "misc.h", "persDiag.c", "persDiag.h", "reduc.c", "reduc.h"),
    "prgms": ("analyse_cplx.c", ),
    "tests": ("tests_geometry.c", "tests_list.c", "tests_persDiag.c", "tests_reduc.c"),
    "": ("main.c", "retrieve_data.py")
  )

#show raw.line: it => {
  text(fill: gray)[#it.number]
  h(1em)
  it.body
}

#show heading: it => {
  set text(25pt)
  pagebreak(weak: true)
  it
}

#for (dir, names) in files {
    for name in names{
      [= #dir/#name]
      let txt = read("Code/"+dir+"/"+name)
      let (_, ext) = name.split(".")
      let lang = (
        if ext == "c" or ext == "h" {
          "C"
        } else if ext == "py" {
          "python"
        }
      )

      raw(txt, lang:lang, block:true)
    }
}