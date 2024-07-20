all: interpreter

turing: turing.ml
	ocamlc -g turing.ml -o turing

lexer: lexer.ml
	ocamlc -g lexer.ml -o lexer

parser: turing.ml parser.ml lexer.ml
	ocamlc -g turing.ml lexer.ml parser.ml -o parser

compiler: turing.ml parser.ml lexer.ml compiler.ml
	ocamlc -g turing.ml lexer.ml parser.ml compiler.ml -o compiler

interpreter: turing.ml lexer.ml parser.ml compiler.ml interpreter.ml
	ocamlc -g turing.ml lexer.ml parser.ml compiler.ml interpreter.ml -o interpreter

uncompiler: turing.ml uncompiler.ml
	ocamlc -g turing.ml uncompiler.ml -o uncompiler


turing_tests: turing
	ocamlc -g turing.ml tests/turing_tests.ml -o turing_tests

lexer_tests: lexer
	ocamlc -g lexer.ml tests/lexer_tests.ml -o lexer_tests

parser_tests: lexer parser turing
	ocamlc -g lexer.ml turing.ml parser.ml tests/parser_tests.ml -o parser_tests


tests: turing_tests lexer_tests parser_tests
	./turing_tests && ./lexer_tests && ./parser_tests
	echo "Tests OK"

clean: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo *.dot *.pdf

cleanall: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo turing lexer parser interpreteur \
	compiler interpreter uncompiler lexer_tests turing_tests \
	parser_tests *.dot *.pdf