/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:33:19
 *  Last modified : 12-10-2024 22:06:31
 *  File : persDiag.c
 */
#include <stdio.h>
#include <stdlib.h>

#include "persDiag.h"
#include "misc.h"

////////////////////////////
//    Filtrations & VR    //
////////////////////////////

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
            if (isFaceOf(&s1, &s2)) boundary[i][j] = 1;
            else boundary[i][j] = 0;
        }
    }

    return boundary;
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

////////////////////////////
//  Persistance Diagram   //
////////////////////////////

// Crée un diagramme de persistance à partir d'une filtration injective
PersistenceDiagram *PDCreate(Filtration *filtration, PointCloud *X){
    PersistenceDiagram *pd = malloc(sizeof(PersistenceDiagram));
    
    // Récupère le plus grand nom de simplexe dans la filtration
    int max_name = filtrationMaxName(filtration);
    
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

    // Récupération des classes d'homologie
    pd->dims = malloc(pd->size_pairs * sizeof(int));
    for(int i=0; i<pd->size_pairs; i++){
        Simplex s = simplexFromId(reversed[pd->pairs[i].x], X->size);
        pd->dims[i] = dimSimplex(&s);
    }

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

    // Ecriture des paires
    for(int i=0; i<pd->size_pairs; i++){
        if (pd->pairs[i].y == -1){
            fprintf(f, "%d %d inf\n", pd->dims[i], pd->pairs[i].x);
        } else {
            fprintf(f, "%d %d %d\n",pd->dims[i], pd->pairs[i].x, pd->pairs[i].y);
        }
    }

    fclose(f);
}

// Libère la mémoire allouée pour un diagramme de persistance
void PDFree(PersistenceDiagram *pd){
    free(pd->dims);
    free(pd->pairs);
    free(pd);
}