'''
 Contact : Elowan - elowarp@gmail.com
 Creation : 10-09-2024 17:13:53
 Last modified : 10-10-2024 22:33:25
 File : repr.py
'''
#%%
import numpy as np
import matplotlib.pyplot as plt
import os

def repr_pointCloud(filename):
    # Charger le fichier de triangulation
    pts = []
    triangles = []
    with open(filename, "r") as f:
        data = f.readlines()
        for line in data:
            if line[0] == "v":
                pts.append([float(x) for x in line.split()[2:]])
            elif line[0] == "t":
                triangles.append([int(x) for x in line.split()[1:]])

    # Convertir les listes en tableaux numpy
    pts = np.array(pts)
    triangles = np.array(triangles)

    # Afficher les points avec leur index
    plt.figure()
    for i, pt in enumerate(pts):
        plt.text(pt[0], pt[1], str(i))
    plt.scatter(pts[:, 0], pts[:, 1], c="red")
    plt.axis("equal")
    plt.axis("off")

    # Afficher les triangles
    for triangle in triangles:
        pts_triangle = pts[triangle]
        pts_triangle = np.vstack((pts_triangle, pts_triangle[0]))
        plt.plot(pts_triangle[:, 0], pts_triangle[:, 1], c="blue")
    
    plt.show()
    
def repr_filtration(filename):
    # Charger le fichier de filtrations
    pts_by_id = []
    pts_by_simplex = []
    edges = []
    triangles = []
    with open(filename, "r") as f:
        data = f.readlines()
        for line in data:
            if line[0] == "v":
                pts_by_id.append([float(x) for x in line.split()[2:]])
            elif line[0] == "t":
                elmts = [int(x) for x in line.split()[1:]]
                if elmts[0] == -1:
                    if elmts[1] == -1:  # Cas d'un point
                        pts_by_simplex.append((elmts[3], elmts[2]))
                    else: # Cas d'un coté
                        edges.append((elmts[3], elmts[1], elmts[2]))
                else: ## Cas d'un triangle
                    triangles.append((elmts[3], elmts[0], elmts[1], elmts[2]))
    
    # Convertir les listes en tableaux numpy
    pts_by_id = np.array(pts_by_id)
    pts_by_simplex = np.array(pts_by_simplex)
    edges = np.array(edges)
    triangles = np.array(triangles)

    # Afficher les points
    plt.figure()
    for pt in pts_by_simplex:
        x = pts_by_id[pt[1]][0]
        y = pts_by_id[pt[1]][1]
        plt.text(x, y, int(pt[0]), c="orange")

    # Afficher les arêtes avec leur index en leur milieu
    for edge in edges:
        pt1 = pts_by_id[edge[1]]
        pt2 = pts_by_id[edge[2]]
        plt.plot([pt1[0], pt2[0]], [pt1[1], pt2[1]], c="blue", alpha=0.7)
        plt.text((pt1[0] + pt2[0]) / 2, (pt1[1] + pt2[1]) / 2, str(edge[0]))

    # Afficher les triangles de centre coloré avec leur index en leur centre
    for triangle in triangles:
        pt1 = pts_by_id[triangle[1]]
        pt2 = pts_by_id[triangle[2]]
        pt3 = pts_by_id[triangle[3]]
        center = (pt1 + pt2 + pt3) / 3
        plt.fill([pt1[0], pt2[0], pt3[0]], [pt1[1], pt2[1], pt3[1]], c="blue", alpha=0.2)
        plt.text(center[0], center[1], str(triangle[0]), c="red")
        
    plt.axis("equal")
    plt.show()

def repr_PD(filename):
    # Charger le diagramme de persistance
    pts = []
    pairs = []
    max_birth = 0
    with open(filename, "r") as f:
        data = f.readlines()
        for line in data:
            if line[0] == "v":
                pts.append([float(x) for x in line.split()[1:]])
            elif line[0] == "p":
                pairs.append([int(x) for x in line.split()[1:]]) 
                max_birth = max(max_birth, pairs[-1][1])

    # Convertir les listes en tableaux numpy
    pts = np.array(pts)
    pairs = np.array(pairs)

    # Afficher les paires
    for pair in pairs:
        if pair[1] == -1:
            plt.scatter(pair[0], max_birth, c="blue")
        else:
            plt.scatter(pair[0], pair[1], c="blue")

    plt.axis("equal")
    plt.plot([0, max_birth], [0, max_birth], c="red")
    plt.show()

if __name__ == "__main__":
    # os.system("make tests")
    # repr_pointCloud("triangulation.txt")
    # repr_filtration("filtration.txt")
    repr_PD("exportedPD/pd_example.dat")
# %%
