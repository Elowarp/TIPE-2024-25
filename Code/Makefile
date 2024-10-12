# Nom de l'exécutable
TARGET = main

# Compilateur
CC = gcc

# Options de compilation
CFLAGS = -Wall -Wextra -std=c11 -g -lm

# Liste des fichiers source
SRCS = $(wildcard *.c) $(wildcard src/*.c)

# Liste des fichiers objets
OBJS = $(SRCS:.c=.o)

# Règle par défaut
all: $(TARGET)

# Règle pour créer l'exécutable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Règle pour créer les fichiers objets
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nom de l'exécutable de test
TEST_TARGET = testsAll

# Liste des fichiers source de test
TEST_SRCS = $(wildcard tests/*.c)

# Liste des fichiers objets de test
TEST_OBJS = $(TEST_SRCS:.c=.o)

# Liste des fichiers objets sans le fichier contenant le main
MAIN_OBJ = main.o
OBJS_NO_MAIN = $(filter-out $(MAIN_OBJ), $(OBJS))


# Règle pour créer l'exécutable de test
$(TEST_TARGET): $(TEST_OBJS) $(OBJS_NO_MAIN)
	$(CC) $(CFLAGS) -o $@ $^

# Règle pour créer les fichiers objets de test
tests/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Règle pour exécuter les tests
tests: $(TEST_TARGET)
	./$(TEST_TARGET)

# Règle pour nettoyer les fichiers générés
clean:
	rm -f $(OBJS) $(TARGET) $(TEST_OBJS) $(TEST_TARGET)

# Règle pour nettoyer tout, y compris les fichiers de sauvegarde
distclean: clean
	rm -f *~

# Indique que les règles suivantes ne sont pas des fichiers
.PHONY: all clean distclean