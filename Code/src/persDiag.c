/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:33:19
 *  Last modified : 21-12-2024 16:19:50
 *  File : persDiag.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "persDiag.h"
#include "misc.h"

////////////////////////////
//    Filtrations & VR    //
////////////////////////////

// Ajoute un simplexe à un complexe simplicial en incrémentant le compteur
// si le simplexe n'est pas déjà présent
void addSimplex(SimComplex *K, Simplex *s, int n, int *count){
    if (!simComplexContains(K, s, n)){
        simComplexInsert(K, s, n);
        (*count)++;
    }
}

// Renvoie le VR complexe simplical associé à un nuage de points et un temps t
SimComplex *VRSimplex(PointCloud *X, float t){
    int n = X->size;
    SimComplex *K = simComplexInit(simplexMax(n));
    
    int count = 0;
    for(int i = 0; i<n; i++){
        // Condition pour considérer un point d'un VR weighted
        if (X->weights[i] < t){ 
            // Ajoute le simplexe {i}
            Simplex *s_i = simplexInit(-1, -1, i);
            addSimplex(K, s_i, n, &count);

            for(int j = i+1; j<n; j++){
                // Même condition
                if (X->weights[j]<t){
                    // Ajoute le simplexe {j} s'il est pas déjà présent
                    Simplex *s_j = simplexInit(-1, -1, j);
                    addSimplex(K, s_j, n, &count);

                    // Ajout des simplexes de dimensions > 0
                    if (dist(i, j, X) + X->weights[i] + X->weights[j] < 2*t){
                        // Ajoute le simplexe {i, j} à cmpx s'il n'est pas déjà présent
                        Simplex *s_ij = simplexInit(-1, i, j);
                        addSimplex(K, s_ij, n, &count);

                        // S'il existe déjà deux autres simplexes {i, k} et {j, k}
                        // alors on ajoute le simplexe {i, j, k} à cmpx
                        for(int k = 0; k<n; k++){
                            // Evite le cas où on considère les mêmes arêtes
                            if (k == i || k == j) continue;
                            
                            Simplex *s_ik = simplexInit(-1, i, k);
                            Simplex *s_jk = simplexInit(-1, j, k);
                            if (simComplexContains(K, s_ik, n) && simComplexContains(K, s_jk, n)){
                                Simplex *s_ijk = simplexInit(i, j, k);
                                addSimplex(K, s_ijk, n, &count);
                                simplexFree(s_ijk);
                            }
                            simplexFree(s_ik);
                            simplexFree(s_jk);
                        }
                        simplexFree(s_ij);
                        simplexFree(s_j);
                    }
                }
            }
            simplexFree(s_i);
        }
    }

    K->size = count;

    return K;
}

// Renvoie la distance maximale à considérer lors de la création
// d'une filtration
float maxDistOfPointCloud(PointCloud *X){
    // Calcule la distance maximale 
    float max_d = 0;
    for(int i=0; i<X->size; i++){
        for(int j=i+1; j<X->size; j++){
            if (max_d < dist(i, j, X)) max_d = dist(i, j, X);
        }
    }

    // Calcule le poids maximal
    float max_w = 0;
    for(int i=0; i<X->size; i++){
        if(X->weights[i]>max_w) max_w = X->weights[i];
    }

    // Retourne la distance maximale à considérer
    return max_d + 2*max_w;
}

// Renvoie une filtration associée à un nuage de points via la VR complexe 
// simplicial
Filtration *buildFiltration(PointCloud *X){
    int n = X->size;
    unsigned long long max_simplex = simplexMax(n); // Nombre maximal de simplexes possible
    float eps = 1; // Epsilon pour la filtration ie 1seconde
    float dist_max = maxDistOfPointCloud(X); // Distance maximale à considérer
    // Initialisation de la filtration
    Filtration *filt = filtrationInit(max_simplex);

    int nb_simplex = 0;
    int nb_complex = 1; // 0 est le complexe vide
    float t = 0.0;      // Rayon des boules
    int last_size = 0;  // Taille du dernier complexe simplical
    while(t < dist_max+eps){
        SimComplex *K = VRSimplex(X, t);
        
        // Si le complexe n'est pas vide et n'est pas égal au précédent
        if (K->size != 0 && K->size != last_size){
            last_size = K->size;
            
            for(unsigned long long s = 0; s<max_simplex; s++){
                // Si le simplexe est présent dans le complexe
                if (K->simplices[s]){
                    // Récupère le simplexe associé à l'identifiant
                    Simplex simp = simplexFromId(s, n);

                    // Si le simplexe n'a jamais été rencontré
                    if (!filtrationContains(filt, &simp, n)){
                        filtrationInsert(filt, &simp, n, (int) t, nb_simplex);
                        nb_simplex++;
                    }
                }
            }
            
            nb_complex++;
        }
        
        simComplexFree(K);
        t = t + eps;
    }

    return filt;
}

