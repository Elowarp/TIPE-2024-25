'''
 Contact : Elowan - elowarp@gmail.com
 Creation : 10-09-2024 17:13:53
 Last modified : 19-11-2024 16:19:15
 File : repr.py
'''
#%%
import numpy as np
import matplotlib.pyplot as plt
import plotly.graph_objects as go
import plotly.express as px
import sys
import pandas as pd
import gudhi

marseille = {
                "lat":43.29695,
                "lon":5.38107,
            }

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
        plt.fill([pt1[0], pt2[0], pt3[0]], [pt1[1], pt2[1], pt3[1]], c="blue", 
                 alpha=0.2)
        plt.text(center[0], center[1], str(triangle[0]), c="red")
        
    plt.axis("equal")
    plt.show()

def repr_PD(filename):
    # Charger le diagramme de persistance
    ax = gudhi.plot_persistence_diagram(persistence_file=filename, legend=True)
    ax.set_title("Persistence diagram of {}".format(filename))
    ax.set_aspect("equal") 
    ax.grid()
    ax.set_ylabel("Temps de mort (seconde)")
    ax.set_xlabel("Temps de naissance (seconde)")
    plt.show()

def print_stats(filename):
    dim, birth, death = np.loadtxt("exportedPD/"+filename+".dat", unpack=True)
    
    birth_0d = []
    birth_1d = []
    death_0d = []
    death_1d = []
    for i in range(len(dim)):
        if death[i] != np.inf and death[i]/birth[i] >= 1.05:
            if dim[i] == 0: 
                birth_0d.append(birth[i])
                death_0d.append(death[i])

            if dim[i] == 1: 
                birth_1d.append(birth[i])
                death_1d.append(death[i])

    print("Pour {} :".format(filename))
    print("     Médiane Variance")
    print("0d : {:.3} {:.4}".format(np.median(death_0d), np.std(death_0d)))
    print("1d : {:.3} {:.4}".format(np.median(death_1d), np.std(death_1d)))

def repr_map(filename, simplexes=[]):
    lat, long, _ = np.loadtxt("data/"+filename+"_pts.txt", skiprows=1, unpack=True)
    # pts_x, pts_y, dist = np.loadtxt("data/"+filename+"_dist.txt", skiprows=1, unpack=True)

    distance = []
    # total = 0
    # for i in range(len(long)-1):
    #     if (total < len(dist)):
    #         distance.append(str(dist[total]))
    #         total += len(long) - 1 - i

    # distance.append("0")


    fig = go.Figure()

    fig.add_trace(go.Scattermap(
            lat=lat,
            lon=long,
            mode='markers',
            marker=go.scattermap.Marker(
                size=9
            ),
            name = "Stations de metro"
        ))
    
    
    x = [long[i] for i in simplexes]
    y = [lat[i] for i in simplexes]

    fig.add_trace(go.Scattermap(lon=x, lat=y, fill="toself"))

    fig.add_trace(go.Scattermap(lon=long, lat=lat, mode="lines", text=distance))


    fig.update_layout(
        autosize=True,
        hovermode='closest',
        map=dict(
            bearing=0,
            center=marseille,
            pitch=0,
            zoom=12
        ),
    )

    fig.show()

if __name__ == "__main__":
    if len(sys.argv) < 2: 
        print("Il faut au moins le nom d'une ville !")
        exit(1)
    
    marseille_simplex = [18, 23, 25, 18]
    example_simplex = [0, 2, 3, 0]
    # repr_PD("exportedPD/" + sys.argv[1] + ".dat")
    repr_map(sys.argv[1], marseille_simplex)
    # print_stats(sys.argv[1])
    
# %%
