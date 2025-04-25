# Calcule la forme normale de smith d'une matrice à coef ds N
def taille(M, i, j): 
    m,n = len(M), len(M[0])
    return m, n

def min_coef(M, i, j): #Renvoie le plus petit coef ds la mat extraite
    m, n = taille(M, i, j)
    i0 = i
    j0 = j
    min = M[i0][j0]
    for k in range(i, m):
        for l in range(j, n):
            if (M[k][l] < min or min == 0) and M[k][l] !=0:
                min = M[k][l]
                i0, j0 = k, l

    return (i0, j0)

def addLigne(M, i, j, a):
    m, n = taille(M, i, j)
    for l in range(n):
        M[i][l] = M[i][l] + a*M[j][l]

def addCol(M, i, j, a):
    m, n = taille(M, i, j)
    for k in range(m):
        M[k][i] = M[k][i] + a*M[k][j]

def swapCol(M, i, j):
    m, n = taille(M, i, j)
    for k in range(m):
        v = M[k][i]
        M[k][i] = M[k][j]
        M[k][j] = v

def swapLigne(M, i, j):
    v = M[i]
    M[i] = M[j]
    M[j] = v

def print_mat(M, i, j):
    m, n = taille(M, i, j)
    for k in range(i, m):
        for l in range(j, n):
            print("{:3} ".format(M[k][l]), end="")
        print()

def reduc(M, i, j): #Concidère la matrice extraite (M_k,l)i<=k<=m, j<=l<=n
    m, n = taille(M, i, j)
    if i==len(M)-1 and j==len(M[0])-1:
        return
    
    print("Matrice avant l'étape 2 :")
    print_mat(M, i, j)
    print()
    
    i0, j0 = min_coef(M, i ,j)
    if M[i0][j0] == 0:
        print("Matrice nulle : fin")
        return
    
    swapLigne(M, i, i0)
    swapCol(M, j, j0)

    print("Matrice apres étape 2 :")
    print_mat(M, i, j)
    print()

    recommencer = True
    while recommencer:
        recommencer = False
        print("Début de l'étape 3 :")
        print_mat(M, i, j)
        print()

        for k in range(i+1, m):
            q, r = M[k][j]//M[i][j], M[k][j] % M[i][j]
            addLigne(M, k, i, -q)
            if r != 0:
                print("Element ligne {} non divisible, inversion lignes".format(k+1))
                swapLigne(M, i, k)
                recommencer = True
                break
            print_mat(M, i, j)
            print()

    recommencer = True
    while recommencer:
        recommencer = False
        print("Début de l'étape 4 :")
        print_mat(M, i, j)
        print()
        for l in range(j+1, n):
            q, r = M[i][l]//M[i][j], M[i][l] % M[i][j]
            addCol(M, l, j, -q)
            if r != 0:
                swapCol(M, j, l)
                recommencer = True
                break
            print_mat(M, i, j)
            print()
    
    print("Etape 5 :")
    for k in range(i, m):
        for l in range(j, n):
            if M[k][l] % M[i][j] != 0:
                print("Element non divisible, retour (3)")
                addCol(M, j, l, 1)
                reduc(M, i, j)
                break
    
    print("Fin étape 5, calcul sur la matrice extraite")
    reduc(M, i+1, j+1)

A = [
    [4, 8, 4],
    [4, 13, 11],
    [4, 16, 8]
]

l = [(0, 4), (0,7), (0, 8), (1, 4), (1, 5), (2, 5), (2,6), (2, 8), (3,6), (3, 7), (4, 9), (5, 9), (6, 10), (7, 10), (8, 9), (8, 10)]
T = [[0 for _ in range(11)] for _ in range(11)]
for c in l:
    i, j = c 
    T[i][j] = 1


#print_mat(T, 0, 0)
#reduc(T, 0, 0)
#print_mat(T, 0, 0)

# Plot un graphe des différences entre la cmpx que g calc et la vrai

import numpy as np 
import matplotlib.pyplot as plt 
import math

N = 10

pts = np.linspace(1, N, N)
y_initiale = 8**pts

def binom(N,d):
    if d < 0 or d > N: return 0
    return math.factorial(N)//math.factorial(d)*math.factorial(N-d)

def calcN(N):
    s = 0
    N = int(N)
    for d in range(int(N)+1):
        s = s + (binom(N, d+1))**2 * binom(N, d+2)
    return s

y_ameliore = np.array([calcN(i) for i in pts])

plt.plot(pts, y_initiale, label="Complexité initiale")
plt.plot(pts, y_ameliore, label="Complexité améliorée")
plt.show()