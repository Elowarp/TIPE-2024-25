all: tests

dlist: dlist.ml
	ocamlc -g dlist.ml -o dlist

automaton: automaton.ml
	ocamlc -g automaton.ml -o automaton

turing: turing.ml automaton.ml
	ocamlc -g automaton.ml turing.ml -o turing

minimisation: minimisation.ml dlist.ml
	ocamlc -g automaton.ml dlist.ml minimisation.ml -o minimisation

turing_tests: turing.ml automaton.ml tests/turing_tests.ml
	ocamlc -g automaton.ml turing.ml tests/turing_tests.ml -o turing_tests

minimisation_tests: minimisation.ml dlist.ml tests/minimisation_tests.ml
	ocamlc -g automaton.ml dlist.ml minimisation.ml tests/minimisation_tests.ml -o minimisation_tests


tests: turing_tests minimisation_tests
	./turing_tests && ./minimisation_tests
	echo "Tests OK"

clean: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo *.dot *.pdf

cleanall: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo turing turing_tests \
	minimisation_tests minimisation dlist automaton *.dot *.pdf