// Renvoie la matrice low associée à une matrice de bordure
int *buildLowMatrix(int **boundary, unsigned long long n){
    int *low = malloc(n*sizeof(int));
    for(unsigned long long j=0; j<n; j++){
        low[j] = -1;
        for(unsigned long long i=0; i<n; i++)
            if(boundary[i][j] != 0) low[j] = i;
    }
    return low;
}

// Renvoie l'indice de la première colonne de la matrice low ayant la même valeur
int sameLow(int *low, int i){
    for(int j=i-1; j>=0; j--){
        if(low[i] == low[j] && low[i] != -1){
            return j;
        }
    }
    return -1;
}

// Met à jour la colonne j de la matrice low
void updateLow(int **boundary, int* low, int j, int n){
    low[j] = -1;
    for(int i=0; i<n; i++)
        if(boundary[i][j] != 0) low[j] = i;
}

// Standart Algorithm
int **reduceMatrix(int **boundary, unsigned long long n, int *low){
    int **reduced = copy_matrix(boundary, n);
    for(unsigned long long i=0; i<n; i++){
        int j = sameLow(low, i);
        while(j != -1){
            // Soustraction de la colonne j à la colonne i
            for(unsigned long long k=0; k<n; k++){
                reduced[k][i] = (reduced[k][i] + reduced[k][j]) % 2;
            }
            
            updateLow(reduced, low, i, n);
            j = sameLow(low, i);
        }
    }
    return reduced;
}

// Construit la matrice de bordure associée à une filtration
// reversed est le tableau des identifiants des simplexes dans la filtration 
// nb_pts est le nb de points dans l'ensemble
// max_name est le nom maximal attribué dans une filtration
int **buildBoundaryMatrix(int *reversed, unsigned long long max_name, int nb_pts){
    int **boundary = malloc(max_name * sizeof(int*));
    
    for(unsigned long long i = 0; i<max_name; i++){
        boundary[i] = malloc(max_name * sizeof(int));
        
        for(unsigned long long j = 0; j<max_name; j++){
            Simplex s1 = simplexFromId(reversed[i], nb_pts);
            Simplex s2 = simplexFromId(reversed[j], nb_pts);
            if (isFaceOf(&s1, &s2)) boundary[i][j] = 1;
            else boundary[i][j] = 0;
        }
    }

    return boundary;
}

// Renvoie une liste de paires correspondant aux idéntifiants des simplexes 
// récupérés depuis la matrice réduite
Tuple *extractPairsFilt(int *low, Filtration *filt, unsigned long long *size_pairs,
 int *reversed){
    Tuple *pairs = malloc(filt->max_name * sizeof(Tuple));
    *size_pairs = 0;
    
    bool seen[filt->max_name];
    for(unsigned long long i=0; i<filt->max_name; i++) seen[i] = false;

    unsigned long long count = 0; 
    for(unsigned long long j = filt->max_name-1; count < filt->max_name; j--){
        if (!seen[j]){ // Pas déjà appairé
            if (low[j] != -1){
                // On a trouvé une paire
                int x = filt->filt[reversed[low[j]]];
                int y = filt->filt[reversed[j]];
                if (x != y){
                    pairs[*size_pairs].x = reversed[low[j]];
                    pairs[*size_pairs].y = reversed[j];
                    (*size_pairs)++;
                }
                
                seen[low[j]] = true;
                seen[j] = true;
            } else {
                // On a trouvé un cycle encore en vie
                pairs[*size_pairs].x = reversed[j];
                pairs[*size_pairs].y = -1;
                (*size_pairs)++;
            }
        }
        count++;
    }
    
    pairs = realloc(pairs, *size_pairs * sizeof(Tuple));
    return pairs;
}

