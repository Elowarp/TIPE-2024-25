/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:33:19
 *  Last modified : 10-10-2024 22:31:51
 *  File : persDiag.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "persDiag.h"
#include "misc.h"

// Renvoie le maximum de simplex possible pour un nuage de points de taille n
int maxSimplex(int n){
    return (n+1)*(n+1)*(n+1);
}

// Ajoute un simplexe à un complexe simplicial en incrémentant le compteur
// si le simplexe n'est pas déjà présent
void addSimplex(SimComplex *K, Simplex *s, int n, int *count){
    if (!simComplexContains(K, s, n)){
        simComplexInsert(K, s, n);
        (*count)++;
    }
}

// Renvoie le VR complexe simplical associé à un nuage de points et un rayon R
SimComplex *VRSimplex(PointCloud X, float R){
    int n = X.size;
    SimComplex *K = simComplexInit(maxSimplex(n));
    
    int count = 0;
    for(int i = 0; i<n; i++){
        for(int j = i+1; j<n; j++){
            if (dist(X.pts[i], X.pts[j]) <= R){
                // Ajoute le simplexe {i} et {j} s'ils ne sont pas déjà présent
                Simplex *s_i = simplexInit(-1, -1, i);
                Simplex *s_j = simplexInit(-1, -1, j);
                addSimplex(K, s_i, n, &count);
                addSimplex(K, s_j, n, &count);

                // Ajoute le simplexe {i, j} à cmpx s'il n'est pas déjà présent
                Simplex *s_ij = simplexInit(-1, i, j);
                addSimplex(K, s_ij, n, &count);

                // S'il existe déjà deux autres simplexes {i, k} et {j, k}
                // alors on ajoute le simplexe {i, j, k} à cmpx
                for(int k = 0; k<n; k++){
                    // Evite le cas où on considère les mêmes arêtes
                    if (k == i || k == j){
                        continue;
                    }

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
                simplexFree(s_i);
                simplexFree(s_j);
            }
        }
    }

    K->size = count;

    return K;
}

// Renvoie une filtration associée à un nuage de points via la VR complexe 
// simplicial
Filtration *buildFiltration(PointCloud X){
    int n = X.size;
    int max_simplex = maxSimplex(n); // Nombre maximal de simplexes possible
    float eps = 0.5; // Epsilon pour la filtration
    float dist_max = 32; // Distance maximale entre deux points

    // Initialisation de la filtration
    Filtration *filt = filtrationInit(max_simplex);

    int nb_simplex = 0;
    int nb_complex = 1; // 0 est le complexe vide
    float r = 0.0; // Rayon de la boule
    int last_size = 0; // Taille du dernier complexe simplical
    while(r < dist_max){
        SimComplex *K = VRSimplex(X, r);
        
        // Si le complexe n'est pas vide et n'est pas égal au précédent
        if (K->size != 0 && K->size != last_size){
            last_size = K->size;
            
            for(int s = 0; s<max_simplex; s++){
                // Si le simplexe est présent dans le complexe
                if (K->simplices[s]){
                    // Récupère le simplexe associé à l'identifiant
                    Simplex simp = simplexFromId(s, n);

                    // Si le simplexe n'a jamais été rencontré
                    if (!filtrationContains(filt, &simp, n)){
                        filtrationInsert(filt, &simp, n, nb_complex, nb_simplex);
                        nb_simplex++;
                    }
                }
            }
            
            nb_complex++;
        }
        
        simComplexFree(K);
        r = r + eps;
    }

    return filt;
}

// Renvoie la dimension d'un simplexe
int dimSimplex(Simplex *s){
    if (s->i != -1){
        return 3;
    } else if (s->j != -1){
        return 2;
    } else {
        return 1;
    }
}

// Renvoie 1 si s1 est une face de s2, 0 sinon
int isFaceOf(Simplex *s1, Simplex *s2){
    // Si les dimensions ne sont pas cohérentes
    if (dimSimplex(s1) != dimSimplex(s2) - 1){
        return 0;
    }

    // Si s1 est un point
    if (s1->i == -1 && s1->j == -1){
        if (s1->k == s2->i || s1->k == s2->j || s1->k == s2->k){
            return 1;
        }
    }

    // Si s1 est une arête
    if (s1->j != -1){
        if (s1->j == s2->i && s1->k == s2->j){
            return 1;
        } else if (s1->j == s2->i && s1->k == s2->k){
            return 1;
        } else if (s1->j == s2->j && s1->k == s2->k){
            return 1;
        } else {
            return 0;
        }
    }

    // Sinon on est dans un cas impossible
    return 0;    
}

// Renvoie la matrice low associée à une matrice de bordure
int *buildLowMatrix(int **boundary, int n){
    int *low = malloc(n*sizeof(int));
    for(int j=0; j<n; j++){
        low[j] = -1;
        for(int i=0; i<n; i++)
            if(boundary[i][j] != 0) low[j] = i;
    }
    return low;
}

// Copie une matrice
int **copy_matrix(int **t, int n){
    int **copy = malloc(n * sizeof(int*));
    for(int i = 0; i<n; i++){
        copy[i] = malloc(n * sizeof(int));
        for(int j = 0; j<n; j++){
            copy[i][j] = t[i][j];
        }
    }
    return copy;
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
int **reduceMatrix(int **boundary, int n, int *low){
    int **reduced = copy_matrix(boundary, n);
    for(int i=0; i<n; i++){
        int j = sameLow(low, i);
        while(j != -1){
            // Soustraction de la colonne j à la colonne i
            for(int k=0; k<n; k++){
                reduced[k][i] = (reduced[k][i] + reduced[k][j]) % 2;
            }
            
            updateLow(reduced, low, i, n);
            j = sameLow(low, i);
        }
    }
    return reduced;
}

// Construit la matrice de bordure associée à une filtration
int **buildBoundaryMatrix(int *reversed, int n, int nb_pts){
    int **boundary = malloc(n * sizeof(int*));
    
    for(int i = 0; i<n; i++){
        boundary[i] = malloc(n * sizeof(int));
        
        for(int j = 0; j<n; j++){
            Simplex s1 = simplexFromId(reversed[i], nb_pts);
            Simplex s2 = simplexFromId(reversed[j], nb_pts);
            boundary[i][j] = isFaceOf(&s1, &s2);
        }
    }

    return boundary;
}

void printMatrix(int **matrix, int n, int m){
    for(int i = 0; i<n; i++){
        for(int j = 0; j<m; j++){
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

// Renvoie des paires à partir d'une matrice de reduction, size_pairs est
// la taille du tableau de paires créé
Tuple *extractPairs(int *low, int n, int *size_pairs){
    Tuple *pairs = malloc(n * sizeof(Tuple));
    *size_pairs = 0;

    bool seen[n];
    for(int i=0; i<n; i++) seen[i] = false;

    for(int j = n-1; j>=0; j--){
        if (!seen[j]){
            if (low[j] != -1){
                // On a trouvé une paire
                pairs[*size_pairs].x = low[j];
                pairs[*size_pairs].y = j;
                (*size_pairs)++;
                seen[low[j]] = true;
                seen[j] = true;
            } else {
                // On a trouvé un cycle encore en vie
                pairs[*size_pairs].x = j;
                pairs[*size_pairs].y = -1;
                (*size_pairs)++;
            }
        }
    }
    pairs = realloc(pairs, *size_pairs * sizeof(Tuple));
    return pairs;
}

// Renvoie le numéro de complexe simplical associé à un simplexe depuis la 
// filtration injective dans la filtration de base
int complexFromInjective(Filtration *base_filt, int *reversed, int i){
    return base_filt->nums[reversed[i]];
}

// Associe les identifiants des simplexes à leurs paires
Tuple *extractPairsBeforeInjective(int *low, int n, int *size_pairs, 
    Filtration *base_filt, int *injective_reversed){
    
    Tuple *pairs = malloc(n * sizeof(Tuple));
    *size_pairs = 0;

    bool seen[n];
    for(int i=0; i<n; i++) seen[i] = false;

    for(int j = n-1; j>=0; j--){
        if (!seen[j]){
            int complex_j = complexFromInjective(base_filt, injective_reversed, j);
            if (low[j] != -1){
                int complex_low_j = complexFromInjective(base_filt, injective_reversed, low[j]);
                
                if (complex_j != complex_low_j){
                    // On a trouvé une paire
                    pairs[*size_pairs].x = complex_low_j;
                    pairs[*size_pairs].y = complex_j;
                    (*size_pairs)++;
                }
                seen[low[j]] = true;
                seen[j] = true;
            } else {
                // On a trouvé un cycle encore en vie
                pairs[*size_pairs].x = complex_j;
                pairs[*size_pairs].y = -1;
                (*size_pairs)++;
            }
        }
    }
    pairs = realloc(pairs, *size_pairs * sizeof(Tuple));
    return pairs;
}

// Renvoie le plus grand nom de simplexe dans une filtration
int maxNameFiltration(Filtration *filt){
    int max = 0;
    for(int i=0; i<filt->size; i++){
        if (filt->nums[i] > max){
            max = filt->nums[i];
        }
    }
    return max;
}

// Renvoie le tableau des identifiants des simplexes dans la filtration
int *reverseIdAndSimplex(Filtration *filt, int max_nums){
    int *reversed = malloc((max_nums+1)*sizeof(int));
    for(int i=0; i<filt->size; i++){
        if(filt->filt[i] != -1)
            reversed[filt->nums[i]] = i; 
        
    }

    return reversed;
}

// Crée un diagramme de persistance à partir d'une filtration injective
PersistenceDiagram *PDCreate(Filtration *filtration, PointCloud *X){
    PersistenceDiagram *pd = malloc(sizeof(PersistenceDiagram));
    pd->size_pts = X->size;
    pd->pts = malloc(X->size * sizeof(Point));
    for(int i=0; i<X->size; i++) pd->pts[i] = (Point) {X->pts[i].x, X->pts[i].y};
    
    // Récupère le plus grand nom de simplexe dans la filtration
    int max_name = maxNameFiltration(filtration);
    
    // Matrice tq reversed[i] = j si le simplexe j est le i-ème simplexe de la filtration
    // Cohérent dans l'hypothèse de filtration injective
    int *reversed = reverseIdAndSimplex(filtration, max_name);

    // Matrice de bordure associée à la filtration
    int **boundary = buildBoundaryMatrix(reversed, max_name, X->size);
    
    // Matrice low associée à la matrice de bordure
    int *low = buildLowMatrix(boundary, max_name);

    // Réduction de la matrice de bordure
    int **reduced = reduceMatrix(boundary, max_name, low);

    // Extraction des paires
    Tuple *pairs = extractPairs(low, max_name, &pd->size_pairs);
    pd->pairs = pairs;

    // Libération de la mémoire
    free(reversed);
    for(int i=0; i<max_name; i++) free(boundary[i]);
    free(boundary);
    free(low);
    for(int i=0; i<max_name; i++) free(reduced[i]);
    free(reduced);

    return pd;
}

// Exporte un diagramme de persistance dans un fichier
void PDExport(PersistenceDiagram *pd, char *filename){
    FILE *f = fopen(filename, "w");
    if (f == NULL){
        print_err("Erreur lors de l'ouverture du fichier");
    }

    // Ecriture des points
    for(int i=0; i<pd->size_pts; i++){
        fprintf(f, "v %f %f\n", pd->pts[i].x, pd->pts[i].y);
    }

    // Ecriture des paires
    for(int i=0; i<pd->size_pairs; i++){
        fprintf(f, "p %d %d\n", pd->pairs[i].x, pd->pairs[i].y);
    }

    fclose(f);
}

// Libère la mémoire allouée pour un diagramme de persistance
void PDFree(PersistenceDiagram *pd){
    free(pd->pts);
    free(pd->pairs);
    free(pd);
}