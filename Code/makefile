all: parser

turing: turing.ml
	ocamlc -g turing.ml -o turing

lexer: lexer.ml
	ocamlc -g lexer.ml -o lexer

parser: turing.ml parser.ml lexer.ml
	ocamlc -g turing.ml lexer.ml parser.ml -o parser

compiler: turing.ml parser.ml lexer.ml compiler.ml
	ocamlc -g turing.ml lexer.ml parser.ml compiler.ml -o compiler

clean: 
	rm -r *.cmi *.cmo turing lexer parser