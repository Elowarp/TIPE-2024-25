all: tests

dlist: dlist.ml
	ocamlc -g dlist.ml -o dlist

partition: partition.ml dlist
	ocamlc -g dlist.ml partition.ml -o partition

automaton: automaton.ml
	ocamlc -g automaton.ml -o automaton

turing: turing.ml automaton.ml
	ocamlc -g automaton.ml turing.ml -o turing

two_color: two_color.ml turing
	ocamlc -g automaton.ml turing.ml two_color.ml -o two_color

minimisation: minimisation.ml turing automaton partition dlist partition
	ocamlc -g automaton.ml turing.ml dlist.ml partition.ml minimisation.ml -o minimisation

automaton_tests: automaton tests/automaton_tests.ml
	ocamlc -g automaton.ml tests/automaton_tests.ml -o automaton_tests

turing_tests: turing tests/turing_tests.ml
	ocamlc -g automaton.ml turing.ml tests/turing_tests.ml -o turing_tests

partition_tests: partition tests/partition_tests.ml
	ocamlc -g dlist.ml partition.ml tests/partition_tests.ml -o partition_tests

minimisation_tests: minimisation tests/minimisation_tests.ml
	ocamlc -g automaton.ml dlist.ml partition.ml turing.ml minimisation.ml tests/minimisation_tests.ml -o minimisation_tests


tests: turing_tests minimisation_tests partition_tests automaton_tests
	./partition_tests && ./automaton_tests && ./turing_tests && ./minimisation_tests
	echo "All tests are OK."

clean: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo *.dot *.pdf

cleanall: 
	rm -r *.cmi *.cmo tests/*.cmi tests/*.cmo turing turing_tests \
	minimisation_tests minimisation partition partition_tests \
	dlist automaton automaton_tests *.dot *.pdf