import datetime
import requests
import numpy as np
from dotenv import load_dotenv
import os

load_dotenv()
API_key = os.getenv("API_key")

def build_dist(filename):
    url = "https://api.geoapify.com/v1/routing?waypoints={}%7C{}&mode={}&apiKey={}"
    lon, lat = np.loadtxt("data/"+filename+"_pts.txt", skiprows=1, unpack=True, usecols=[0, 1], dtype="str")
    
    nb_lines = len(lon) # Nb lignes dans le fichier

    with open('{}_dist.txt'.format(filename), 'w') as file:
        file.write(str(nb_lines) + "\n")

        for i in range(nb_lines):
            for j in range(nb_lines):
                if i < j:
                    coord1 = ",".join([lon[i], lat[i]])
                    coord2 = ",".join([lon[j], lat[j]])
                    # Calcule le temps min entre les deux moyennes 
                    resp1 = requests.request("GET", url.format(coord1, coord2, "drive", API_key))
                    resp2 = requests.request("GET", url.format(coord2, coord1, "drive", API_key))
                    time1 = resp1.json()["features"][0]["properties"]["time"]
                    time2 = resp2.json()["features"][0]["properties"]["time"]
                    moy1 = (time1+time2)/2

                    resp1 = requests.request("GET", url.format(coord1, coord2, "walk", API_key))
                    resp2 = requests.request("GET", url.format(coord2, coord1, "walk", API_key))
                    time1 = resp1.json()["features"][0]["properties"]["time"]
                    time2 = resp2.json()["features"][0]["properties"]["time"]
                    moy2 = (time1+time2)/2

                    file.write("{} {} {}\n".format(i, j, min(moy1, moy2)))
                    print("i={}, j={} done".format(i, j))

if __name__ == "__main__":
    build_dist("toulouse")