////////////////////////////
//  Persistance Diagram   //
////////////////////////////

// Crée un diagramme de persistance à partir d'une filtration injective
PersistenceDiagram *PDCreate(Filtration *filtration, PointCloud *X){
    PersistenceDiagram *pd = malloc(sizeof(PersistenceDiagram));

    // Matrice tq reversed[i] = j si le simplexe j est le i-ème simplexe de la filtration
    // Cohérent dans l'hypothèse de filtration injective
    int *reversed = reverseIdAndSimplex(filtration);

    // Matrice de bordure associée à la filtration
    int **boundary = buildBoundaryMatrix(reversed, filtration->max_name, X->size);
    
    // Matrice low associée à la matrice de bordure
    int *low = buildLowMatrix(boundary, filtration->max_name);

    // Réduction de la matrice de bordure
    int **reduced = reduceMatrix(boundary, filtration->max_name, low);
    
    // Extraction des paires
    Tuple *pairs = extractPairsFilt(low, filtration, &(pd->size_pairs),
        reversed);

    // Assignation du rang d'apparition des simplexes dans la filtration 
    // depuis la liste de paires
    pd->pairs = malloc(pd->size_pairs * sizeof(Tuple));
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        pd->pairs[i].x = filtration->filt[pairs[i].x];

        if (pairs[i].y != -1)
            pd->pairs[i].y = filtration->filt[pairs[i].y];
        else
            pd->pairs[i].y = -1;
    }

    // Récupération des dimensions des simplexes et donc catégorises les 
    // classes d'homologie
    
    printf("Affichage des simplexes tuant des 1D homologies\n");
    pd->dims = malloc(pd->size_pairs * sizeof(int));
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        Simplex s = simplexFromId(pairs[i].x, X->size);
        
        pd->dims[i] = dimSimplex(&s);
        if(dimSimplex(&s) == 1) pd->size_death1D++;
    }
    
    // Rajoute les temps de naissance des tueurs de classes 1D 
    pd->death1D = malloc(pd->size_death1D * sizeof(Simplex));
    int c = 0;
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        Simplex s = simplexFromId(pairs[i].x, X->size);
        Simplex death_s = simplexFromId(pairs[i].y, X->size);
        if(dimSimplex(&s) == 1)
        {
            pd->death1D[c] = death_s;
            c++;
        }
    }

    // Libération de la mémoire
    free(reversed);
    for(unsigned long long i=0; i<filtration->max_name; i++) free(boundary[i]);
    free(boundary);
    free(low);
    for(unsigned long long i=0; i<filtration->max_name; i++) free(reduced[i]);
    free(reduced);

    return pd;
}

// Exporte un diagramme de persistance dans un fichier
void PDExport(PersistenceDiagram *pd, char *filename, char *death_filename,
  bool bigger_dims){
    FILE *f = fopen(filename, "w");
    if (f == NULL){
        print_err("Erreur lors de l'ouverture du fichier");
    }

    // Ecriture des paires
    for(unsigned long long i=0; i<pd->size_pairs; i++){
        if (pd->dims[i] >= 2 && !bigger_dims) continue; // On veut que dims 0 et 1

        if (pd->pairs[i].y == -1){
            fprintf(f, "%d %d inf\n", pd->dims[i], pd->pairs[i].x);
        } else {
            fprintf(f, "%d %d %d\n",pd->dims[i], pd->pairs[i].x, pd->pairs[i].y);
        }
    }

    fclose(f);

    // Ecriture des simplexes tuant les classes 1D
    FILE *f_death = fopen(death_filename, "w");
    for(int i = 0; i<pd->size_death1D; i++)
        fprintf(f_death, "%d %d %d\n", pd->death1D[i].i, 
            pd->death1D[i].j, pd->death1D[i].k);
    
    fclose(f_death);
    printf("Diagram exported at %s\n", filename);
}

// Libère la mémoire allouée pour un diagramme de persistance
void PDFree(PersistenceDiagram *pd){
    free(pd->dims);
    free(pd->pairs);
    free(pd);
}