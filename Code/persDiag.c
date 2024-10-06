/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 10-09-2024 16:33:19
 *  Last modified : 06-10-2024 22:55:33
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

// Renvoie le VR complexe simplical associé à un nuage de points et un rayon R
SimComplex *VRSimplex(PointCloud X, float R){
    int n = X.size;
    SimComplex *K = simComplexInit(maxSimplex(n));
    
    int count = 0;
    for(int i = 0; i<n; i++){
        for(int j = i+1; j<n; j++){
            if (dist(X.pts[i], X.pts[j]) <= R){
                Simplex *s_ij = simplexInit(-1, i, j);
                // Ajoute le simplexe {i, j} à cmpx s'il n'est pas déjà présent
                if (!simComplexContains(K, s_ij, n)){
                    simComplexInsert(K, s_ij, n);
                    count++;
                }


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
                        if (!simComplexContains(K, s_ijk, n)){
                            simComplexInsert(K, s_ijk, n);
                            count++;
                        }
                        simplexFree(s_ijk);
                    }
                    simplexFree(s_ik);
                    simplexFree(s_jk);
                }
                simplexFree(s_ij);
            }
        }
    }

    K->size = count;

    return K;
}

void FindPersistentHomology(PointCloud X){
    int n = X.size;
    int max_simplex = maxSimplex(n); // Nombre maximal de simplexes possible (a changer)
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
            printf("K_%d : %d\n", nb_complex, K->size);
            
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
    
    // Affiche chaque complexe avec son id dans la filtration
    filtrationPrint(filt, n);

    // Libération de la mémoire
    filtrationFree(filt);
}

int main(){
    PointCloud *X = pointCloudLoad("data/example.dat");
    printf("Nuage de points : \n");
    for(int i = 0; i<X->size; i++){
        pointPrint(X->pts[i]);
        printf("\n");
    }
    FindPersistentHomology(*X);
    pointCloudFree(X);
    return 0;
}