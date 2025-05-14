'''
 Contact : Elowan - elowarp@gmail.com
 Creation : 10-09-2024 17:13:53
 Last modified : 14-05-2025 13:50:22
 File : repr.py
'''

import numpy as np
import matplotlib.pyplot as plt
import plotly.graph_objects as go
import plotly.express as px
import sys
import os
import pandas as pd
import gudhi

def repr_PD(filename):
    # Charger le diagramme de persistance
    ax = gudhi.plot_persistence_diagram(persistence_file="exportedPD/"+filename+".dat", legend=True)
    ax.set_title("Persistence diagram of {}".format(filename))
    ax.set_aspect("equal") 
    ax.grid()
    ax.set_ylabel("Temps de mort (seconde)")
    ax.set_xlabel("Temps de naissance (seconde)")
    plt.savefig("images/pd_{}.png".format(filename), bbox_inches="tight", dpi=180)

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

    print("Statistiques pour {} (en secondes):".format(filename))
    print("     Médiane Variance")
    print("0d : {:.4}   {:.4}".format(np.median(death_0d), np.std(death_0d)))
    print("1d : {:.4}   {:.4}".format(np.median(death_1d), np.std(death_1d)))

def repr_map(filename):
    # Récupération des stations de métros
    lat, lon = np.loadtxt("data/"+filename+"_pts.txt", skiprows=1, 
                            unpack=True, usecols=[0, 1])

    # Récupération des formes des lignes de métros
    line, color, shape_lat, shape_lon, shape_pt_seq = \
        np.loadtxt("data/"+filename+"_shapes.txt", skiprows=0, unpack=True, dtype="str")

    # Récupération des zones de faiblesse
    s_i, s_j, s_k = np.loadtxt("exportedPD/"+filename+"_death.txt", unpack=True)
    
    simplexes = [[int(s_i[i]), int(s_j[i]), int(s_k[i]), int(s_i[i])] 
        for i in range(len(s_i))]
    # simplexes = []

    # Création du dict des formes nom_ligne_metro : [coordonnées]
    lines = {}
    for i in range(len(line)):
        line_name = str(line[i])
        if line_name not in lines:
            lines[line_name] = {
                "lat": [],
                "lon": [],
                "color": "#" + color[i]
            }
        
        lines[line_name]["lat"].append(float(shape_lat[i]))
        lines[line_name]["lon"].append(float(shape_lon[i]))
        


    fig = go.Figure()

    # Affichage des stations
    fig.add_trace(go.Scattermap(
            lat=lat,
            lon=lon,
            mode='markers',
            marker=go.scattermap.Marker(
                size=9
            ),
            name = "Stations de metro"
        ))
    
    
    # Affichage des zones de faiblesse
    triangles_x = [[lon[j] for j in simplexes[i] ] for i in range(len(simplexes))]
    triangles_y = [[lat[j] for j in simplexes[i] ] for i in range(len(simplexes))]

    for i in range(len(triangles_x)):
        fig.add_trace(go.Scattermap(lon=triangles_x[i], lat=triangles_y[i], 
            fill="toself", name="Zone {}".format(i), fillcolor="#9CAF88"))

    # Affichage des tracés des lignes
    for key, value in lines.items():
        fig.add_trace(go.Scattermap(lon=value["lon"], lat=value["lat"], 
            mode="lines", line=dict(color = value["color"]), name="Ligne {}".format(key)))


    fig.update_layout(
        autosize=True,
        hovermode='closest',
        map=dict(
            bearing=0,
            center = {
                "lon": float(np.mean(lon)), 
                "lat" :float(np.mean(lat))
            },
            pitch=0,
            zoom=12
        ),
        margin=dict(l=0, r=0, t=0, b=0),
        showlegend=False
    )

    if not os.path.exists("images"):
        os.mkdir("images")
    
    fig.write_image("images/"+filename+".png", width=800, height=800)

    # fig.show()

if __name__ == "__main__":
    if len(sys.argv) < 2: 
        print("Il faut au moins le nom d'une ville !")
        exit(1)
    
    # repr_PD(sys.argv[1])
    repr_map(sys.argv[1])
    # print_stats(sys.argv[1])
    