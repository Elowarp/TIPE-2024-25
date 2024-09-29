'''
 Contact : Elowan - elowarp@gmail.com
 Creation : 10-09-2024 17:13:53
 Last modified : 29-09-2024 13:23:33
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
    
if __name__ == "__main__":
    os.system("make tests")
    repr_pointCloud("triangulation.txt")
# %%
