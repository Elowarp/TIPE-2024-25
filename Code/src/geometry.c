/*
 *  Contact : Elowan - elowarp@gmail.com
 *  Creation : 14-09-2024 13:55:46
 *  Last modified : 24-11-2024 23:30:37
 *  File : geometry.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

#include "geometry.h"
#include "misc.h"

const int DIM = 2;

// Renvoie la distance euclidienne entre deux points
float dist_euclidean(int p1, int p2, PointCloud *X){
    return sqrt(pow(X->pts[p2].x - X->pts[p1].x, 2) + 
            pow(X->pts[p2].y - X->pts[p1].y, 2));
}

// Renvoie la distance entre deux points
// Cette fonction sert d'interface pour que l'on puisse facilement
// la modifier lors de l'application de notre programme à un sujet
float dist(int p1, int p2, PointCloud *X){
    // return dist_euclidean(p1, p2, X);

    return X->dist[p1][p2];
}

///////////////////////
//      POINTS       //
///////////////////////

// Affiche un point
void pointPrint(Point p){
    printf("(%f, %f)", p.x, p.y);
}

// Initialise un nuage de points
PointCloud *pointCloudInit(int size){
    PointCloud *pointCloud = malloc(sizeof(PointCloud));
    pointCloud->pts = malloc(size * sizeof(Point));
    pointCloud->weights = malloc(size * sizeof(float));
    pointCloud->dist = malloc(size * sizeof(float*));
    for(int i=0; i<size; i++) pointCloud->dist[i] = calloc(size, sizeof(float));
    pointCloud->size = size;
    return pointCloud;
};

// Teste si deux points sont égaux
bool pointAreEqual(Point p1, Point p2){
    return p1.x == p2.x && p1.y == p2.y;
};

// Libère un nuage de points
void pointCloudFree(PointCloud *pointCloud){
    free(pointCloud->pts);
    free(pointCloud->weights);
    free(pointCloud);
};

PointCloud *pointCloudLoad(char *filename, char *dist_filename){
    FILE *file = fopen(filename, "r");
    if(file == NULL){
        print_err("Erreur: fichier points introuvable\n");
        exit(1);
    }

    int size;
    fscanf(file, "%d", &size);
    PointCloud *pointCloud = pointCloudInit(size);

    for(int i = 0; i < size; i++){
        float weigth;
        fscanf(file, "%f %f %f %*[^\n]", &(pointCloud->pts[i].x), 
            &(pointCloud->pts[i].y), &weigth);
        pointCloud->weights[i] = weigth;

    }
    fclose(file);

    // Si un fichier distance a été fourni
    if (dist_filename != NULL){
        FILE *dist_file = fopen(dist_filename, "r");
        if(file == NULL){
            print_err("Erreur: fichier distances introuvable\n");
        }

        fscanf(dist_file, "%d", &size);
        int poubelle;
        for(int i = 0; i<size; i++){
            for(int j=i+1; j<size; j++){
                float weigth;
                fscanf(dist_file, "%d %d %f", &poubelle, &poubelle, &weigth);
                pointCloud->dist[i][j] = weigth;
            }
        }

        for(int i=0; i<size;i++)
            for(int j=0; j<i+1; j++)
                pointCloud->dist[i][j] = pointCloud->dist[j][i];

    } else { // Sinon on utilise les distances euclidiennes
        printf("Remplissage par des distances euclidiennes\n");
        for(int i = 0; i<size; i++){
            for(int j=0; j<size; j++){
                pointCloud->dist[i][j] = dist_euclidean(i, j, pointCloud);
            }
        }
    }

    return pointCloud;
};

void pointCloudPrint(PointCloud *X){
    for(int i=0; i<X->size; i++){
        printf("Point %d : ", i);
        pointPrint(X->pts[i]);
        printf(" de poids %.2f\n", X->weights[i]);
    }
    printf("Distances :\n");
    for(int i=0; i<X->size; i++){
        for(int j=i+1; j<X->size; j++) 
            printf("%d -- %.3f --> %d\n", i, dist(i, j, X), j);
    }
}

///////////////////////
//     Simplex      //
///////////////////////

int compare(const void *a, const void *b){
    return *(int *)a - *(int *)b;
}

// Initialise un simplexe
Simplex *simplexInit(int i, int j, int k){
    Simplex *s = malloc(sizeof(Simplex));
    // Respect de l'ordre lexicographique
    int tab[3] = {i, j, k};
    qsort(tab, 3, sizeof(int), compare);

    s->i = tab[0];
    s->j = tab[1];
    s->k = tab[2];
    return s;
}

// Renvoie l'identifiant associé à un simplexe
int simplexId(Simplex *s, int n){
    return (s->i+1) + (n+1) * (s->j+1) + (n+1) * (n+1) * (s->k+1);
}

// Renvoie le simplexe associé à un identifiant
Simplex simplexFromId(int id, int n){
    Simplex s;
    s.i = (id % (n+1)) - 1;
    s.j = ((id / (n+1)) % (n+1)) - 1;
    s.k = (id / ((n+1)*(n+1))) - 1;
    return s;
}

// Libère un simplexe
void simplexFree(Simplex *s){
    free(s);
}

// Renvoie le maximum de simplex possible pour un nuage de points de taille n
unsigned long long simplexMax(int n){
    return (n+1)*(n+1)*(n+1);
}

// Affiche un simplexe
void simplexPrint(Simplex *s){
    printf("{%d, %d, %d}", s->i, s->j, s->k);
}

// Renvoie la dimension d'un simplexe
int dimSimplex(Simplex *s){
    if (s->i != -1){
        return 2;
    } else if (s->j != -1){
        return 1;
    } else {
        return 0;
    }
}

// Renvoie vrai si s1 est une face de s2, false sinon
bool isFaceOf(Simplex *s1, Simplex *s2){
    // Si les dimensions ne sont pas cohérentes
    if (dimSimplex(s1) != dimSimplex(s2) - 1){
        return false;
    }

    // Si s1 est un point
    if (s1->i == -1 && s1->j == -1){
        if (s1->k == s2->i || s1->k == s2->j || s1->k == s2->k){
            return true;
        }
    }

    // Si s1 est une arête
    if (s1->j != -1){
        if (s1->j == s2->i && s1->k == s2->j){
            return true;
        } else if (s1->j == s2->i && s1->k == s2->k){
            return true;
        } else if (s1->j == s2->j && s1->k == s2->k){
            return true;
        } else {
            return false;
        }
    }

    // Sinon on est dans un cas impossible
    return false;    
}

///////////////////////
// Simplical Complex //
///////////////////////

// Initialise un complexe simplicial
SimComplex *simComplexInit(unsigned long long n){
    SimComplex *cmpx = malloc(sizeof(SimComplex));
    cmpx->simplices = malloc(n * sizeof(bool));
    for(unsigned long long i = 0; i<n; i++){
        cmpx->simplices[i] = false;
    }
    cmpx->size = 0;
    return cmpx;
}

// Libère un complexe simplicial
void simComplexFree(SimComplex *cmpx){
    free(cmpx->simplices);
    free(cmpx);
}

// Teste si un simplex est dans un complexe simplicial
bool simComplexContains(SimComplex *cmpx, Simplex *s, int n){
    return cmpx->simplices[simplexId(s, n)];
}

// Insère un simplex dans un complexe simplicial
void simComplexInsert(SimComplex *cmpx, Simplex *s, int n){
    cmpx->simplices[simplexId(s, n)] = true;
    cmpx->size++;
}

///////////////////////
//     Filtration    //
///////////////////////

// Initialise une filtration
Filtration *filtrationInit(unsigned long long size){
    Filtration *filt = malloc(sizeof(Filtration));
    filt->filt = malloc(size * sizeof(int));
    filt->nums = malloc(size * sizeof(unsigned long long));
    for(unsigned long long i = 0; i<size; i++){
        filt->filt[i] = -1;
        filt->nums[i] = -1;
    }
    filt->max_name = 0;
    filt->size = size;
    return filt;
}

// Libère une filtration
void filtrationFree(Filtration *filtration){
    free(filtration->nums);
    free(filtration->filt);
    free(filtration);
}

// Ajoute un simplexe à une filtration
void filtrationInsert(Filtration *filtration, Simplex *s, int n, int k, 
  unsigned long long num){
    int id = simplexId(s, n);
    filtration->filt[id] = k;
    filtration->nums[id] = num;

    // Mise à jour du nom maximal
    if (num+1 > filtration->max_name) filtration->max_name = num+1;
}

// Teste si un simplexe est dans une filtration
bool filtrationContains(Filtration *filtration, Simplex *s, int n){
    return filtration->filt[simplexId(s, n)]!=-1;
}

// Affiche une filtration, l'option sorted trie selon les noms de simplexes,
// n'a de sens et ne fonctionne que lorsque la fonction de nommage est injective
void filtrationPrint(Filtration *filt, int n, bool sorted){
    int *sortByName = calloc(simplexMax(n), sizeof(int));
    if (sorted){
        for(int i=0; i<filt->size; i++){
            if (filt->filt[i] != -1){
                sortByName[filt->nums[i]] = i;
            }
        }
    } else {
        for(int i=0; i<filt->size; i++)
            sortByName[i] = i;
    }
    
    for(int r = 0; r<filt->size; r++){
        if (filt->filt[sortByName[r]] != -1){
            Simplex s = simplexFromId(sortByName[r], n);
            printf("Simplex %lld (dans K_%d): ", filt->nums[sortByName[r]], 
                filt->filt[sortByName[r]]);
            simplexPrint(&s);
            printf("\n");
        }
    }

    printf("Nom max : %lld\n", filt->max_name);
}

// Renvoie le tableau des identifiants des simplexes dans la filtration
int *reverseIdAndSimplex(Filtration *filt){
    int *reversed = malloc(filt->max_name*sizeof(int));
    for(int i=0; i<filt->size; i++){
        if(filt->filt[i] != -1)
            reversed[filt->nums[i]] = i; 
        
    }

    return reversed;
}

// Renvoie le plus grand nom de simplexe + 1 dans une filtration
unsigned long long filtrationMaxName(Filtration *filt){
    unsigned long long max = 0;
    for(int i=0; i<filt->size; i++){
        if (filt->nums[i] > max){
            max = filt->nums[i];
        }
    }
    return max+1;
}

// Ecrit une filtration dans un fichier
void filtrationToFile(Filtration *filtration, Point* pts, int n, char *filename){
    FILE *f = fopen(filename, "w");
    if (f == NULL) {
        printf("Impossible d'ouvrir le fichier !\n");
        exit(1);
    }

    // Ecriture des points dans le fichier
    for(int i=0;i<n;i++){
        fprintf(f, "v %d %f %f\n", i, pts[i].x, pts[i].y);
    }

    // Ecriture des faces dans le fichier
    for(int i=0;i<filtration->size;i++){
        if(filtration->filt[i] != -1){
            Simplex s = simplexFromId(i, n);
            fprintf(f, "t %d %d %d %lld\n", s.i, s.j, s.k, filtration->nums[i]);
        }
    }

    fclose(f);

}