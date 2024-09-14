'''
 Contact : Elowan - elowarp@gmail.com
 Creation : 10-09-2024 17:13:53
 Last modified : 14-09-2024 22:18:47
 File : repr.py
'''
import numpy as np
import matplotlib.pyplot as plt

def repr_pointCloud(filename):
    x, y = np.loadtxt(filename, unpack=True, skiprows=1)
    plt.scatter(x, y)
    plt.show()
    
if __name__ == "__main__":
    repr_pointCloud("data/example.dat")